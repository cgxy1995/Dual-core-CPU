/*
	Eric Villasenor
	evillase@gmail.com

	all types used to make life easier.
*/
`ifndef CONTROL_SEL_PKG_VH
`define CONTROL_SEL_PKG_VH
package control_sel_pkg;

	parameter EXME = 2;
	parameter IDEX = 1;
	parameter IFID = 0;
// oprnd2_mux
	typedef enum logic [1:0] {
		OP2_RDAT 	 = 2'd0,
		OP2_SA		 = 2'd1,
		OP2_IMM 	 = 2'd2
	}oprnd2_mux_t;
// imm_extender
	typedef enum logic [1:0] {
		EXT_ZERO 	 = 2'd0,
		EXT_ONE  	 = 2'd1,
		EXT_SIGN 	 = 2'd2
	}imm_extender_t;
// wsel_select
	typedef enum logic [1:0] {
		WSEL_RT		 = 2'd0,
		WSEL_RD		 = 2'd1,
		WSEL_31		 = 2'd2
	}wsel_select_t;
// wdat_select
	typedef enum logic [1:0] {
		WDAT_ALU	 = 2'd0,
		WDAT_LUI	 = 2'd1,
		WDAT_MEM	 = 2'd2,
		WDAT_PC4	 = 2'd3
	}wdat_select_t;
// PCelse_select
	typedef enum logic [1:0] {
		PC_JR	 	 = 2'd0,
		PC_JI	 	 = 2'd1,
		PC_BEQ	 	 = 2'd2,
		PC_BNE		 = 2'd3
	}PCelse_select_t;
// just to be clear..
	typedef enum logic [31:0] {
		NOP = 0
	}NOP_t;
endpackage
`endif //CPU_TYPES_PKG_VH
