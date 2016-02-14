// interface
`include "control_hazard_alu_if.vh"

module hazard_unit_fpga (
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [17:0] SW,
	output logic [17:0] LEDR,
	output logic [17:0] LEDG
);

	// interface
	control_hazard_alu_if chaif();

	// components
	hazard_unit HU(CLOCK_50 , SW[1] , chaif);

	assign chaif.ihit			= SW[0];
	assign chaif.dhit			= SW[1];
	assign chaif.cu_dmemWEN		= SW[2];
	assign chaif.cu_dmemREN		= SW[3];
	assign chaif.halt			= SW[4];

	assign LEDR[10] = chaif.imemREN;
	assign LEDR[11] = chaif.dmemREN;
	assign LEDR[12] = chaif.dmemWEN;
	assign LEDR[13] = chaif.instEN;
	assign LEDR[14] = chaif.ilast;
endmodule
