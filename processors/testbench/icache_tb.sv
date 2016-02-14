/*
	Mingfei Huang
	datapath testbench
*/

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module icache_tb;

	datapath_cache_if dcif();
	cache_control_if ccif();
	logic CLK , nRST;

	parameter PERIOD = 10;
	parameter RAM = 15;
	always #(PERIOD/2) CLK++;

	icache icdut(CLK, nRST, dcif, ccif);


	// dcif:
	/*input   imemREN, imemaddr,
	output  ihit, imemload*/
	// ccif:
	/*input   iwait, iload,
	output  iREN, iaddr*/


	initial begin
		CLK = 0;
		nRST = 0;
		dcif.imemREN = 0;
		dcif.imemaddr = 0;
		ccif.iwait = 1;
		ccif.iload = 0;
		#PERIOD;
		nRST = 1;

		#PERIOD;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h0;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;
		#PERIOD;

		ccif.iwait = 1;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h4;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;
		#PERIOD;

		ccif.iwait = 1;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h8;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;
		#PERIOD;

		ccif.iwait = 1;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h0;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;
		#PERIOD;

		ccif.iwait = 1;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h4;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;

		//if imemREN is not asserted
		ccif.iwait = 1;
		dcif.imemREN = 0;
		dcif.imemaddr = 32'h4;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'habcdef;


		ccif.iwait = 1;
		dcif.imemREN = 1;
		dcif.imemaddr = 32'h4;
		#RAM;
		ccif.iwait = 0;
		ccif.iload = 32'hdeadef;


	end
endmodule