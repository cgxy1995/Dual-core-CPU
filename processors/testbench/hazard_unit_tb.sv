/*
	hazard unit
	Mingfei Huang
	huang243@purdue.edu

*/
// mapped needs this
`include "control_hazard_alu_if.vh"
`timescale 1 ns / 1 ns


module hazard_unit_tb;
	logic CLK , nRST;
	control_hazard_alu_if chaif();
	hazard_unit HU_DUT(CLK , nRST,chaif);
	parameter PERIOD = 10;

	logic ihit;
	logic dhit;
	logic cu_dmemWEN;
	logic cu_dmemREN;
	logic halt;
	assign chaif.ihit = ihit;
	assign chaif.dhit = dhit;
	assign chaif.cu_dmemWEN = cu_dmemWEN;
	assign chaif.cu_dmemREN = cu_dmemREN;
	assign chaif.halt = halt;

	always #(PERIOD/2) CLK++;

	initial begin
		ihit = 0;
		dhit = 0;
		cu_dmemWEN = 0;
		cu_dmemREN = 0;

		nRST = 0;
		#PERIOD;
		nRST = 1;

		#PERIOD;
		ihit = 0;
		#PERIOD;
		ihit = 1;
		#PERIOD;
		ihit = 0;

		#PERIOD;
		cu_dmemREN = 1;
		#(PERIOD*4);
		dhit = 1;
		#PERIOD;
		cu_dmemREN = 0;
		cu_dmemWEN = 1;
		dhit = 1;
	end


	always@(chaif.dmemREN,chaif.dmemWEN,chaif.instEN,chaif.ilast)begin
		$display("\ntime:%g\ndmemREN:%1b\ndmemWEN:%1b\ninstEN:%1b\nilast:%1b",
			$time,chaif.dmemREN,chaif.dmemWEN,chaif.instEN,chaif.ilast);

	end
endmodule

