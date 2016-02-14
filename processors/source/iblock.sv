
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module iblock (
	input	logic CLK , nRST,
	input 	logic [31:0] setData,
	input	logic [25:0] setTag,
	input	logic set,
	output	logic [31:0] readData,
	output	logic [25:0] readTag,
	output	logic readValid
);

	always_ff@(posedge CLK or negedge nRST) begin : iblock_ff
		if(~nRST)begin
			readData	<= 0;
			readTag		<= 0;
			readValid	<= 0;
		end else if(set)begin
			readData	<= setData;
			readTag		<= setTag;
			readValid	<= 1'b1;
		end
	end

endmodule




