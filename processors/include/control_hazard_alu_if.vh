/*
	Mingfei Huang

	Control unit
	Hazard unit
	Alu

	CHA interface
*/

`ifndef CONTROL_HAZARD_ALU_if
`define CONTROL_HAZARD_ALU_if

// all types
`include "cpu_types_pkg.vh"

interface control_hazard_alu_if;
	// import types
	import cpu_types_pkg::*;

	regbits_t wsel_IFID;	// datapath local

	logic     rWEN;		// register write enable
	logic 	  cu_rWEN;
	regbits_t wsel, rsel1, rsel2;
	word_t    wdat, rdat1, rdat2;

	word_t inst;	// one line of instruction read from memory by PC
	word_t PCelse;
	//word_t PC;
	logic dmemREN;
	logic dmemWEN;
	logic cu_dmemREN_IFID;
	logic cu_dmemWEN_IFID;
	logic cu_dmemWEN_EXME  , cu_dmemREN_EXME;
	/*
	word_t dmemstore;
	word_t dmemaddr;
	word_t dmemload;
	word_t PCnxt;*/

	word_t imemload;
	//alu part
	word_t oprnd1 , oprnd2 , alurst;
	logic [3:0] alucode , alucode_IDEX;
	logic vldflg , cryflg , ngtflg , zroflg;
	logic PC4EN;
	logic [1:0] op2sel;
	logic [1:0] extmode;
	logic [1:0] wseles;
	logic [1:0] wdat_sel;
	logic [1:0] PCsel;
	logic ilast , dfin , dlast;

	logic llsc;

	modport alu(
		input oprnd1 , oprnd2 , alucode_IDEX,
		output alurst , vldflg , cryflg , ngtflg , zroflg
	);

	// register file ports
	modport rf (
		input   rWEN, wsel, rsel1, rsel2, wdat,
		output  rdat1, rdat2
	);

	logic ihit , dhit , halt , halt_MEWB , imemREN , instEN;

	// control unit ports
	modport cu(
		input inst,								// from memory
		zroflg,							 		// alu flags
		imemload,
		output
		cu_rWEN,									//	 to register file
		alucode,								// to alu
		cu_dmemREN_IFID, cu_dmemWEN_IFID,						// to memory enables
		op2sel,extmode,wseles,wdat_sel,			// source selects
		PC4EN , PCsel,
		halt,
		llsc
	);

	// hazard unit
	modport hu(
		input ihit , dhit, cu_dmemWEN_EXME  , cu_dmemREN_EXME, halt_MEWB,
		output imemREN, dmemREN, dmemWEN , instEN , ilast , dfin , dlast
	);
	word_t PC;
	// fake inst mem
	modport fi(
		input PC,
		output imemload
	);
	word_t PC4;
	modport pipeline_latch(
		input PC4
	);

endinterface

`endif













