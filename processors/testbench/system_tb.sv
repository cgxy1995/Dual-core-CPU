/*
	Eric Villasenor
	evillase@gmail.com

	system test bench, for connected processor (datapath+cache)
	and memory (ram).
*/

// interface
`include "system_if.vh"

// types
`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
`include "datapath_cache_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module system_tb;
  // clock period
  parameter PERIOD = 20;

	// signals
	logic CLK = 1, nRST;

	// clock
	always #(PERIOD/2) CLK++;

	// interface
	system_if syif();

	// test program
	test                                PROG (CLK,nRST,syif);

	// dut
`ifndef MAPPED
	system                              DUT (CLK,nRST,syif/*,ccif,dcif*/);
`else
	system                              DUT (,,,,//for altera debug ports
		CLK,
		nRST,
		syif.halt,
		syif.load,
		syif.addr,
		syif.store,
		syif.REN,
		syif.WEN,
		syif.tbCTRL
	);
`endif

	/*always@(posedge ccif.daddr,posedge ccif.dWEN,posedge ccif.dREN, posedge ccif.iaddr,posedge ccif.iload ,posedge ccif.iREN, posedge ccif.iwait,posedge ccif.dwait,
posedge dcif.halt, posedge dcif.dmemREN, posedge dcif.dmemWEN,
posedge dcif.datomic, posedge dcif.dmemstore, posedge dcif.dmemaddr,
posedge dcif.dhit, posedge dcif.dmemload,posedge dcif.flushed
,posedge DUT.outrValid0
,posedge DUT.outwen0
,posedge DUT.outwValid0
,posedge DUT.outwRU0


	) begin
		$display("ccif::%x,%x,%x,%b,%b" , ccif.daddr,ccif.dload , ccif.dstore ,ccif.dWEN,ccif.dREN);
		$display("ccif::%x,%x,%b" , ccif.iaddr,ccif.iload ,ccif.iREN);
		$display("ccif::%b,%b" , ccif.iwait,ccif.dwait);
		$display("out::%b , %b , %b , %b"
, DUT.outrValid0
, DUT.outwen0
, DUT.outwValid0
, DUT.outwRU0);


$display("dcif::%x,%x,%x,%x,%x,%x,%x,%x,%x" , dcif.halt, dcif.dmemREN, dcif.dmemWEN,
dcif.datomic, dcif.dmemstore, dcif.dmemaddr,
dcif.dhit, dcif.dmemload, dcif.flushed,);

	end*/




endmodule

program test(input logic CLK, output logic nRST, system_if.tb syif);
	// import word type
	import cpu_types_pkg::word_t;

	// number of cycles
	int unsigned cycles = 0;

	initial
	begin
		nRST = 0;
		syif.tbCTRL = 0;
		syif.addr = 0;
		syif.store = 0;
		syif.WEN = 0;
		syif.REN = 0;
		@(posedge CLK);
		$display("Starting Processor.");
		nRST = 1;
		// wait for halt
		while (!syif.halt)
		begin
			@(posedge CLK);
			cycles++;
			//$display("cycle:%d" , cycles);
		end
		$display("Halted at %g time and ran for %d cycles.",$time, cycles);

		nRST = 0;
		dump_memory();
		$finish;
	end

	task automatic dump_memory();
		string filename = "memcpu.hex";
		int memfd;

		syif.tbCTRL = 1;
		syif.addr = 0;
		syif.WEN = 0;
		syif.REN = 0;

		memfd = $fopen(filename,"w");
		if (memfd)
			$display("Starting memory dump.");
		else
			begin $display("Failed to open %s.",filename); $finish; end

		for (int unsigned i = 0; memfd && i < 8192; i++)
		begin

			int chksum = 0;
			bit [7:0][7:0] values;
			string ihex;

			syif.addr = i << 2;
			//$display("dump addr %x" , syif.addr);
			syif.REN = 1;
			repeat (2) @(posedge CLK);
			if (syif.load === 0)
				continue;
			values = {8'h04,16'(i),8'h00,syif.load};
			foreach (values[j])
				chksum += values[j];
			chksum = 16'h100 - chksum;
			ihex = $sformatf(":04%h00%h%h",16'(i),syif.load,8'(chksum));
			$fdisplay(memfd,"%s",ihex.toupper());
		end //for
		if (memfd)
		begin
			syif.tbCTRL = 0;
			syif.REN = 0;
			$fdisplay(memfd,":00000001FF");
			$fclose(memfd);
			$display("Finished memory dump.");
		end
	endtask
endprogram
