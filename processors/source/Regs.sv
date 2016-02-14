module Regs(
	input logic [31:0] wdat,
	input logic en,
	input logic CLK,
	input logic rst_n,
	output logic [31:0] data
	);
/*
	logic [31:0] reg_data;
	always_ff@(posedge CLK or negedge rst_n) begin
		if(~rst_n) begin
			reg_data <= 0;
		end else if(en) begin
			reg_data <= wdat;
		end
	end
	assign data = reg_data;
*/

//	logic [31:0] reg_data;
	always_ff@(posedge CLK or negedge rst_n) begin
		if(~rst_n) begin
			data <= 0;
		end else if(en) begin
			data <= wdat;
		end
	end


endmodule


