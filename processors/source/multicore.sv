/*
  Eric Villasenor
  evillase@gmail.com

  multicoretop block
  holds data path components, cache level
  and coherence
*/

`include "cpu_ram_if.vh"
module multicore (
  input logic CLK, nRST,
  output logic halt,
  cpu_ram_if.cpu scif
);

parameter PC0 = 0;
parameter PC1 = 'h200;

  // bus interface
  datapath_cache_if         dcif0 ();
  datapath_cache_if         dcif1 ();
  // coherence interface
  cache_control_if           ccif ();

  // map datapath
  datapath #(.PC_INIT(PC0)) DP0 (CLK, nRST, dcif0);
  datapath #(.PC_INIT(PC1)) DP1 (CLK, nRST, dcif1);


    icache #(.CPUID(0)) ICACHE0(CLK , nRST ,dcif0 , ccif.iwait[0], ccif.iload[0],ccif.iREN[0], ccif.iaddr[0]);
    dcache #(.CPUID(0)) DCACHE0(CLK , nRST ,dcif0,
      ccif.dwait[0],
      ccif.dload[0],
      ccif.ccwait[0],
      ccif.ccinv[0],
      ccif.ccsnoopaddr[0],
      ccif.dREN[0],
      ccif.dWEN[0],
      ccif.daddr[0],
      ccif.dstore[0],
      ccif.ccwrite[0],
      ccif.cctrans[0],
      ccif.ccdirty[0]
      );
    icache #(.CPUID(1)) ICACHE1(CLK , nRST ,dcif1 , ccif.iwait[1], ccif.iload[1],ccif.iREN[1], ccif.iaddr[1]);
    dcache #(.CPUID(1)) DCACHE1(CLK , nRST ,dcif1,
      ccif.dwait[1],
      ccif.dload[1],
      ccif.ccwait[1],
      ccif.ccinv[1],
      ccif.ccsnoopaddr[1],
      ccif.dREN[1],
      ccif.dWEN[1],
      ccif.daddr[1],
      ccif.dstore[1],
      ccif.ccwrite[1],
      ccif.cctrans[1],
      ccif.ccdirty[1]
    );

  // map caches
/*  `ifndef MAPPED
  caches #(.CPUID(0))       CM0 (CLK, nRST, dcif0, ccif);
  caches #(.CPUID(1))       CM1 (CLK, nRST, dcif0, ccif);
  `else
    caches #(.CPUID(0))       CM0 (
      CLK,
      nRST,*/
     /* .\dcif.halt (dcif0.halt),
      .\dcif.ihit (dcif0.ihit),
      .\dcif.imemREN (dcif0.imemREN),
      .\dcif.imemload (dcif0.imemload),
      .\dcif.imemaddr (dcif0.imemaddr),
      .\dcif.dhit (dcif0.dhit),
      .\dcif.datomic (dcif0.datomic),
      .\dcif.dmemREN (dcif0.dmemREN),
      .\dcif.dmemWEN (dcif0.dmemWEN),
      .\dcif.flushed (dcif0.flushed),
      .\dcif.dmemload (dcif0.dmemload),
      .\dcif.dmemstore (dcif0.dmemstore),
      .\dcif.dmemaddr (dcif0.dmemaddr),
      .\ccif.iwait (ccif.iwait),
      .\ccif.dwait (ccif.dwait),
      .\ccif.iREN (ccif.iREN),
      .\ccif.dREN (ccif.dREN),
      .\ccif.dWEN (ccif.dWEN),
      .\ccif.iload (ccif.iload),
      .\ccif.dload (ccif.dload),
      .\ccif.dstore (ccif.dstore),
      .\ccif.iaddr (ccif.iaddr),
      .\ccif.daddr (ccif.daddr),
      .\ccif.ccwait (ccif.ccwait),
      .\ccif.ccinv (ccif.ccinv),
      .\ccif.ccwrite (ccif.ccwrite),
      .\ccif.cctrans (ccif.cctrans),
      .\ccif.localwrit (ccif.localwrit),
      .\ccif.ccdirty (ccif.ccdirty),
      .\ccif.ramWEN (ccif.ramWEN),
      .\ccif.ramREN (ccif.ramREN),
      .\ccif.ramstate (ccif.ramstate),
      .\ccif.ramaddr (ccif.ramaddr),
      .\ccif.ramstore (ccif.ramstore),
      .\ccif.ramload (ccif.ramload)*/
/*      dcif0.halt,
      dcif0.ihit,
      dcif0.imemREN,
      dcif0.dhit,
      dcif0.datomic,
      dcif0.dmemREN,
      dcif0.dmemWEN,
      dcif0.flushed,
      ccif.iwait,
      ccif.dwait,
      ccif.iREN,
      ccif.dREN,
      ccif.dWEN,
      ccif.ccwait,
      ccif.ccinv,
      ccif.ccwrite,
      ccif.cctrans,
      ccif.localwrit,
      ccif.ccdirty,
      ccif.ramWEN,
      ccif.ramREN,
      ccif.ramstate,
      ccif.ramload,
      ccif.ramaddr,
      ccif.ramstore,
      ccif.iload,
      ccif.dload,
      dcif0.dmemload,
      dcif0.imemload,
      dcif0.imemaddr,
      dcif0.dmemstore,
      dcif0.dmemaddr,
      ccif.dstore,
      ccif.iaddr,
      ccif.daddr
        );
    caches #(.CPUID(1))       CM1 (
      CLK,
      nRST,
      dcif1.halt,
      dcif1.ihit,
      dcif1.imemREN,
      dcif1.dhit,
      dcif1.datomic,
      dcif1.dmemREN,
      dcif1.dmemWEN,
      dcif1.flushed,
      ccif.iwait,
      ccif.dwait,
      ccif.iREN,
      ccif.dREN,
      ccif.dWEN,
      ccif.ccwait,
      ccif.ccinv,
      ccif.ccwrite,
      ccif.cctrans,
      ccif.localwrit,
      ccif.ccdirty,
      ccif.ramWEN,
      ccif.ramREN,
      ccif.ramstate,
      ccif.ramload,
      ccif.ramaddr,
      ccif.ramstore,
      ccif.iload,
      ccif.dload,
      dcif1.dmemload,
      dcif1.imemload,
      dcif1.imemaddr,
      dcif1.dmemstore,
      dcif1.dmemaddr,
      ccif.dstore,
      ccif.iaddr,
      ccif.daddr
        );*/
  // map coherence
  memory_control            CC (CLK, nRST, ccif);

  // interface connections
  assign scif.memaddr = ccif.ramaddr;
  assign scif.memstore = ccif.ramstore;
  assign scif.memREN = ccif.ramREN;
  assign scif.memWEN = ccif.ramWEN;

  assign ccif.ramload = scif.ramload;
  assign ccif.ramstate = scif.ramstate;

  assign halt = dcif0.flushed & dcif1.flushed;
endmodule
