/*
	Mingfei Huang
	huang243@purdue.edu

	register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

	parameter PERIOD = 10;

	logic CLK = 0, nRST = 0;

	// test vars
	int v1 = 1;
	int v2 = 4721;
	int v3 = 25119;

	// clock
	always #(PERIOD/2) CLK++;

	// interface
	register_file_if rfif ();
	// DUT
`ifndef MAPPED
	register_file DUT(rfif , CLK, nRST);
`else
	register_file DUT(
		.\rfif.rdat2 (rfif.rdat2),
		.\rfif.rdat1 (rfif.rdat1),
		.\rfif.wdat (rfif.wdat),
		.\rfif.rsel2 (rfif.rsel2),
		.\rfif.rsel1 (rfif.rsel1),
		.\rfif.wsel (rfif.wsel),
		.\rfif.rWEN (rfif.rWEN),
		.\nRST (nRST),
		.\CLK (CLK)
	);
`endif

initial begin
/*      $monitor("
clk=%d
wsel=%d
wdat=%d
WEN=%d
rsel1=%d
rsel2=%d
rdat1=%d
rdat2=%d\n\n"
		,CLK
		,rfif.wsel
		,rfif.wdat
		,rfif.rWEN
		,rfif.rsel1
		,rfif.rsel2
		,rfif.rdat1
		,rfif.rdat2);*/

		$monitor("
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b
reg%d:	%d:%b"
, 00 , DUT.data[00] , DUT.data[00]
, 01 , DUT.data[01] , DUT.data[01]
, 02 , DUT.data[02] , DUT.data[02]
, 03 , DUT.data[03] , DUT.data[03]
, 04 , DUT.data[04] , DUT.data[04]
, 05 , DUT.data[05] , DUT.data[05]
, 06 , DUT.data[06] , DUT.data[06]
, 07 , DUT.data[07] , DUT.data[07]
, 08 , DUT.data[08] , DUT.data[08]
, 09 , DUT.data[09] , DUT.data[09]
, 10 , DUT.data[10] , DUT.data[10]
, 11 , DUT.data[11] , DUT.data[11]
, 12 , DUT.data[12] , DUT.data[12]
, 13 , DUT.data[13] , DUT.data[13]
, 14 , DUT.data[14] , DUT.data[14]
, 15 , DUT.data[15] , DUT.data[15]
, 16 , DUT.data[16] , DUT.data[16]
, 17 , DUT.data[17] , DUT.data[17]
, 18 , DUT.data[18] , DUT.data[18]
, 19 , DUT.data[19] , DUT.data[19]
, 20 , DUT.data[20] , DUT.data[20]
, 21 , DUT.data[21] , DUT.data[21]
, 22 , DUT.data[22] , DUT.data[22]
, 23 , DUT.data[23] , DUT.data[23]
, 24 , DUT.data[24] , DUT.data[24]
, 25 , DUT.data[25] , DUT.data[25]
, 26 , DUT.data[26] , DUT.data[26]
, 27 , DUT.data[27] , DUT.data[27]
, 28 , DUT.data[28] , DUT.data[28]
, 29 , DUT.data[29] , DUT.data[29]
, 30 , DUT.data[30] , DUT.data[30]
, 31 , DUT.data[31] , DUT.data[31]);


			$display("\n---------------reset---------------");
			nRST = 0;
			#(PERIOD/2)
			nRST = 1;

	#(PERIOD*2)
	rfif.wsel = 0;
	rfif.rWEN = 0;
	rfif.wdat = 0;
	rfif.rsel1 = 0;
	rfif.rsel2 = 0;

	$display("write to $0");
	#(PERIOD*2)// write to $0
	rfif.wsel = 0;
	rfif.rWEN = 1;
	rfif.wdat = 99;
	rfif.rsel1 = 1;
	rfif.rsel2 = 0;

	$display("write to $2");
	#(PERIOD*2)// write to $2
	rfif.wsel = 2;
	rfif.rWEN = 1;
	rfif.wdat = 99;
	rfif.rsel1 = 2;
	rfif.rsel2 = 0;

	$display("write to $17");
	#(PERIOD*2)// write to $17
	rfif.wsel = 17;
	rfif.rWEN = 1;
	rfif.wdat = 12345;
	rfif.rsel1 = 2;
	rfif.rsel2 = 17;

	$display("WEN is 0");
	#(PERIOD*2)// WEN is 0
	rfif.wsel = 31;
	rfif.rWEN = 0;
	rfif.wdat = 54321;
	rfif.rsel1 = 2;
	rfif.rsel2 = 31;
end


endmodule
