/*
	Mingfei Huang
	datapath testbench
*/

// cpu instructions
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
// mapped needs this
`include "register_file_if.vh"
// data path interface
`include "datapath_cache_if.vh"
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module datapath_fpga(
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [17:0] SW,
	output logic [17:0] LEDR,
	output logic [6:0] HEX7,
	output logic [6:0] HEX6,
	output logic [6:0] HEX5,
	output logic [6:0] HEX4,
	output logic [6:0] HEX3,
	output logic [6:0] HEX2,
	output logic [6:0] HEX1,
	output logic [6:0] HEX0
	);

	logic CLK , nRST;
	assign CLK = KEY[0];
	assign nRST = KEY[3];


	datapath_cache_if dpif();

	datapath DP_DUT(CLK , nRST , dpif);

	// fake stuff
	fake_imem FI_DUT(dpif);

	// not used
	assign dpif.ihit = 1'b0;
	assign dpif.dhit = 1'b0;

endmodule