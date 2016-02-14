
module addr32bit	// a +- b
(
	input  logic [31:0] a,
	input  logic [31:0] b,
	input  logic mode,	// 0 for + , 1 for -
	output logic [31:0] result,
	output logic vldflg,
	output logic cryflg,
	output logic ngtflg,
	output logic zroflg
);


	logic [32:0] carrys;
	genvar i;

	assign carrys[0] = mode;	// carry 1 if subtraction

	generate
		for(i = 0; i <= 31; i = i + 1)
		begin:addername
			addr1bit IX (.a(a[i]), .b(b[i] ^ mode), .cin(carrys[i]),.s(result[i]), .cout(carrys[i+1]));
		end
	endgenerate

	assign vldflg = carrys[32] ^ carrys[31];	// valid flag
	assign cryflg = mode ^ carrys[32];		// carry flag
	assign ngtflg = result[31];	// negative flag
	assign zroflg = !(1&&result);			// zero flag

endmodule
