/*
	Eric Villasenor
	evillase@gmail.com

	this block holds the i and d cache
*/


// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module caches (
	input logic CLK, nRST,
		datapath_cache_if dcif,
		cache_control_if ccif
	/*output logic
      dcif_halt,
      dcif_ihit,
      dcif_imemREN,
      dcif_dhit,
      dcif_datomic,
      dcif_dmemREN,
      dcif_dmemWEN,
      dcif_flushed,
      ccif_iwait,
      ccif_dwait,
      ccif_iREN,
      ccif_dREN,
      ccif_dWEN,
      ccif_ccwait,
      ccif_ccinv,
      ccif_ccwrite,
      ccif_cctrans,
      ccif_localwrit,
      ccif_ccdirty,
      ccif_ramWEN,
      ccif_ramREN,
      //input
  //  ramstate_t ccif_ramstate,
  //  word_t ccif_ramload,
        ccif_ramstate,
        ccif_ramload,
  //  output word_t
       ccif_ramaddr,
      ccif_ramstore,

      ccif_iload,
      ccif_dload,
      dcif_dmemload,
      dcif_imemload,
      dcif_imemaddr,
      dcif_dmemstore,
      dcif_dmemaddr,
      ccif_dstore,
      ccif_iaddr,
      ccif_daddr*/
);
	// import types
	import cpu_types_pkg::word_t;

	parameter CPUID = 0;

	//word_t instr;

	// icache
	`ifndef MAPPED
		icache #(.CPUID(CPUID)) ICACHE(CLK , nRST ,dcif , ccif);
		dcache #(.CPUID(CPUID)) DCACHE(CLK , nRST , dcif, ccif);
  	`else
		icache #(.CPUID(CPUID)) ICACHE(CLK , nRST ,
		dcif_imemREN,
    dcif_imemaddr,
    dcif_ihit,
    dcif_imemload,
    ccif_iwait,
    ccif_iload,
    ccif_iREN,
    ccif_iaddr,
    );
    dcache #(.CPUID(CPUID)) DCACHE(CLK , nRST ,
    dcif_halt,
    dcif_dmemREN,
    dcif_dmemWEN,
    dcif_datomic,
    dcif_dmemstore,
    dcif_dmemaddr,
    dcif_dhit,
    dcif_dmemload,
    dcif_flushed,
    ccif_dwait,
    ccif_dload,
    ccif_ccwait,
    ccif_ccinv,
    ccif_ccsnoopaddr,
    ccif_dREN,
    ccif_dWEN,
    ccif_daddr,
    ccif_dstore,
    ccif_ccwrite,
    ccif_cctrans,
    ccif_ccdirty,
	);
	`endif

endmodule
