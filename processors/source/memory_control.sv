/*
	Mingfei Huang
	huang243@purdue.edu

	this block is the coherence protocol
	and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
	input CLK, nRST,
	cache_control_if.cc ccif
);
	// type import
	import cpu_types_pkg::*;
	parameter CPUS = 2;

/*  modport cc (
			// cache inputs
	input   iREN, dREN, dWEN, dstore, iaddr, daddr,
			// ram inputs
			ramload, ramstate,
			// coherence inputs from cache
			ccwrite, cctrans,
			// cache outputs
	output  iwait, dwait, iload, dload,
			// ram outputs
			ramstore, ramaddr, ramWEN, ramREN,
			// coherence outputs to cache
			ccwait, ccinv, ccsnoopaddr
  );*/

// cc state stuff


logic toggle_iread;

typedef enum{
	IDLE,
	SNOOP0,
	INVALID0,
	SNOOP1,
	INVALID1,
	INST0,
	INST1,
	FLUSH_FIRST0,
	FLUSH_SECOND0,
	READ_FIRST0,
	READ_SECOND0,
	FLUSH_FIRST1,
	FLUSH_SECOND1,
	READ_FIRST1,
	READ_SECOND1,
	SIMPLE_FIRST0,
	SIMPLE_SECOND0,
	SIMPLE_FIRST1,
	SIMPLE_SECOND1
}stateType;
stateType cstate , nstate;
always_ff@(posedge CLK or negedge nRST) begin : _state_logic
	if(~nRST)begin
		cstate = IDLE;
	end else begin
		cstate = nstate;
	end
end

always_comb begin : _cc_next_state_logic
	case(cstate)
	IDLE:begin
		if(ccif.dWEN[0])begin
			nstate = SIMPLE_FIRST0;	// simple flush have higher priority
		end else if(ccif.dWEN[1])begin
			nstate = SIMPLE_FIRST1;
		end else if(ccif.dREN[0])begin
			nstate = SNOOP0;		// then handle read write stuff
		end else if(ccif.dREN[1])begin
			nstate = SNOOP1;
		end else if(ccif.iREN[0]&ccif.iREN[1])begin
			if(toggle_iread)begin
				nstate = INST0;
			end else begin
				nstate = INST1;
			end
		end else if(ccif.iREN[0])begin
			nstate = INST0;
		end else if(ccif.iREN[1])begin
			nstate = INST1;
		end else begin
			nstate = IDLE;
		end
	end

	SNOOP0:begin	// snoop into each other to see if dirty
		if(ccif.dREN[0])begin
			if(ccif.ccdirty[1])begin
				nstate = FLUSH_FIRST0;
			end else begin
				nstate = READ_FIRST0;
			end
		end else begin
			nstate = IDLE;
		end
	end

	SNOOP1:begin
		if(ccif.dREN[1])begin
			if(ccif.ccdirty[0])begin
				nstate = FLUSH_FIRST1;
			end else begin
				nstate = READ_FIRST1;
			end
		end else begin
			nstate = IDLE;
		end
	end

	FLUSH_FIRST0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = FLUSH_SECOND0;
		end else begin
			nstate = FLUSH_FIRST0;
		end
	end
	FLUSH_SECOND0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = READ_FIRST0;
		end else begin
			nstate = FLUSH_SECOND0;
		end
	end
	READ_FIRST0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = READ_SECOND0;
		end else begin
			nstate = READ_FIRST0;
		end
	end
	READ_SECOND0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = READ_SECOND0;
		end
	end

	FLUSH_FIRST1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = FLUSH_SECOND1;
		end else begin
			nstate = FLUSH_FIRST1;
		end
	end
	FLUSH_SECOND1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = READ_FIRST1;
		end else begin
			nstate = FLUSH_SECOND1;
		end
	end
	READ_FIRST1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = READ_SECOND1;
		end else begin
			nstate = READ_FIRST1;
		end
	end
	READ_SECOND1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = READ_SECOND1;
		end
	end
	SIMPLE_FIRST0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = SIMPLE_SECOND0;
		end else begin
			nstate = SIMPLE_FIRST0;
		end
	end
	SIMPLE_SECOND0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = SIMPLE_SECOND0;
		end
	end
	SIMPLE_FIRST1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = SIMPLE_SECOND1;
		end else begin
			nstate = SIMPLE_FIRST1;
		end
	end
	SIMPLE_SECOND1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = SIMPLE_SECOND1;
		end
	end

	INST0:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = INST0;
		end
	end

	INST1:begin
		if(ccif.ramstate==ACCESS)begin
			nstate = IDLE;
		end else begin
			nstate = INST1;
		end
	end

	default:begin nstate = IDLE;end
	endcase
end

always_comb begin : _ccaddr
	// snoop each other
	ccif.ccsnoopaddr[0] = ccif.daddr[1];
	ccif.ccsnoopaddr[1] = ccif.daddr[0];
end

always_comb begin : _toggle_iread
	// pseudo randomly toggle inst load
	if(nRST)begin toggle_iread = 0;end
	else begin toggle_iread = !toggle_iread;end
end

// _the actual main stuff
always_comb begin : _output_logic
	ccif.iwait[0] = 1;
	ccif.iwait[1] = 1;
	ccif.dwait[0] = 1;
	ccif.dwait[1] = 1;
	ccif.ccinv[0] = ccif.cctrans[1];	// cctrans is asserted when the cache has a write hit
	ccif.ccinv[1] = ccif.cctrans[0];	// which means a S->M, causing the other cache to do a S->I
	ccif.ccwait[0] = 0;
	ccif.ccwait[1] = 0;
	ccif.ramstore = 0;
	ccif.ramaddr = 0;
	ccif.ramWEN = 0;
	ccif.ramREN = 0;
	case(cstate)
		IDLE:begin
			// all default value
		end
		SNOOP0:begin	// snoop into c1 find dirty bit
			// guess not dirty to save one cycle of ram wait time
			ccif.ramaddr = ccif.daddr[0];
			ccif.ramREN = 1;
		end
		SNOOP1:begin	// snoop into c1 find dirty bit
			// guess not dirty to save one cycle of ram wait time
			ccif.ramaddr = ccif.daddr[1];
			ccif.ramREN = 1;
		end
		FLUSH_FIRST0:begin	// the dirty cache write back to ram
			ccif.ccwait[1] = 1;
			ccif.ramWEN = 1;
			if(ccif.ccwrite[0])begin
				ccif.ccinv[1] = 1;
			end
			ccif.ramstore = ccif.dstore[1];
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS);
		end
		FLUSH_SECOND0:begin	// the dirty cache write back to ram
			ccif.ccwait[1] = 1;
			ccif.ramWEN = 1;
			if(ccif.ccwrite[0])begin
				ccif.ccinv[1] = 1;
			end
			ccif.ramstore = ccif.dstore[1];
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS);
		end
		FLUSH_FIRST1:begin	// the dirty cache write back to ram
			ccif.ccwait[0] = 1;
			ccif.ramWEN = 1;
			if(ccif.ccwrite[1])begin
				ccif.ccinv[0] = 1;
			end
			ccif.ramstore = ccif.dstore[0];
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS);
		end
		FLUSH_SECOND1:begin	// the dirty cache write back to ram
			ccif.ccwait[0] = 1;
			ccif.ramWEN = 1;
			if(ccif.ccwrite[1])begin
				ccif.ccinv[0] = 1;
			end
			ccif.ramstore = ccif.dstore[0];
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS);
		end
		READ_FIRST0:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS)|(!ccif.dREN[0]);
		end
		READ_SECOND0:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS)|(!ccif.dREN[0]);
		end
		READ_FIRST1:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS)|(!ccif.dREN[1]);
		end
		READ_SECOND1:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS)|(!ccif.dREN[1]);
		end
		INST0:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.iaddr[0];
			ccif.iwait[0] = (ccif.ramstate!=ACCESS);
		end
		INST1:begin
			ccif.ramREN = 1;
			ccif.ramaddr = ccif.iaddr[1];
			ccif.iwait[1] = (ccif.ramstate!=ACCESS);
		end
		SIMPLE_FIRST0:begin
			ccif.ramWEN = 1;
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS);
			ccif.ramstore = ccif.dstore[0];
		end
		SIMPLE_SECOND0:begin
			ccif.ramWEN = 1;
			ccif.ramaddr = ccif.daddr[0];
			ccif.dwait[0] = (ccif.ramstate!=ACCESS);
			ccif.ramstore = ccif.dstore[0];
		end
		SIMPLE_FIRST1:begin
			ccif.ramWEN = 1;
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS);
			ccif.ramstore = ccif.dstore[1];
		end
		SIMPLE_SECOND1:begin
			ccif.ramWEN = 1;
			ccif.ramaddr = ccif.daddr[1];
			ccif.dwait[1] = (ccif.ramstate!=ACCESS);
			ccif.ramstore = ccif.dstore[1];
		end
	endcase
end



assign ccif.dload[0] = ccif.ramload;
assign ccif.dload[1] = ccif.ramload;
assign ccif.iload[0] = ccif.ramload;
assign ccif.iload[1] = ccif.ramload;











endmodule
