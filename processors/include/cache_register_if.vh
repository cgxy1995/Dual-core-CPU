`ifndef CACHE_REGISTER_IF_VH
`define CACHE_REGISTER_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface cache_register_if;
	// import types
	import cpu_types_pkg::*;
	word_t rdat;
	word_t rdat0;
	word_t rdat1;
	logic [25:0] rtag0;
	logic [25:0] rtag1;
	word_t wdat;
	logic rdirty0;
	logic rdirty1;
	logic rru0;
	logic rru1;
	logic rValid0;
	logic rValid1;
	logic setsel;
	logic wdirty;
	logic wdten;
	logic wfgen;
	logic wrdsel;
	logic wru0;
	logic wru1;
	logic [25:0] wtag;
	logic wValid;
endinterface

`endif
