/*
	Mingfei Huang
	huang243@purdue.edu

	front and back side of pipeline registers interface
*/
`ifndef PIPELINE_LATCH_IF_VH
`define PIPELINE_LATCH_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface pipeline_front_if;

	/*	// instruction fetch - instruction decode regs
			word_t imemload_IFID , PC4_IFID;

		// instruction decode - execute
			word_t PC4_IDEX , PCelse_IDEX;   // PC stuff
			logic PC4EN_IDEX;
			word_t imemload_IDEX; // from memory
			word_t rdat1_IDEX , rdat2_IDEX;   // to register file
			logic  cu_rWEN_IDEX;
			logic [1:0] wseles_IDEX , PCsel_IDEX , wdat_sel_IDEX , extmode_IDEX , op2sel_IDEX;  // mux selects
			logic [3:0] alucode_IDEX;
			logic  halt_IDEX , cu_dmemWEN_IDEX , cu_dmemREN_IDEX;

		// execute / memory
			word_t PC4_EXME , PCelse_EXME;   // pc stuff
			logic  PC4EN_EXME;
			word_t imemload_EXME; // from memory
			word_t dmemstore_EXME , dmemaddr_EXME;  // to mem
			word_t rdat1_EXME, rdat2_EXME;    // to register file
			logic  cu_rWEN_EXME;
			logic [1:0] wseles_EXME, PCsel_EXME, wdat_sel_EXME, extmode_EXME; // mux selects
			word_t alurst_EXME;     // alu stuff
			logic  zroflg_EXME;
			logic  halt_EXME, cu_dmemWEN_EXME, cu_dmemREN_EXME;

		// memory / write back
			word_t PC4_MEWB;
			word_t imemload_MEWB, dmemload_MEWB;  // from memory
			logic  cu_rWEN_MEWB;
			logic [1:0] wseles_MEWB, wdat_sel_MEWB, extmode_MEWB; // mux selects
			word_t alurst_MEWB;     // alu stuff
			logic  halt_MEWB, cu_dmemWEN_MEWB, cu_dmemREN_MEWB , dhit_MEWB;
	*/
	logic cu_rWEN_EXME;
	logic cu_rWEN_IDEX;
	logic cu_rWEN_MEWB;
	logic halt_EXME;
	logic halt_IDEX ;
	logic halt_MEWB;
	logic PC4EN_EXME;
	logic zroflg_EXME;
	logic[3:0] alucode_IDEX;
	word_t alurst_EXME;     // alu stuff
	word_t alurst_MEWB;     // alu stuff
	logic cu_dmemREN_EXME;
	logic cu_dmemREN_IDEX;
	logic cu_dmemREN_MEWB;
	logic cu_dmemWEN_EXME;
	logic cu_dmemWEN_IDEX ;
	logic cu_dmemWEN_MEWB;
	logic dhit_MEWB;
	word_t dmemaddr_EXME;  // to mem
	word_t dmemload_MEWB;  // from memory
	word_t dmemstore_EXME ;
	logic[1:0] extmode_EXME; // mux selects
	logic[1:0] extmode_IDEX;
	logic[1:0] extmode_MEWB; // mux selects
	word_t imemload_EXME; // from memory
	word_t imemload_IDEX; // from memory
	word_t imemload_IFID ;
	word_t imemload_MEWB;
	logic[1:0] op2sel_IDEX;  // mux selects
	word_t PC4_EXME ;
	word_t PC4_IDEX ;
	word_t PC4_IFID;
	word_t PC4_MEWB;
	logic PC4EN_IDEX;
	word_t PCelse_EXME;   // pc stuff
	word_t PCelse_IDEX;   // PC stuff
	logic[1:0] PCsel_EXME;
	logic[1:0] PCsel_IDEX ;
	word_t rdat1_EXME;
	word_t rdat1_IDEX ;
	word_t rdat2_EXME;    // to register file
	word_t rdat2_IDEX;   // to register file
	logic[1:0] wdat_sel_EXME;
	logic[1:0] wdat_sel_IDEX;
	logic[1:0] wdat_sel_MEWB;
	logic[1:0] wseles_EXME;	// these three are functionally replaced by the next three
	logic[1:0] wseles_IDEX;	// these three are functionally replaced by the next three
	logic[1:0] wseles_MEWB;	// these three are functionally replaced by the next three
	logic[4:0] wsel_EXME;	// new stuff:Lab6
	logic[4:0] wsel_IDEX;	// new stuff:Lab6
	logic[4:0] wsel_MEWB;	// new stuff:Lab6
	word_t wdat_IDEX;
	word_t wdat_EXME;
	word_t wdat_MEWB;
	logic wdat_ready_IDEX;
	logic wdat_ready_EXME;
	logic wdat_ready_MEWB;
	word_t dmemstore_IMAGINARY_IDEX;
	logic dmemstore_EARLY_IDEX;
	word_t dmemstore_IMAGINARY_EXME;
	logic dmemstore_EARLY_EXME;

	logic llsc_IDEX;
	logic llsc_EXME;
	logic llsc_MEWB;

	word_t wdat_WBIM;
	word_t wsel_WBIM;
	logic cu_rWEN_WBIM;

	modport ppl(
		input
		alucode_IDEX,
		alurst_EXME,
		alurst_MEWB,
		cu_dmemREN_EXME,
		cu_dmemREN_IDEX,
		cu_dmemREN_MEWB,
		cu_dmemWEN_EXME,
		cu_dmemWEN_IDEX,
		cu_dmemWEN_MEWB,
		cu_rWEN_EXME,
		cu_rWEN_IDEX,
		cu_rWEN_MEWB,
		dhit_MEWB,
		dmemaddr_EXME,
		dmemload_MEWB,
		dmemstore_EXME,
		extmode_EXME,
		extmode_IDEX,
		extmode_MEWB,
		halt_EXME,
		halt_IDEX,
		halt_MEWB,
		imemload_EXME,
		imemload_IDEX,
		imemload_IFID,
		imemload_MEWB,
		op2sel_IDEX,
		PC4_EXME,
		PC4_IDEX,
		PC4_IFID,
		PC4_MEWB,
		PC4EN_EXME,
		PC4EN_IDEX,
		PCelse_EXME,
		PCelse_IDEX,
		PCsel_EXME,
		PCsel_IDEX,
		rdat1_EXME,
		rdat1_IDEX,
		rdat2_EXME,
		rdat2_IDEX,
		wdat_sel_EXME,
		wdat_sel_IDEX,
		wdat_sel_MEWB,
		wseles_EXME,
		wseles_IDEX,
		wseles_MEWB,
		zroflg_EXME,
		wsel_EXME,
		wsel_IDEX,
		wsel_MEWB,
		wdat_IDEX,
		wdat_EXME,
		wdat_MEWB,
		wdat_ready_IDEX,
		wdat_ready_EXME,
		wdat_ready_MEWB,
		dmemstore_IMAGINARY_IDEX,
		dmemstore_EARLY_IDEX,
		dmemstore_IMAGINARY_EXME,
		dmemstore_EARLY_EXME,
		llsc_IDEX,
		llsc_EXME,
		llsc_MEWB,
		wdat_WBIM,
		wsel_WBIM,
		cu_rWEN_WBIM
	);
endinterface


interface pipeline_back_if;

	logic cu_rWEN_EXME;
	logic cu_rWEN_IDEX;
	logic cu_rWEN_MEWB;
	logic halt_EXME;
	logic halt_IDEX;
	logic halt_MEWB;
	logic[1:0] op2sel_IDEX;
	logic PC4EN_EXME;
	logic zroflg_EXME;
	logic[3:0] alucode_IDEX;
	word_t alurst_EXME;
	word_t alurst_MEWB;
	logic cu_dmemREN_EXME;
	logic cu_dmemREN_IDEX;
	logic cu_dmemREN_MEWB;
	logic cu_dmemWEN_EXME;
	logic cu_dmemWEN_IDEX;
	logic cu_dmemWEN_MEWB;
	logic dhit_MEWB;
	word_t dmemaddr_EXME;
	word_t dmemload_MEWB;
	word_t dmemstore_EXME;
	logic[1:0] extmode_EXME;
	logic[1:0] extmode_IDEX;
	logic[1:0] extmode_MEWB;
	word_t imemload_EXME;
	word_t imemload_IDEX;
	word_t imemload_IFID;
	word_t imemload_MEWB;
	word_t PC4_EXME;
	word_t PC4_IDEX;
	word_t PC4_IFID;
	word_t PC4_MEWB;
	logic PC4EN_IDEX;
	word_t PCelse_EXME;
	word_t PCelse_IDEX;
	logic[1:0] PCsel_EXME;
	logic[1:0] PCsel_IDEX;
	word_t rdat1_EXME;
	word_t rdat1_IDEX;
	word_t rdat2_EXME;
	word_t rdat2_IDEX;
	logic[1:0] wdat_sel_EXME;
	logic[1:0] wdat_sel_IDEX;
	logic[1:0] wdat_sel_MEWB;
	logic[1:0] wseles_EXME;
	logic[1:0] wseles_IDEX;
	logic[1:0] wseles_MEWB;
	logic[4:0] wsel_EXME;	// new stuff:Lab6
	logic[4:0] wsel_IDEX;	// new stuff:Lab6
	logic[4:0] wsel_MEWB;	// new stuff:Lab6
	word_t wdat_IDEX;
	word_t wdat_EXME;
	word_t wdat_MEWB;
	logic wdat_ready_IDEX;
	logic wdat_ready_EXME;
	logic wdat_ready_MEWB;
	word_t dmemstore_IMAGINARY_IDEX;
	logic dmemstore_EARLY_IDEX;
	word_t dmemstore_IMAGINARY_EXME;
	logic dmemstore_EARLY_EXME;

	logic llsc_IDEX;
	logic llsc_EXME;
	logic llsc_MEWB;

	word_t wdat_WBIM;
	word_t wsel_WBIM;
	logic cu_rWEN_WBIM;

	modport ppl(
		output
		alucode_IDEX,
		alurst_EXME,
		alurst_MEWB,
		cu_dmemREN_EXME,
		cu_dmemREN_IDEX,
		cu_dmemREN_MEWB,
		cu_dmemWEN_EXME,
		cu_dmemWEN_IDEX,
		cu_dmemWEN_MEWB,
		cu_rWEN_EXME,
		cu_rWEN_IDEX,
		cu_rWEN_MEWB,
		dhit_MEWB,
		dmemaddr_EXME,
		dmemload_MEWB,
		dmemstore_EXME,
		extmode_EXME,
		extmode_IDEX,
		extmode_MEWB,
		halt_EXME,
		halt_IDEX,
		halt_MEWB,
		imemload_EXME,
		imemload_IDEX,
		imemload_IFID,
		imemload_MEWB,
		op2sel_IDEX,
		PC4_EXME,
		PC4_IDEX,
		PC4_IFID,
		PC4_MEWB,
		PC4EN_EXME,
		PC4EN_IDEX,
		PCelse_EXME,
		PCelse_IDEX,
		PCsel_EXME,
		PCsel_IDEX,
		rdat1_EXME,
		rdat1_IDEX,
		rdat2_EXME,
		rdat2_IDEX,
		wdat_sel_EXME,
		wdat_sel_IDEX,
		wdat_sel_MEWB,
		wseles_EXME,
		wseles_IDEX,
		wseles_MEWB,
		zroflg_EXME,
		wsel_EXME,
		wsel_IDEX,
		wsel_MEWB,
		wdat_IDEX,
		wdat_EXME,
		wdat_MEWB,
		wdat_ready_IDEX,
		wdat_ready_EXME,
		wdat_ready_MEWB,
		dmemstore_IMAGINARY_IDEX,
		dmemstore_EARLY_IDEX,
		dmemstore_IMAGINARY_EXME,
		dmemstore_EARLY_EXME,
		llsc_IDEX,
		llsc_EXME,
		llsc_MEWB,
		wdat_WBIM,
		wsel_WBIM,
		cu_rWEN_WBIM
	);
endinterface

`endif //PIPELINE_LATCH_IF_VH
