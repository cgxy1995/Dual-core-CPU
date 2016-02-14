/*
	coherence control testbench
*/
// cpu instructions
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
`include "cache_control_if.vh"
`timescale 1 ns / 1 ns

module memory_control_tb;

	logic CLK , nRST;
	cache_control_if ccif();
	memory_control cc(CLK, nRST,ccif);
	parameter PERIOD = 20;

	always #(PERIOD/2) CLK++;


/*
	// arbitration
	logic   [CPUS-1:0]       iwait, dwait, iREN, dREN, dWEN;
	word_t  [CPUS-1:0]       iload, dload, dstore;
	word_t  [CPUS-1:0]       iaddr, daddr;
	logic   [CPUS-1:0]      ccwait, ccinv;
	logic   [CPUS-1:0]      ccwrite, cctrans;
	word_t  [CPUS-1:0]      ccsnoopaddr;

  logic [1:0]localwrit;

	// ram side
	logic                   ramWEN, ramREN;
	ramstate_t              ramstate;
	word_t                  ramaddr, ramstore, ramload;

*/
	initial begin
		nRST = 0;
		CLK = 1;
		#PERIOD;
		nRST = 1;
		ccif.iREN[0] = 0;
		ccif.iREN[1] = 0;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;

		#PERIOD;
		ccif.iREN[0] = 1;
		ccif.iREN[1] = 1;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.iaddr[0] = 32'h0;
		ccif.iaddr[1] = 32'h200;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;
		#PERIOD;
		ccif.ramstate = BUSY;
		#(PERIOD*2);
		ccif.ramstate = ACCESS;
		ccif.ramload = 32'habcdef;
		#PERIOD;
		ccif.dREN[0] = 1;
		ccif.ramstate = FREE;
		ccif.ramload = 32'hx;
		#PERIOD;
		ccif.ramstate = BUSY;
		#(PERIOD*2);
		ccif.ramstate = ACCESS;
		ccif.ramload = 32'hfedcba;
		#PERIOD;
		ccif.ramstate = FREE;
		ccif.ccidrty = 3;
		#PERIOD;
		ccif.ramstate = FREE;
		#PERIOD;
		ccif.ramstate = BUSY;
		ccif.ramload = 32'hx;
		#(PERIOD*2);
		ccif.ramstate = ACCESS;
		ccif.ramload = 32'heebbda;
		#PERIOD;
		ccif.dREN = 0;
		ccif.ramstate = FREE;
		#PERIOD;
		ccif.dWEN[0] = 1;
		#PERIOD;
		ccif.ramstate = BUSY;
		#PERIOD;
		ccif.ramstate = ACCESS;
		#PERIOD;
		ccif.ramstate = FREE;
		#PERIOD;
		ccif.ramstate = BUSY;
		#PERIOD;
		ccif.ramstate = ACCESS;
		#PERIOD;
		ccif.ramstate = FREE;
		ccif.dWEN[0] = 0;
		#PERIOD;



/*

		#PERIOD;
		ccif.iREN[0] = 0;
		ccif.iREN[1] = 0;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;

		#PERIOD;
		ccif.iREN[0] = 0;
		ccif.iREN[1] = 0;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;

		#PERIOD;
		ccif.iREN[0] = 0;
		ccif.iREN[1] = 0;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;

		#PERIOD;
		ccif.iREN[0] = 0;
		ccif.iREN[1] = 0;
		ccif.dREN[0] = 0;
		ccif.dREN[1] = 0;
		ccif.dWEN[0] = 0;
		ccif.dWEN[1] = 0;
		ccif.localwrit[0] = 0;
		ccif.localwrit[1] = 0;
		ccif.ramstate = FREE;



*/
	end

endmodule