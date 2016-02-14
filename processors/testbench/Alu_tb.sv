/*
	Eric Villasenor
	evillase@gmail.com

	register file test bench
*/

// cpu instructions
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

// mapped needs this
`include "control_hazard_alu_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module Alu_tb;

	control_hazard_alu_if chaif();
	logic [31:0] tb_oprnd1;
	logic [31:0] tb_oprnd2;
	logic [3:0] tb_opcode;
	logic [31:0] tb_result;

	assign chaif.oprnd1 = tb_oprnd1;
	assign chaif.oprnd2 = tb_oprnd2;
	assign chaif.alucode = tb_opcode;
	assign tb_result = chaif.alurst;

	int casen;
	Alu DUT(chaif);

	string spec;

	task printmsg (input [3:0] spe);
		case(spe)
			4'b0000:spec="ALU_SLL";
			4'b0001:spec="ALU_SRL";
			4'b0010:spec="ALU_ADD";
			4'b0011:spec="ALU_SUB";
			4'b0100:spec="ALU_AND";
			4'b0101:spec="ALU_OR";
			4'b0110:spec="ALU_XOR";
			4'b0111:spec="ALU_NOR";
			4'b1010:spec="ALU_SLT";
			4'b1011:spec="ALU_SLTU";
			default:begin
				$sformat(spec, "%4b", spe);
			end
		endcase	// alucode print
	endtask

	initial begin

		$monitor("==================\ncasen:%2d\nop:%s\noprnd1:%b\noprnd2:%b\nvldflg:%b\ncryflg:%b\nngtflg:%b\nzroflg:%b\n==================\n	"
		,casen
		,spec
		,tb_opcode
		,tb_oprnd1
		,tb_oprnd2
		,chaif.vldflg
		,chaif.cryflg
		,chaif.ngtflg
		,chaif.zroflg);


		/*
		testcase 1:
			testing function SLL
			actual operation: result=oprnd1<<oprnd2
			expected output:
		*/
		casen=1;
		tb_opcode = ALU_SLL;
		tb_oprnd1 = 32'b11100011111111110001111111111110;
		tb_oprnd2 = 10;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 2:
			testing function SRL
			actual operation: result=oprnd1>>oprnd2
			expected output:
		*/
		casen=2;
		tb_opcode = ALU_SRL;
		tb_oprnd1 = 32'b11100011111010110001111111111110;
		tb_oprnd2 = 10;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 3:
			testing function ADD
			actual operation: result=oprnd1+oprnd2
			expected output:
		*/
		casen=3;
		tb_opcode = ALU_ADD;
		tb_oprnd1 = 12345;
		tb_oprnd2 = 6789;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 4:
			testing function SUB
			actual operation: result=oprnd1-oprnd2
			expected output:
		*/
		casen=4;
		tb_opcode = ALU_SUB;
		tb_oprnd1 = 23456;
		tb_oprnd2 = 543;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 5:
			testing function AND
			actual operation: result=oprnd1&oprnd2
			expected output:
		*/
		casen=5;
		tb_opcode = ALU_AND;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 6:
			testing function OR
			actual operation: result=oprnd1|oprnd2
			expected output:
		*/
		casen=6;
		tb_opcode = ALU_OR;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 7:
			testing function XOR
			actual operation: result=oprnd1^oprnd2
			expected output:
		*/
		casen=7;
		tb_opcode = ALU_XOR;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 8:
			testing function NOR
			actual operation: result=~(oprnd1|oprnd2)
			expected output:
		*/
		casen=8;
		tb_opcode = ALU_NOR;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 9:
			testing function SLT
			actual operation: result=oprnd1<oprnd2
			expected output:1
		*/
		casen=9;
		tb_opcode = ALU_SLT;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 10:
			testing function SLT
			actual operation: result=oprnd1<oprnd2
			expected output:0
		*/
		casen=10;
		tb_opcode = ALU_SLT;
		tb_oprnd1 = 32'b01000110011110111000011001001011;
		tb_oprnd2 = 32'b10101011110010001101000101101110;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 11:
			testing function SLT
			actual operation: result=oprnd1<oprnd2
			expected output:0
		*/
		casen=11;
		tb_opcode = ALU_SLT;
		tb_oprnd1 = 32'b0;
		tb_oprnd2 = '1;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 12:
			testing function SLTU
			actual operation: result=(unsigned)oprnd1<oprnd2
			expected output:0
		*/
		casen=12;
		tb_opcode = ALU_SLTU;
		tb_oprnd1 = 32'b10101011110010001101000101101110;
		tb_oprnd2 = 32'b01000110011110111000011001001011;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 13:
			testing function SLTU
			actual operation: result=(unsigned)oprnd1<oprnd2
			expected output:1
		*/
		casen=13;
		tb_opcode = ALU_SLTU;
		tb_oprnd1 = 32'b01000110011110111000011001001011;
		tb_oprnd2 = 32'b10101011110010001101000101101110;
		#(10);
		printmsg (tb_opcode);
		/*
		testcase 14:
			testing function SLTU
			actual operation: result=(unsigned)oprnd1<oprnd2
			expected output:1
		*/
		casen=14;
		tb_opcode = ALU_SLTU;
		tb_oprnd1 = 32'b0;
		tb_oprnd2 = '1;
		#(10);
		printmsg (tb_opcode);
	end
endmodule