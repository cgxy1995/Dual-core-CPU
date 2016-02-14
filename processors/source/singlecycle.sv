/*
  Eric Villasenor
  evillase@gmail.com

  single cycle top block
  holds data path components
  and cache level
*/

module singlecycle (
  input logic CLK, nRST,
  output logic halt,
  //cache_control_if ccif,
  cpu_ram_if.cpu scif/*,
  datapath_cache_if dcif
,output logic outrValid0
,output logic outwen0
,output logic outwValid0
,output logic outwRU0*/
);

parameter PC0 = 0;

  // bus interface
  datapath_cache_if         dcif ();
  // coherence interface
  cache_control_if           ccif ();

  // map datapath
  datapath #(.PC_INIT(PC0)) DP (CLK, nRST, dcif);
  // map caches
  caches #(.CPUID(0))       CM (CLK, nRST, dcif, ccif/*
,outrValid0
,outwen0
,outwValid0
,outwRU0*/
);
  // map coherence
  memory_control            CC (CLK, nRST, ccif);

  // interface connections
  assign scif.memaddr = ccif.ramaddr;
  assign scif.memstore = ccif.ramstore;
  assign scif.memREN = ccif.ramREN;
  assign scif.memWEN = ccif.ramWEN;

  assign ccif.ramload = scif.ramload;
  assign ccif.ramstate = scif.ramstate;

  assign halt = dcif.flushed;



endmodule
