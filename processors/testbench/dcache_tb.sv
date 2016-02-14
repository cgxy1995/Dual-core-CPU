/*
	Mingfei Huang
	datapath testbench
*/

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module dcache_tb;

	datapath_cache_if dcif();
	cache_control_if ccif();
	cpu_ram_if scif();



	logic CLK , nRST;

	parameter PERIOD = 10;
	parameter RAM = 20;
	always #(PERIOD/2) CLK++;

	//dcache icdut(CLK, nRST, dcif, ccif);


	`ifndef MAPPED
		dcache icdut(CLK, nRST, dcif, ccif);
	`else
		dcache  icdut(
			.CLK(CLK),
			.nRST(nRST),
			.\dcif.flushed (dcif.flushed) ,
			.\dcif.dmemload (dcif.dmemload) ,
			.\dcif.dhit (dcif.dhit) ,
			.\dcif.dmemaddr (dcif.dmemaddr) ,
			.\dcif.dmemstore (dcif.dmemstore) ,
			.\dcif.datomic (dcif.datomic) ,
			.\dcif.dmemWEN (dcif.dmemWEN) ,
			.\dcif.dmemREN (dcif.dmemREN) ,
			.\dcif.halt (dcif.halt) ,
			.\ccif.cctrans (ccif.cctrans) ,
			.\ccif.ccwrite (ccif.ccwrite) ,
			.\ccif.ccread (ccif.ccread) ,
			.\ccif.dstore (ccif.dstore) ,
			.\ccif.daddr (ccif.daddr) ,
			.\ccif.dWEN (ccif.dWEN) ,
			.\ccif.dREN (ccif.dREN) ,
			.\ccif.ccsnoopaddr (ccif.ccsnoopaddr) ,
			.\ccif.ccinv (ccif.ccinv) ,
			.\ccif.ccwb (ccif.ccwb) ,
			.\ccif.ccwait (ccif.ccwait) ,
			.\ccif.dload (ccif.dload) ,
			.\ccif.dwait (ccif.dwait)
			);
	`endif
/*
	assign ramif.memaddr = ccif.ramaddr;
	assign ramif.memstore = ccif.ramstore;
	assign ramif.memREN = ccif.ramREN;
	assign ramif.memWEN = ccif.ramWEN;
	assign ccif.ramload = ramif.ramload;
	assign ccif.ramstate = ramif.ramstate;*/

/*
	ram oneram(CLK, nRST, ramif);
	memory_control memctrl(CLK, nRST,ccif);*/

	logic halt;
	singlecycle onecpu (CLK, nRST,halt,scif);

	initial begin
		CLK = 0;
		nRST = 0;
		dcif.dmemREN = 0;
		dcif.dmemWEN = 0;
		dcif.dmemaddr = 0;
		#PERIOD;

		nRST = 1;

		#(PERIOD/2);
		dcif.dmemREN = 1;
		dcif.dmemaddr = 32'h0;
/*
		@(posedge dcif.dhit)begin
			dcif.dmemREN = 0;
		end*/


		#(PERIOD*10);

		#(PERIOD)
		dcif.dmemREN = 1;
		dcif.dmemaddr = 32'h4;
		#RAM;


		// wait for dhit(simulate datapath)
		#(PERIOD)
		dcif.dmemREN = 1;
		dcif.dmemaddr = 32'h8;
		#RAM;

		// wait for dhit(simulate datapath)
		#(PERIOD)

		dcif.dmemREN = 1;
		dcif.dmemaddr = 32'h0;
		#RAM;

		// wait for dhit(simulate datapath)
		#(PERIOD)

		dcif.dmemREN = 0;
		dcif.dmemWEN = 1;
		dcif.dmemaddr = 32'h4;
		dcif.dmemstore = 32'hd4d4d4d4;

		// wait for dhit(simulate datapath)
		#(PERIOD);
		#(PERIOD);

		dcif.dmemREN = 1;
		dcif.dmemWEN = 0;
		dcif.dmemaddr = 32'h4;
		#(PERIOD);

		// wait for dhit(simulate datapath)

		dcif.dmemWEN = 1;
		dcif.dmemREN = 1;
		dcif.dmemaddr = 32'h4;
		#RAM;
		// wait for dhit(simulate datapath)
		#(PERIOD);




	end

	/*always@(ccif.ramstate)begin
		$display("%x" , ccif.ramstate);
	end*/
/*
	always@(
posedge icdut.dpTag
,posedge icdut.cTag
,posedge icdut.inIndex
,posedge icdut.rValid
,posedge icdut.inBO
,posedge icdut.inByteO
,posedge icdut.rData
,posedge icdut.readValid0
,posedge icdut.readValid1
,posedge icdut.set
,posedge icdut.setEN
,posedge icdut.setDirty0
,posedge icdut.setDirty1
,posedge icdut.readDirty0
,posedge icdut.readDirty1
,posedge icdut.setRU0
,posedge icdut.setRU1
,posedge icdut.RUEN
,posedge icdut.syncRUEN
,posedge icdut.writDirty0
,posedge icdut.writDirty1
,posedge icdut.writValid0
,posedge icdut.writValid1
,posedge icdut.writRecentlyUsed0
,posedge icdut.writRecentlyUsed1
,posedge icdut.readRecentlyUsed0
,posedge icdut.readRecentlyUsed1
,posedge icdut.cWEN0
,posedge icdut.cWEN1
,posedge icdut.setsel0
,posedge icdut.setsel1
,posedge icdut.wen0
,posedge icdut.wen1
,posedge icdut.rData0
,posedge icdut.rData1
,posedge icdut.rTag0
,posedge icdut.rTag1
,posedge icdut.wDirty0
,posedge icdut.wDirty1
,posedge icdut.rDirty0
,posedge icdut.rDirty1
,posedge icdut.wValid0
,posedge icdut.wValid1
,posedge icdut.rValid0
,posedge icdut.rValid1
,posedge icdut.wRU0
,posedge icdut.wRU1
,posedge icdut.rRU0
,posedge icdut.rRU1
,posedge icdut.blkStat
,posedge icdut.wData
,posedge icdut.wTag
,posedge icdut.rAddr0
,posedge icdut.rAddr1
,posedge icdut.wsel
,posedge icdut.onevar
,posedge icdut.hitCen
,posedge icdut.hitcount
,posedge icdut.SLstate
,posedge icdut.SLtrigger
,posedge icdut.fakeHit
)begin
		$display("%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x
"
,icdut.dpTag
,icdut.cTag
,icdut.inIndex
,icdut.rValid
,icdut.inBO
,icdut.inByteO
,icdut.rData
,icdut.readValid0
,icdut.readValid1
,icdut.set
,icdut.setEN
,icdut.setDirty0
,icdut.setDirty1
,icdut.readDirty0
,icdut.readDirty1
,icdut.setRU0
,icdut.setRU1
,icdut.RUEN
,icdut.syncRUEN
,icdut.writDirty0
,icdut.writDirty1
,icdut.writValid0
,icdut.writValid1
,icdut.writRecentlyUsed0
,icdut.writRecentlyUsed1
,icdut.readRecentlyUsed0
,icdut.readRecentlyUsed1
,icdut.cWEN0
,icdut.cWEN1
,icdut.setsel0
,icdut.setsel1
,icdut.wen0
,icdut.wen1
,icdut.rData0
,icdut.rData1
,icdut.rTag0
,icdut.rTag1
,icdut.wDirty0
,icdut.wDirty1
,icdut.rDirty0
,icdut.rDirty1
,icdut.wValid0
,icdut.wValid1
,icdut.rValid0
,icdut.rValid1
,icdut.wRU0
,icdut.wRU1
,icdut.rRU0
,icdut.rRU1
,icdut.blkStat
,icdut.wData
,icdut.wTag
,icdut.rAddr0
,icdut.rAddr1
,icdut.wsel
,icdut.onevar
,icdut.hitCen
,icdut.hitcount
,icdut.SLstate
,icdut.SLtrigger
);
end
*/
/*

logic [31:0] readData0 [7:0];
logic [31:0] readData1 [7:0];
logic [25:0] readTag0 [7:0];
logic [25:0] readTag1 [7:0];
logic [25:0]writTag0[7:0];
logic [25:0]writTag1[7:0];
word_t writData0[7:0];
word_t writData1[7:0];
*/
endmodule