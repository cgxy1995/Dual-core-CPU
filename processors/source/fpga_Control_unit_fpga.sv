// interface
`include "control_hazard_alu_if.vh"

module Control_unit_fpga (
	input logic [3:0] KEY,
	input logic [17:0] SW,
	output logic [17:0] LEDR,
	output logic [17:0] LEDG
);

	// interface
	control_hazard_alu_if chaif();

	// components
	Control_unit CU(chaif);

	assign chaif.imemload[31:14] = SW[17:0];
	assign chaif.zroflg = KEY[0];

	assign LEDG[0] = chaif.cu_rWEN;
	assign LEDG[1] = chaif.cu_dmemWEN;
	assign LEDG[2] = chaif.cu_dmemREN;
	assign LEDR[17:14] = chaif.alucode;
	assign LEDR[13:12] = chaif.wdat_sel;
	assign LEDR[11:10] = chaif.wseles;
	assign LEDR[9:8] = chaif.extmode;
	assign LEDR[7:6] = chaif.op2sel;
	assign LEDR[5] = chaif.PC4EN;
	assign LEDR[4:3] = chaif.PCsel;
	assign LEDR[2] = chaif.halt;
endmodule
