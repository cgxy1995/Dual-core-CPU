// mapped needs this
`include "control_hazard_alu_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module Alu(
	control_hazard_alu_if.alu chaif
	);

	logic [31:0] rstand;	// and
	logic [31:0] rstorr;	// or
	logic [31:0] rstxor;	// xor
	logic [31:0] rstnor;	// nor
	logic [31:0] rstadr;	// add / subtract

	assign rstand = chaif.oprnd1 & chaif.oprnd2;	// and
	assign rstorr = chaif.oprnd1 | chaif.oprnd2;	// or
	assign rstxor = (~rstand) & rstorr;	// xor
	assign rstnor = ~rstorr;	// nor

	/*logic vldflg;	// valid flag*/
	/*logic cryflg;	// carry flag*/
	/*logic ngtflg;	// negative flag*/
	/*logic zroflg;	// zero flag*/

	logic unsign;
	assign unsign = (chaif.alucode_IDEX==ALU_SLTU);	// unsigned operation

	addr32bit Adder // a +- b , oprnd1 +- oprnd2
	(
		.a(chaif.oprnd1),
		.b(chaif.oprnd2),
		.mode((chaif.alucode_IDEX==ALU_SUB) || (chaif.alucode_IDEX==ALU_SLT) || (chaif.alucode_IDEX==ALU_SLTU)),	// 0 for + , 1 for -
		.result(rstadr),
		.vldflg(chaif.vldflg),
		.cryflg(chaif.cryflg),
		.ngtflg(chaif.ngtflg),
		.zroflg(chaif.zroflg)
	);

	always_comb begin : alucode_IDEX_decoder
		casez(chaif.alucode_IDEX)
			default:
				chaif.alurst = chaif.oprnd1;
			ALU_SLL:    // chaif.oprnd1 is GPR[rt],chaif.oprnd2 is sa
				casez(chaif.oprnd2)
					default:chaif.alurst=chaif.oprnd1;
					00:chaif.alurst= chaif.oprnd1[31 : 0];
					01:chaif.alurst={chaif.oprnd1[30 : 0] , 01'b0};
					02:chaif.alurst={chaif.oprnd1[29 : 0] , 02'b0};
					03:chaif.alurst={chaif.oprnd1[28 : 0] , 03'b0};
					04:chaif.alurst={chaif.oprnd1[27 : 0] , 04'b0};
					05:chaif.alurst={chaif.oprnd1[26 : 0] , 05'b0};
					06:chaif.alurst={chaif.oprnd1[25 : 0] , 06'b0};
					07:chaif.alurst={chaif.oprnd1[24 : 0] , 07'b0};
					08:chaif.alurst={chaif.oprnd1[23 : 0] , 08'b0};
					09:chaif.alurst={chaif.oprnd1[22 : 0] , 09'b0};
					10:chaif.alurst={chaif.oprnd1[21 : 0] , 10'b0};
					11:chaif.alurst={chaif.oprnd1[20 : 0] , 11'b0};
					12:chaif.alurst={chaif.oprnd1[19 : 0] , 12'b0};
					13:chaif.alurst={chaif.oprnd1[18 : 0] , 13'b0};
					14:chaif.alurst={chaif.oprnd1[17 : 0] , 14'b0};
					15:chaif.alurst={chaif.oprnd1[16 : 0] , 15'b0};
					16:chaif.alurst={chaif.oprnd1[15 : 0] , 16'b0};
					17:chaif.alurst={chaif.oprnd1[14 : 0] , 17'b0};
					18:chaif.alurst={chaif.oprnd1[13 : 0] , 18'b0};
					19:chaif.alurst={chaif.oprnd1[12 : 0] , 19'b0};
					20:chaif.alurst={chaif.oprnd1[11 : 0] , 20'b0};
					21:chaif.alurst={chaif.oprnd1[10 : 0] , 21'b0};
					22:chaif.alurst={chaif.oprnd1[09 : 0] , 22'b0};
					23:chaif.alurst={chaif.oprnd1[08 : 0] , 23'b0};
					24:chaif.alurst={chaif.oprnd1[07 : 0] , 24'b0};
					25:chaif.alurst={chaif.oprnd1[06 : 0] , 25'b0};
					26:chaif.alurst={chaif.oprnd1[05 : 0] , 26'b0};
					27:chaif.alurst={chaif.oprnd1[04 : 0] , 27'b0};
					28:chaif.alurst={chaif.oprnd1[03 : 0] , 28'b0};
					29:chaif.alurst={chaif.oprnd1[02 : 0] , 29'b0};
					30:chaif.alurst={chaif.oprnd1[01 : 0] , 30'b0};
					31:chaif.alurst={chaif.oprnd1[00 : 0] , 31'b0};
				endcase

			ALU_SRL:    // chaif.oprnd1 is GPR[rt],chaif.oprnd2 is sa
				casez(chaif.oprnd2)
					default:chaif.alurst=chaif.oprnd1;
					//00:chaif.alurst=chaif.oprnd1[31 : 0];
					01:chaif.alurst={01'b0 , chaif.oprnd1[31 : 01]};
					02:chaif.alurst={02'b0 , chaif.oprnd1[31 : 02]};
					03:chaif.alurst={03'b0 , chaif.oprnd1[31 : 03]};
					04:chaif.alurst={04'b0 , chaif.oprnd1[31 : 04]};
					05:chaif.alurst={05'b0 , chaif.oprnd1[31 : 05]};
					06:chaif.alurst={06'b0 , chaif.oprnd1[31 : 06]};
					07:chaif.alurst={07'b0 , chaif.oprnd1[31 : 07]};
					08:chaif.alurst={08'b0 , chaif.oprnd1[31 : 08]};
					09:chaif.alurst={09'b0 , chaif.oprnd1[31 : 09]};
					10:chaif.alurst={10'b0 , chaif.oprnd1[31 : 10]};
					11:chaif.alurst={11'b0 , chaif.oprnd1[31 : 11]};
					12:chaif.alurst={12'b0 , chaif.oprnd1[31 : 12]};
					13:chaif.alurst={13'b0 , chaif.oprnd1[31 : 13]};
					14:chaif.alurst={14'b0 , chaif.oprnd1[31 : 14]};
					15:chaif.alurst={15'b0 , chaif.oprnd1[31 : 15]};
					16:chaif.alurst={16'b0 , chaif.oprnd1[31 : 16]};
					17:chaif.alurst={17'b0 , chaif.oprnd1[31 : 17]};
					18:chaif.alurst={18'b0 , chaif.oprnd1[31 : 18]};
					19:chaif.alurst={19'b0 , chaif.oprnd1[31 : 19]};
					20:chaif.alurst={20'b0 , chaif.oprnd1[31 : 20]};
					21:chaif.alurst={21'b0 , chaif.oprnd1[31 : 21]};
					22:chaif.alurst={22'b0 , chaif.oprnd1[31 : 22]};
					23:chaif.alurst={23'b0 , chaif.oprnd1[31 : 23]};
					24:chaif.alurst={24'b0 , chaif.oprnd1[31 : 24]};
					25:chaif.alurst={25'b0 , chaif.oprnd1[31 : 25]};
					26:chaif.alurst={26'b0 , chaif.oprnd1[31 : 26]};
					27:chaif.alurst={27'b0 , chaif.oprnd1[31 : 27]};
					28:chaif.alurst={28'b0 , chaif.oprnd1[31 : 28]};
					29:chaif.alurst={29'b0 , chaif.oprnd1[31 : 29]};
					30:chaif.alurst={30'b0 , chaif.oprnd1[31 : 30]};
					31:chaif.alurst={31'b0 , chaif.oprnd1[31 : 31]};
				endcase

			ALU_AND:
				chaif.alurst = rstand;
			ALU_OR:
				chaif.alurst = rstorr;
			ALU_XOR:
				chaif.alurst = rstxor;
			ALU_NOR:
				chaif.alurst = rstnor;
			ALU_ADD:
				chaif.alurst = rstadr;
			ALU_SUB:
				chaif.alurst = rstadr;
			ALU_SLT:
				chaif.alurst = chaif.ngtflg ^ chaif.vldflg;
			ALU_SLTU:
				chaif.alurst = {31'b0 , (chaif.ngtflg | ((~chaif.vldflg)) & (~chaif.ngtflg)) & chaif.cryflg & (~chaif.zroflg)};		// truth table
		endcase
	end


endmodule