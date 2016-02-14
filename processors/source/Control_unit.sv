
// cpu instructions
`include "cpu_types_pkg.vh"

// mapped needs this
`include "control_hazard_alu_if.vh"

// control signal selects
`include "control_sel_pkg.vh"
import control_sel_pkg::*;
import cpu_types_pkg::*;
module Control_unit(control_hazard_alu_if.cu chaif);

logic [5:0] opcode;
logic [5:0] rcode;

assign opcode		 = chaif.imemload[31:26];
assign rcode		 = chaif.imemload[5:0];

// instruction decode
	always_comb begin
		chaif.halt			= 0;
		chaif.PC4EN			= 1;
		chaif.cu_rWEN		= 'd0;
		chaif.PCsel			= 'dx;
		chaif.cu_dmemREN_IFID	= 'd0;
		chaif.cu_dmemWEN_IFID	= 'd0;
		chaif.alucode		= 'dx;
		chaif.op2sel		= 'dx;
		chaif.extmode		= 'dx;
		chaif.wseles		= 0;
		chaif.wdat_sel		= 'dx;
		chaif.llsc = 0;
		casez(opcode)
		// alu r type instructions
		RTYPE:begin
			chaif.halt			= 0;
			chaif.PC4EN			= 1;
			chaif.cu_rWEN		= 'd0;
			chaif.alucode		= 'dx;
			chaif.cu_dmemREN_IFID	= 'd0;
			chaif.cu_dmemWEN_IFID	= 'd0;
			chaif.op2sel		= 'dx;
			chaif.extmode		= 'dx;
			chaif.wseles		= 0;
			chaif.wdat_sel		= 'dx;
			chaif.PCsel			= 'dx;
			casez(rcode)
				SLL:begin		// GPR[rd] ← GPR[rs] << sa , // oprnd1 is GPR[rs],oprnd2 is sa
					chaif.alucode = ALU_SLL;
					chaif.op2sel = OP2_SA;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				SRL:begin		// GPR[rd] ← GPR[rs] >> sa , // oprnd1 is GPR[rs],oprnd2 is sa
					chaif.alucode = ALU_SRL;
					chaif.op2sel = OP2_SA;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				JR:begin
					chaif.PC4EN = 0;
					chaif.PCsel = PC_JR;
				end
				ADDU:begin 		// GPR[rd] ← GPR[rs] + GPR[rt]
					chaif.alucode = ALU_ADD;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				SUBU:begin		// GPR[rd] ← GPR[rs] − GPR[rt] , oprnd1 +- oprnd2
					chaif.alucode = ALU_SUB;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				AND:begin		// GPR[rd] ← GPR[rs] and GPR[rt]
					chaif.alucode = ALU_AND;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				OR:begin
					chaif.alucode = ALU_OR;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				XOR:begin		// GPR[rd] ← GPR[rs] XOR GPR[rt]
					chaif.alucode = ALU_XOR;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				NOR:begin		// GPR[rd] ← GPR[rs] nor GPR[rt]
					chaif.alucode = ALU_NOR;
					chaif.op2sel = OP2_RDAT;

					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				SLT:begin		// GPR[rd] ← (GPR[rs] < GPR[rt]) , oprnd1 < oprnd2
					chaif.alucode = ALU_SLT;
					chaif.op2sel = OP2_RDAT;

					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				SLTU:begin		// GPR[rd] ← (GPR[rs] < GPR[rt])
					chaif.alucode = ALU_SLTU;
					chaif.op2sel = OP2_RDAT;
					chaif.wseles = WSEL_RD;
					chaif.wdat_sel = WDAT_ALU;
					chaif.cu_rWEN = 1;
				end
				default:begin
					chaif.halt = 0;
					chaif.PC4EN		 = 1;
					chaif.cu_rWEN		 = 'd0;
					chaif.alucode	 = 'dx;
					chaif.cu_dmemREN_IFID	 = 'd0;
					chaif.cu_dmemWEN_IFID	 = 'd0;
					chaif.op2sel		 = 'dx;
					chaif.extmode	 = 'dx;
					chaif.wseles		 = 0;
					chaif.wdat_sel	 = 'dx;
					chaif.PCsel		 = 'dx;
				end
			endcase
		end
		// November 3 add llsc inst
			LL:begin	// same as lw plus rmwbit<=1
				chaif.alucode = ALU_ADD;
				chaif.op2sel = OP2_IMM;
				chaif.wdat_sel = WDAT_MEM;
				chaif.extmode = EXT_SIGN;
				chaif.cu_rWEN = 1;
				chaif.cu_dmemREN_IFID = 1;
				chaif.wseles = WSEL_RT;
				chaif.llsc = 1;
			end
			SC:begin
				chaif.llsc = 1;
				chaif.alucode = ALU_ADD;
				chaif.extmode = EXT_SIGN;
				chaif.op2sel = OP2_IMM;
				chaif.cu_dmemWEN_IFID = 1;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_MEM;
			end
		// not alu insts
			SW:begin
				chaif.alucode = ALU_ADD;
				chaif.extmode = EXT_SIGN;
				chaif.op2sel = OP2_IMM;
				chaif.cu_dmemWEN_IFID = 1;
			end
			LW:begin
				chaif.alucode = ALU_ADD;
				chaif.op2sel = OP2_IMM;
				chaif.wdat_sel = WDAT_MEM;
				chaif.extmode = EXT_SIGN;
				chaif.cu_rWEN = 1;
				chaif.cu_dmemREN_IFID = 1;
				chaif.wseles = WSEL_RT;
			end
			LUI:begin		// GPR[rt] ← immediate || 0*16
				chaif.wseles = WSEL_RT;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_LUI;
			end
			J:begin
				chaif.PCsel = PC_JI;
				chaif.PC4EN = 0;
			end
			JAL:begin		// R[31] <= npc; PC <= JumpAddr
				chaif.PCsel = PC_JI;
				chaif.PC4EN = 0;
				chaif.wseles = WSEL_31;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_PC4;
			end
		// alu i type
			ANDI:begin		// GPR[rt] ← GPR[rs] AND immediate
				chaif.op2sel = OP2_IMM;
				chaif.alucode = ALU_AND;
				chaif.extmode = EXT_ZERO;
				chaif.wseles = WSEL_RT;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_ALU;
			end
			ORI:begin		// GPR[rt] ← GPR[rs] or immediate
				chaif.op2sel = OP2_IMM;
				chaif.alucode = ALU_OR;
				chaif.extmode = EXT_ZERO;
				chaif.wseles = WSEL_RT;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_ALU;
			end
			XORI:begin		// R[rt] <= R[rs] XOR ZeroExtImm
				chaif.op2sel = OP2_IMM;

				chaif.alucode = ALU_XOR;
				chaif.extmode = EXT_ZERO;
				chaif.wseles = WSEL_RT;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_ALU;
			end
			ADDIU:begin		// GPR[rt] ← GPR[rs] + sign_extend(immediate)
				chaif.op2sel = OP2_IMM;
				chaif.alucode = ALU_ADD;
				chaif.wseles = WSEL_RT;
				chaif.cu_rWEN = 1;
				chaif.wdat_sel = WDAT_ALU;
				chaif.extmode = EXT_SIGN;
			end
			BEQ:begin		// PC <= (R[rs] == R[rt]) ? npc+BranchAddr : npc

				//chaif.op2sel = OP2_RDAT;
				//chaif.alucode = ALU_SUB;
				//if(chaif.zroflg)begin
					chaif.PC4EN = 0;
					chaif.PCsel = PC_BEQ;
					chaif.extmode = EXT_SIGN;
				//end else begin
				//	chaif.PC4EN = 1;
				//end
			end
			BNE:begin		// PC <= (R[rs] != R[rt]) ? npc+BranchAddr : npc
				//chaif.op2sel = OP2_RDAT;	// all these stuff moved to datapath(ID stage instead of EX stage)
				//chaif.alucode = ALU_SUB;
				//if(!chaif.zroflg)begin
					chaif.PC4EN = 0;
					chaif.PCsel = PC_BNE;
					chaif.extmode = EXT_SIGN;
				//end else begin
				//	chaif.PC4EN = 1;
				//end
			end
			SLTI:begin		// GPR[rt] ← (GPR[rs] < imm) , oprnd1 < oprnd2
				chaif.op2sel = OP2_IMM;
				chaif.extmode = EXT_SIGN;
				chaif.alucode = ALU_SLT;
				chaif.wseles = WSEL_RT;
				chaif.wdat_sel = WDAT_ALU;
				chaif.cu_rWEN = 1;
			end
			SLTIU:begin		// GPR[rt] ← (GPR[rs] < GPR[rt]) , oprnd1 < oprnd2
				chaif.op2sel = OP2_IMM;
				chaif.extmode = EXT_SIGN;
				chaif.alucode = ALU_SLTU;
				chaif.wseles = WSEL_RT;
				chaif.wdat_sel = WDAT_ALU;
				chaif.cu_rWEN = 1;
			end
			HALT:begin		// trapped
				chaif.PC4EN = 0;
				chaif.halt = 1;
			end
			default:begin
				chaif.halt = 0;
				chaif.PC4EN		 = 1;
				chaif.cu_rWEN		 = 'd0;
				chaif.alucode	 = 'dx;
				chaif.cu_dmemREN_IFID	 = 'd0;
				chaif.cu_dmemWEN_IFID	 = 'd0;
				chaif.op2sel	 	 = 'dx;
				chaif.extmode	 = 'dx;
				chaif.wseles		 = 0;
				chaif.wdat_sel	 = 'dx;
				chaif.PCsel		 = 'dx;
			end
		endcase
	end
endmodule