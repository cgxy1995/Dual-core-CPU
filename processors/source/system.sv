/*
	Eric Villasenor
	evillase@gmail.com

	system top block wraps processor(datapath+cache)
	and memory (ram).
*/

// system interface
`include "system_if.vh"

module system (input logic CLK, nRST, system_if.sys syif// , cache_control_if ccif,datapath_cache_if dcif


);
logic outrValid0;
logic outwen0;
logic outwValid0;
logic outwRU0;
	// stopped running
	logic halt;
	logic lookren;


	// interface
	cpu_ram_if                            prif ();
  // processor
  //singlecycle #(.PC0('h0))              CPU (CLK, nRST, halt, prif);
  //pipeline    #(.PC0('h0))              CPU (CLK, nRST, halt, prif);
  multicore   #(.PC0('h0), .PC1('h200)) CPU (CLK, nRST, halt, prif);
	// memory
	ram                                   RAM (CLK, nRST, prif);
	//sdram                                 RAM (CLK, nRST, prif);

	// interface connections
	assign syif.halt = halt;
	assign syif.load = prif.ramload;

	// who has ram control
	assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
	assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
	assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
	assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule
