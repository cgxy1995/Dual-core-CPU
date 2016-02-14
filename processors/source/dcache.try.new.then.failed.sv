`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
`include "cache_register_if.vh"
import cpu_types_pkg::*;

module dcache (
	input logic CLK, nRST,
	datapath_cache_if.dcache dcif,
	cache_control_if.dcache ccif
);

	cache_register_if crif();
	logic [7:0] allrValid0;
	logic [7:0] allrValid1;
	logic [7:0] allrdirty0;
	logic [7:0] allrdirty1;
	logic [7:0] allwdten;
	logic [7:0] allwfgen;
	logic [7:0] allrru0;
	logic [7:0] allrru1;
	logic [25:0]allrtag0	[7:0];
	logic [25:0]allrtag1	[7:0];

	word_t allrdat0 [7:0];
	word_t allrdat1 [7:0];

	logic faststate;

	typedef enum {IDLE,FLS0,FLS1,MEM0,MEM1} stateType;

	// Declare internal state type variables
	stateType cstate;
	stateType nstate;

	always_ff@(posedge CLK or negedge nRST) begin : state_flipflop
		if(~nRST) begin
			cstate = IDLE;
		end else if(!ccif.dwait | faststate) begin
			cstate = nstate;
		end
	end

	// dmemaddr separate
	logic [25:0] intag;
	logic [2:0] inindex;
	logic inword;
	assign intag = dcif.dmemaddr[31:6];
	assign inindex = dcif.dmemaddr[5:3];
	assign inword = dcif.dmemaddr[2];


	logic tagMatch0 , tagMatch1;
	assign tagMatch0 = (crif.rtag0==intag);
	assign tagMatch1 = (crif.rtag1==intag);

	logic veryDirty;
	assign veryDirty = crif.rdirty0&crif.rdirty1;

	always_comb begin : next_state_logic
		if(cstate==IDLE)begin
			if(!(dcif.dmemWEN|dcif.dmemREN))begin
				nstate = IDLE;
			end else begin  // dcif mem access
				if((tagMatch0&crif.rValid0)|(tagMatch1&crif.rValid1))begin    // hit
					nstate = IDLE;
				end else begin          // miss
					if(veryDirty)begin
						nstate = FLS0;
					end else begin
						nstate = MEM0;
					end
				end
			end
		end else if(cstate==FLS0)begin
			nstate = FLS1;
		end else if(cstate==FLS1)begin
			nstate = MEM0;
		end else if(cstate==MEM0)begin
			nstate = MEM1;
		end else if(cstate==MEM1)begin
			nstate = IDLE;
		end else begin
			nstate = IDLE;
		end
	end

	word_t ccif_dstore;
	word_t ccif_daddr;
	logic ccif_dREN;
	logic ccif_dWEN;
	logic crif_wrdsel;

	logic flushdWEN;
	logic flushwordSel;
	word_t flushdata;
	word_t flushaddr;

	logic [3:0] count , nextcount;
	logic [1:0] track;
	logic [1:0] nexttrack;
	always_comb begin: halt_not_halt_logic
		if(!dcif.halt)begin
			ccif.dREN = ccif_dREN;
			ccif.dWEN = ccif_dWEN;
			ccif.dstore = ccif_dstore;
			ccif.daddr = ccif_daddr;
			crif.wrdsel = crif_wrdsel;
		end else begin
			ccif.dREN = 0;
			ccif.dWEN = 0;//flushdWEN;
			ccif.dstore = flushdata;
			ccif.daddr = flushaddr;
			crif.wrdsel = flushwordSel;
		end
	end
	assign dcif.flushed = (count==8);

	logic ccif_tagsel;
	logic ccif_wrdsel;	// which word to load from/strore to mem
	always_comb begin : mem_tag_select
		if(ccif_tagsel==0)begin
			ccif_daddr = {crif.rtag0 , inindex , ccif_wrdsel , 2'b00};
		end else if(ccif_tagsel==1)begin
			ccif_daddr = {crif.rtag1 , inindex , ccif_wrdsel , 2'b00};
		end else begin
			ccif_daddr = 32'dx;
		end
	end





	logic LRU;	// pointer to whichever set is not last used
	assign LRU = crif.rru1;
	logic err_ru;	// recently used error bit
	assign err_ru = (crif.rru0==crif.rru1);

	assign dcif.dmemload = crif.rdat;
	always_comb begin : datapath_cache_if_dmemstore_mux
		ccif_dstore = crif.rdat;
	end

	logic dcif_blkoff;	// dcif memory load/store byte offset
	assign dcif_blkoff = dcif.dmemaddr[2];


	logic [25:0] ccif_tag;	// output tag
	assign ccif_tag = dcif.dmemaddr[31:6];

	// ccif.daddr = {ccif_tag , ccif_index , ccif_wrdsel , 2'b00};

	always_comb begin : mealy_machine
		ccif_dREN = 0;
		ccif_dWEN = 0;
		// tagsel should usually be same as setsel
		// wrdsel should usually be same
		crif.setsel = 1'bx;
		ccif_tagsel = 1'bx;	// which rtag to use for mem
		crif_wrdsel = 1'bx;	// which word to loadfrom/storeto cache reg
		ccif_wrdsel = 1'bx;	// which word to load from/strore to mem

		// write flag
		crif.wfgen = 0;
		crif.wru0 = 1'bx;	// use x to indicate error
		crif.wru1 = 1'bx;
		crif.wtag = 26'bx;
		crif.wdirty = 1'bx;

		// write data
		crif.wdten = 0;	// write data enable
		crif.wdat = 32'bx;

		faststate = 0;	// to jump to next state immidiately without waiting for dwait, used for miss write

		dcif.dhit = 0;

		$display("%g , %d" , $time , cstate);
		casez(cstate)
			IDLE:begin
				$display("IDLE:%g" , $time);
				if((crif.rtag0==intag)&crif.rValid0)begin	// set 0 hit
					crif.setsel = 0;
					crif_wrdsel = dcif_blkoff;
					// write flag
					crif.wfgen = 1;
					crif.wru0 = 1'b1;	// use x to indicate error
					crif.wru1 = 1'b0;
					crif.wtag = intag;
					crif.wdirty = crif.rdirty0;
					dcif.dhit = 1;
					ccif_dREN = 0;
					ccif_dWEN = 0;
				end else if((crif.rtag1==intag)&crif.rValid1)begin	// set 1 hit
					crif.setsel = 1;
					crif_wrdsel = dcif_blkoff;
					// write flag
					crif.wfgen = 1;
					crif.wru0 = 1'b0;	// use x to indicate error
					crif.wru1 = 1'b1;
					crif.wtag = intag;
					crif.wdirty = crif.rdirty1;
					dcif.dhit = 1;
					ccif_dREN = 0;
					ccif_dWEN = 0;
				end else begin
					faststate = 1;	// jump to other state then
				end
			end

			FLS0:begin		// flush first word
				$display("FLS0:%g" , $time);
				ccif_dWEN = 1;
				crif_wrdsel = 0;
				crif.setsel = LRU;	// which set is driving the cache reg output line
				ccif_tagsel = LRU;	// which rtag to use for mem

				ccif_dREN = 0;
			end
			FLS1:begin
				$display("FLS1:%g" , $time);
				ccif_dWEN = 1;
				crif_wrdsel = 1;
				crif.setsel = LRU;	// which set is driving the cache reg output line
				//crif.wdirty = 0;	// clear dirty bit
				//crif.wru0 = !crif.rru0;
				//crif.wru1 = !crif.rru1;
				//crif.wfgen = 1;		// flags write enable
				ccif_tagsel = LRU;	// which rtag to use for mem

				ccif_dREN = 0;
			end
			MEM0:begin




				$display("MEM0:%g , wen%b" , $time , dcif.dmemWEN);
				if(dcif.dmemREN)begin	// read miss
					ccif_dREN = 1;
					ccif_dWEN = 0;
					$display("read miss %g" , $time);
					// tagsel should usually be same as setsel for write
					// wrdsel should usually be same
					crif.setsel = LRU;
					ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
					crif_wrdsel = 0;	// which word to loadfrom/storeto cache reg
					ccif_wrdsel = 0;	// which word to load from/strore to mem
					// write flag: write flag happens in mem1 actually..
					/*crif.wfgen = 1;
					crif.wru0 = !crif.rru0;
					crif.wru1 = !crif.rru1;
					crif.wtag = intag;
					crif.wdirty = 0;*/
					// write data
					crif.wdten = 1;	// write data enable
					crif.wdat = ccif.dload;
				end else if(dcif.dmemWEN)begin	// write miss
					if(inword==0)begin	// dmemstore directly to cache
						$display("sw 0");
						faststate = 1;
						crif.setsel = LRU;
						ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
						crif_wrdsel = 0;	// which word to loadfrom/storeto cache reg
						ccif_wrdsel = 1'dx;	// which word to load from/strore to mem
						// write flag
						/*crif.wfgen = 1;
						crif.wru0 = !crif.rru0;
						crif.wru1 = !crif.rru1;
						crif.wtag = intag;
						crif.wdirty = 1;*/
						// write data
						crif.wdten = 1;	// write data enable
						crif.wdat = dcif.dmemstore;

						ccif_dREN = 0;
						ccif_dWEN = 0;
					end else begin	// this word is in ram
						$display("load word 0");
						ccif_dREN = 1;
						crif.setsel = LRU;
						ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
						crif_wrdsel = 0;	// which word to loadfrom/storeto cache reg
						ccif_wrdsel = 0;	// which word to load from/strore to mem
						// write flag
						/*crif.wfgen = 1;
						crif.wru0 = !crif.rru0;
						crif.wru1 = !crif.rru1;
						crif.wtag = intag;
						crif.wdirty = 1;*/
						// write data
						crif.wdten = 1;	// write data enable
						crif.wdat = ccif.dload;

						ccif_dWEN = 0;
					end
				end
			end
			MEM1:begin
				$display("MEM1:%g" , $time);
				ccif_dWEN = 0;
				if(dcif.dmemREN)begin	// read miss
					ccif_dREN = 1;
					ccif_dWEN = 0;
					// tagsel should usually be same as setsel for write
					// wrdsel should usually be same
					crif.setsel = LRU;
					ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
					crif_wrdsel = 1;	// which word to loadfrom/storeto cache reg
					ccif_wrdsel = 1;	// which word to load from/strore to mem
					// write flag
					crif.wfgen = 1;
					crif.wru0 = !crif.rru0;
					crif.wru1 = !crif.rru1;
					crif.wtag = intag;
					crif.wdirty = 0;
					// write data
					crif.wdten = 1;	// write data enable
					crif.wdat = ccif.dload;
				end else if(dcif.dmemWEN)begin	// write miss
					if(inword==1)begin	// dmemstore directly to cache
						faststate = 1;
						crif.setsel = LRU;
						ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
						crif_wrdsel = 1;	// which word to loadfrom/storeto cache reg
						ccif_wrdsel = 1'dx;	// which word to load from/strore to mem
						// write flag
						crif.wfgen = 1;
						crif.wru0 = !crif.rru0;
						crif.wru1 = !crif.rru1;
						crif.wtag = intag;
						crif.wdirty = 1;
						// write data
						crif.wdten = 1;	// write data enable
						crif.wdat = dcif.dmemstore;

						ccif_dREN = 0;
						ccif_dWEN = 0;
					end else begin	// this word is in ram
						crif.setsel = LRU;
						ccif_tagsel = 1'dx;	// not using this one because ccif is using dcif tag
						crif_wrdsel = 1;	// which word to loadfrom/storeto cache reg
						ccif_wrdsel = 1;	// which word to load from/strore to mem
						// write flag
						crif.wfgen = 1;
						crif.wru0 = !crif.rru0;
						crif.wru1 = !crif.rru1;
						crif.wtag = intag;
						crif.wdirty = 1;
						// write data
						crif.wdten = 1;	// write data enable
						crif.wdat = ccif.dload;

						ccif_dREN = 1;
						ccif_dWEN = 0;
					end
				end
			end
			default:begin
				$display("default:%g" , $time);
				ccif_dREN = 0;
				ccif_dWEN = 0;
				// tagsel should usually be same as setsel
				// wrdsel should usually be same
				crif.setsel = 1'bx;
				ccif_tagsel = 1'bx;	// which rtag to use for mem
				crif_wrdsel = 1'bx;	// which word to loadfrom/storeto cache reg
				ccif_wrdsel = 1'bx;	// which word to load from/strore to mem

				// write flag
				crif.wfgen = 0;
				crif.wru0 = 1'bx;	// use x to indicate error
				crif.wru1 = 1'bx;
				crif.wtag = 26'bx;
				crif.wdirty = 1'bx;

				// write data
				crif.wdten = 0;	// write data enable
				crif.wdat = 32'bx;

				faststate = 0;	// to jump to next state immidiately without waiting for dwait, used for miss write

				dcif.dhit = 0;
			end
		endcase
	end


	logic wValid;	// usually write one, write 0 to invalidate after halt
	assign wValid = !dcif.halt;

	genvar ii;
	generate
		for(ii = 0; ii < 8; ii++)begin: block_gen
			dblock #(.rstval('h0)) oneBlock(
				CLK,
				nRST,
				crif.wdat, // wData,
				crif.wtag, // setTag,
				crif.wValid,
				allwdten[ii]&(crif.setsel==0)&(!ccif.dwait),
				allrdat0[ii],
				allrtag0[ii],
				allrValid0[ii],
				crif.wdirty,
				allrdirty0[ii],
				crif.wru0,
				allrru0[ii],
				allwfgen[ii]&(crif.setsel==0)&(!ccif.dwait),
				crif_wrdsel
			);

			dblock #(.rstval('h1)) twoBlock(
				CLK,
				nRST,
				crif.wdat, // wData,
				crif.wtag, // setTag,
				crif.wValid,
				allwdten[ii]&(crif.setsel==1)&(!ccif.dwait),
				allrdat1[ii],
				allrtag1[ii],
				allrValid1[ii],
				crif.wdirty,
				allrdirty1[ii],
				crif.wru1,
				allrru1[ii],
				allwfgen[ii]&(crif.setsel==1)&(!ccif.dwait),
				crif_wrdsel
			);
		end
	endgenerate

	always_comb begin: select_index
		allwdten	= 0;
		allwfgen	= 0;
		crif.rdat0	= 'bx;
		crif.rdat1	= 'bx;
		crif.rru0	= 'bx;
		crif.rru1	= 'bx;
		crif.rtag0	= 'bx;
		crif.rtag1	= 'bx;
		casez(inindex)
			0:begin
				crif.rValid0	= allrValid0[0];
				crif.rValid1	= allrValid1[0];
				crif.rdirty0	= allrdirty0[0];
				crif.rdirty1	= allrdirty1[0];
				allwdten[0]		= crif.wdten;
				allwfgen[0]		= crif.wfgen;
				crif.rdat0		= allrdat0[0];
				crif.rdat1	= allrdat1[0];
				crif.rru0		= allrru0[0];
				crif.rru1		= allrru1[0];
				crif.rtag0		= allrtag0[0];
				crif.rtag1		= allrtag1[0];
			end
			1:begin
				crif.rValid0=allrValid0[1];crif.rValid1= allrValid1[1];
				crif.rdirty0=allrdirty0[1];crif.rdirty1= allrdirty1[1];
				allwdten[1]=crif.wdten;allwfgen[1]=crif.wfgen;
				crif.rdat0=allrdat0[1];crif.rdat1=allrdat1[1];
				crif.rru0=allrru0[1];crif.rru1= allrru1[1];
				crif.rtag0=allrtag0[1];crif.rtag1= allrtag1[1];
			end
			2:begin
				crif.rValid0	= allrValid0[2];
				crif.rValid1	= allrValid1[2];
				crif.rdirty0	= allrdirty0[2];
				crif.rdirty1	= allrdirty1[2];
				allwdten[2]		= crif.wdten;
				allwfgen[2]		= crif.wfgen;
				crif.rdat0		= allrdat0[2];
				crif.rdat1	= allrdat1[2];
				crif.rru0		= allrru0[2];
				crif.rru1		= allrru1[2];
				crif.rtag0		= allrtag0[2];
				crif.rtag1		= allrtag1[2];
			end
			3:begin
				crif.rValid0	= allrValid0[3];
				crif.rValid1	= allrValid1[3];
				crif.rdirty0	= allrdirty0[3];
				crif.rdirty1	= allrdirty1[3];
				allwdten[3]		= crif.wdten;
				allwfgen[3]		= crif.wfgen;
				crif.rdat0		= allrdat0[3];
				crif.rdat1	= allrdat1[3];
				crif.rru0		= allrru0[3];
				crif.rru1		= allrru1[3];
				crif.rtag0		= allrtag0[3];
				crif.rtag1		= allrtag1[3];
			end
			4:begin
				crif.rValid0 = allrValid0[4];
				crif.rValid1 = allrValid1[4];
				crif.rdirty0= allrdirty0[4];
				crif.rdirty1= allrdirty1[4];
				allwdten[4] = crif.wdten;
				allwfgen[4] = crif.wfgen;
				crif.rdat0	= allrdat0[4];
				crif.rdat1	= allrdat1[4];
				crif.rru0	= allrru0[4];
				crif.rru1	= allrru1[4];
				crif.rtag0	= allrtag0[4];
				crif.rtag1	= allrtag1[4];
			end
			5:begin
				crif.rValid0 = allrValid0[5];
				crif.rValid1 = allrValid1[5];
				crif.rdirty0= allrdirty0[5];
				crif.rdirty1= allrdirty1[5];
				allwdten[5] = crif.wdten;
				allwfgen[5] = crif.wfgen;
				crif.rdat0	= allrdat0[5];
				crif.rdat1	= allrdat1[5];
				crif.rru0	= allrru0[5];
				crif.rru1	= allrru1[5];
				crif.rtag0	= allrtag0[5];
				crif.rtag1	= allrtag1[5];
			end
			6:begin
				crif.rValid0 = allrValid0[6];
				crif.rValid1 = allrValid1[6];
				crif.rdirty0= allrdirty0[6];
				crif.rdirty1= allrdirty1[6];
				allwdten[6] = crif.wdten;
				allwfgen[6] = crif.wfgen;
				crif.rdat0	= allrdat0[6];
				crif.rdat1	= allrdat1[6];
				crif.rru0	= allrru0[6];
				crif.rru1	= allrru1[6];
				crif.rtag0	= allrtag0[6];
				crif.rtag1	= allrtag1[6];
			end
			7:begin
				crif.rValid0 = allrValid0[7];
				crif.rValid1 = allrValid1[7];
				crif.rdirty0= allrdirty0[7];
				crif.rdirty1= allrdirty1[7];
				allwdten[7] = crif.wdten;
				allwfgen[7] = crif.wfgen;
				crif.rdat0	= allrdat0[7];
				crif.rdat1	= allrdat1[7];
				crif.rru0	= allrru0[7];
				crif.rru1	= allrru1[7];
				crif.rtag0	= allrtag0[7];
				crif.rtag1	= allrtag1[7];
			end
		endcase
	end





	/// flush logic
	always_ff@(posedge CLK or negedge nRST)begin
		if(~nRST)begin
			count = 0;
			track = 0;
		end else begin
			//count = nextcount;
			if(flushdWEN)begin
				if(!ccif.dwait)begin
					track = nexttrack;
					count = nextcount;
				end
			end else begin
				track = nexttrack;
				count = nextcount;
			end
		end
	end
	always_comb begin
		nextcount = count;
		nexttrack =track;
		flushaddr = 'bx;
		flushdata = 'bx;
		flushdWEN = 0;
		flushwordSel = track[0];
		if(dcif.halt==1'b1)begin //How do I know there is a halt?
			case(count)
				0:
				begin
					if(allrdirty0[0]|allrdirty1[0])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[0],3'd0,1'b0,2'b00};
							flushdata = allrdat0[0];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[0];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[0],3'd0,1'b1,2'b00};
							flushdata = allrdat0[0];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[0];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[0],3'd0,1'b0,2'b00};
							flushdata = allrdat1[0];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[0];
						end else begin
							flushaddr = {allrtag1[0],3'd0,1'b1,2'b00};
							flushdata = allrdat1[0];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[0];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				1:
				begin
					if(allrdirty0[1]|allrdirty1[1])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[1],3'd1,1'b0,2'b00};
							flushdata = allrdat0[1];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[1];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[1],3'd1,1'b1,2'b00};
							flushdata = allrdat0[1];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[1];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[1],3'd1,1'b0,2'b00};
							flushdata = allrdat1[1];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[1];
						end else begin
							flushaddr = {allrtag1[1],3'd1,1'b1,2'b00};
							flushdata = allrdat1[1];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[1];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				2:
				begin
					if(allrdirty0[2]|allrdirty1[2])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[2],3'd2,1'b0,2'b00};
							flushdata = allrdat0[2];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[2];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[2],3'd2,1'b1,2'b00};
							flushdata = allrdat0[2];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[2];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[2],3'd2,1'b0,2'b00};
							flushdata = allrdat1[2];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[2];
						end else begin
							flushaddr = {allrtag1[2],3'd2,1'b1,2'b00};
							flushdata = allrdat1[2];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[2];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				3:
				begin
					if(allrdirty0[3]|allrdirty1[3])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[3],3'd3,1'b0,2'b00};
							flushdata = allrdat0[3];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[3];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[3],3'd3,1'b1,2'b00};
							flushdata = allrdat0[3];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[3];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[3],3'd3,1'b0,2'b00};
							flushdata = allrdat1[3];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[3];
						end else begin
							flushaddr = {allrtag1[3],3'd3,1'b1,2'b00};
							flushdata = allrdat1[3];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[3];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				4:
				begin
					if(allrdirty0[4]|allrdirty1[4])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[4],3'd4,1'b0,2'b00};
							flushdata = allrdat0[4];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[4];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[4],3'd4,1'b1,2'b00};
							flushdata = allrdat0[4];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[4];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[4],3'd4,1'b0,2'b00};
							flushdata = allrdat1[4];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[4];
						end else begin
							flushaddr = {allrtag1[4],3'd4,1'b1,2'b00};
							flushdata = allrdat1[4];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[4];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				5:
				begin
					if(allrdirty0[5]|allrdirty1[5])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[5],3'd5,1'b0,2'b00};
							flushdata = allrdat0[5];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[5];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[5],3'd5,1'b1,2'b00};
							flushdata = allrdat0[5];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[5];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[5],3'd5,1'b0,2'b00};
							flushdata = allrdat1[5];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[5];
						end else begin
							flushaddr = {allrtag1[5],3'd5,1'b1,2'b00};
							flushdata = allrdat1[5];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[5];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				6:
				begin
					if(allrdirty0[6]|allrdirty1[6])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[6],3'd6,1'b0,2'b00};
							flushdata = allrdat0[6];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[6];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[6],3'd6,1'b1,2'b00};
							flushdata = allrdat0[6];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[6];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[6],3'd6,1'b0,2'b00};
							flushdata = allrdat1[6];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[6];
						end else begin
							flushaddr = {allrtag1[6],3'd6,1'b1,2'b00};
							flushdata = allrdat1[6];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[6];
							nextcount = count+1;
						end
					end else begin
						nextcount = count+1;
					end
				end
				7:
				begin
					if(allrdirty0[7]|allrdirty1[7])begin
						//flushdWEN = 1;
						if((track == 2'b00))begin
							flushaddr = {allrtag0[7],3'd7,1'b0,2'b00};
							flushdata = allrdat0[7];
							nexttrack = 2'b01;
							flushdWEN = allrdirty0[7];
						end else if((track == 2'b01))begin
							flushaddr = {allrtag0[7],3'd7,1'b1,2'b00};
							flushdata = allrdat0[7];
							nexttrack = 2'b10;
							flushdWEN = allrdirty0[7];
						end else if((track == 2'b10))begin
							flushaddr = {allrtag1[7],3'd7,1'b0,2'b00};
							flushdata = allrdat1[7];
							nexttrack = 2'b11;
							flushdWEN = allrdirty1[7];
						end else begin
							flushaddr = {allrtag1[7],3'd7,1'b1,2'b00};
							flushdata = allrdat1[7];
							nexttrack = 2'b00;
							flushdWEN = allrdirty1[7];
							nextcount = count+1;
						end
					end else begin
						nextcount = count + 1;
					end
				end
				8:
				begin
					nextcount = 8;
				end
			endcase
		end
	end


endmodule