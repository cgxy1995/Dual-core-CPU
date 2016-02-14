
// interfaces
//`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

module dcache (
	input logic CLK, nRST,
		datapath_cache_if.dcache dcif,
	input logic dwait,
	input logic [31:0] dload,
	input logic ccwait, ccinv,
	input logic [31:0] ccsnoopaddr,
	output logic dREN, dWEN,
	output logic [31:0] daddr, dstore,
	output logic ccwrite, cctrans,ccdirty
	);
	/*`ifndef MAPPED
		datapath_cache_if.dcache dcif,
		cache_control_if.dcache ccif
  	`else
		dcif.halt,
		dcif.dmemREN,
		dcif.dmemWEN,
		dcif.datomic,
		word_t dcif.dmemstore,
		word_t dcif.dmemaddr,
		dcif.dhit,
		output word_t dcif.dmemload,
		output dcif.flushed,
		ccif.dwait,
		ccif.dload,
		ccif.ccwait,
		ccif.ccinv,
		word_t ccif.ccsnoopaddr,
		output ccif.dREN,
		output ccif.dWEN,
		output word_t ccif.daddr,
		output word_t ccif.dstore,
		output ccif.ccwrite,
		output ccif.cctrans,
		output ccif.ccdirty
	`endif
);*/
	parameter CPUID = 0;
	logic actualWordSel , flushwordSel;

	// dcif:
	/*
	input   halt, dmemREN, dmemWEN,
			datomic, dmemstore, dmemaddr,
	output  dhit, dmemload, flushed*/
	// ccif:
	/*
	input   dwait, dload,
		output  dREN, dWEN, daddr, dstore*/

	//assign dcif.flushed = 0;	// temp val

	logic veryDirtyTransition;	// asserts when reading or writing to the most dirty case

	logic[25:0] dpTag;
	logic[25:0] cTag;
	logic[2:0] inIndex;
	logic rValid;
	logic inBO;
	logic [1:0] inByteO;
	assign dpTag = dcif.dmemaddr[31:6];
	logic ccset;	// cc set select
	logic [2:0] ccindex;

	always_comb begin : _cache_data_index_choose
		if(!ccwait)begin
			inIndex = dcif.dmemaddr[5:3];
		end else begin
			inIndex = ccindex;
		end
	end

	logic blkStat;


	assign inBO = dcif.dmemaddr[2];


	// cc wait stuff
	logic ccFlushWord;

	logic veryHit;
	logic rBO;
	always_comb begin : read_block_select
		if(dcif.halt)begin
			rBO = flushwordSel;
		end else begin
			if(ccwait)begin
				rBO = ccFlushWord;
			end else begin
				// 11/21/2013
				//if(!veryHit)begin
				if(!dcif.dhit)begin
					rBO = blkStat;
				end else begin
					rBO = inBO;
				end
			end
		end
	end


	assign inByteO = dcif.dmemaddr[1:0];

	word_t rData;	// cache read data (pure mux output)

	logic [31:0] readData0 [7:0];
	logic [31:0] readData1 [7:0];

	logic [25:0] readTag0 [7:0];
	logic [25:0] readTag1 [7:0];

	logic [7:0] readValid0;
	logic [7:0] readValid1;

	logic [7:0] set;
	logic setEN;

	logic [7:0] setDirty0;
	logic [7:0] setDirty1;
	logic [7:0] readDirty0;
	logic [7:0] readDirty1;
	logic [7:0] setRU0;
	logic [7:0] setRU1;
	logic [7:0] RUEN;
	logic [7:0] syncRUEN;

	word_t writData0[7:0];
	word_t writData1[7:0];
	logic [25:0]writTag0[7:0];
	logic [25:0]writTag1[7:0];
	logic [7:0]writDirty0 , writDirty1;
	logic [7:0]writValid0 , writValid1;

	logic [7:0]writRecentlyUsed0 , writRecentlyUsed1;
	logic [7:0]readRecentlyUsed0 , readRecentlyUsed1;
	logic [7:0]cWEN0 , cWEN1;	// cache writ enable

	// control signals
	logic setsel0, setsel1;	// ram load which cache(left or right)
	logic wen0 , wen1;		// cache block writ select (left or right which to writ)

	logic hitWen;

	word_t rData0 , rData1;

	logic [25:0] rTag0 , rTag1;

	logic wDirty0 , wDirty1;
	logic rDirty0 , rDirty1;

	logic wValid0 , wValid1;
	logic rValid0 , rValid1;

	logic wRU0 , wRU1;
	logic rRU0 , rRU1;

	logic dhitlast;

	logic dRENLatch , dwaitSync;
	assign dwaitSync = dwait|(!dRENLatch);

	logic wValidEN;



	logic [25:0] cctag;
	//logic [2:0] ccindex;
	logic [1:0] inv [7:0];


	logic rmwval;


	/// flush stuff

	logic [3:0] count;
	logic [3:0] nextcount;
	logic [1:0] track;
	logic [1:0] nexttrack;
	logic flushdWEN;	// this is the flushtime dWEN
	logic [31:0] flushaddr;

	logic [31:0] flushdata;
	logic ramdWEN;	// this is the runtime dWEN
	always_comb begin : ccifdWEN
		if(!dcif.halt)begin
			//if(dcif.datomic)begin	// sc
			//	dWEN = rmwval&ramdWEN;
			//end else begin
				dWEN = ramdWEN;
			//end
		end else begin
			dWEN = flushdWEN;
		end
	end

	always_comb begin : systemHalt
		if(count==9)begin
			dcif.flushed = 1;
		end else begin
			dcif.flushed = 0;
		end
	end


	// flush stuff end





	// if previous state of dREN is not 1 the current dwait is invalid(ram latency != 0)
	always_ff@(posedge CLK or negedge nRST) begin : proc_
		if(~nRST) begin
			dRENLatch = 0;
		end begin
			dRENLatch = dREN | ramdWEN;
		end
	end



	always_ff@(posedge CLK or negedge nRST) begin : dhitlast_ff
		if(~nRST) begin
			dhitlast = 0;
		end else begin
			dhitlast = dcif.dhit;
		end
	end

	logic dmemWENSync , dmemWENLast;
	assign dmemWENSync = dmemWENLast&dcif.dmemWEN&!dhitlast;
	always_ff@(posedge CLK or negedge nRST) begin : dmemWENLast_ff
		if(~nRST) begin
			dmemWENLast = 0;
		end else begin
			dmemWENLast = dcif.dmemWEN;
		end
	end

	int debugSync;




	logic actualHit;
	// actualHit: sometimes datapath gives a dcif.dmemREN for one cycle by mistake, if it is a cache hit
	// the dcache will response an actualHit immidiately, but THAT'S WRONG, so (actualHit&&dcif.dmemREN)
	// is used to filt this kind of "glich hit"
	//assign dcif.dhit = actualHit&(dcif.dmemREN|dmemWENSync);
	always_comb begin : _dhit
		if(!rmwval&dcif.datomic&dmemWENSync)begin	// when sc fails give dhit immediately
			dcif.dhit = 1;
		end else begin
			dcif.dhit = actualHit&(dcif.dmemREN|dmemWENSync);
		end
	end
	logic storeMiss;// this signal asserts when

	logic flush2;	// when need to flush two words.

	always_comb begin : syncRUEN_what
		//$display("start of syncRUEN_what");
		if(dcif.dmemREN|dmemWENSync)begin
			debugSync = 123;
			if(actualHit)begin
				debugSync = 456;
				if(dREN | ramdWEN | storeMiss)begin
					debugSync = 789;
					syncRUEN = RUEN;
				end else begin
					debugSync = 188;
					syncRUEN = 0;
				end
			end else if(veryDirtyTransition & !dwaitSync)begin
				syncRUEN = RUEN;
				debugSync = 990;
			end else if(flush2 & !dwaitSync & blkStat)begin
				syncRUEN = RUEN;
				debugSync = 778;
			end else if(veryHit)begin
				syncRUEN = RUEN;
				debugSync = 20105;
			end else begin
				syncRUEN = 0;
				debugSync = 879;
			end
		end else begin
			syncRUEN = 0;
			debugSync = 993;
		end
	end


	always_comb begin : dmemload_mux
		//$display("start of dmemload_mux");
		/*if(dREN)begin
			if(!dwaitSync)begin
				dmemload = ccif.dload;
			end else begin
				dcif.dmemload = 32'h98765432;	// indicate a bad load
			end
		end else begin	// (hit) data <- cache*/
			if(dcif.datomic&dmemWENSync)begin	// sc
				dcif.dmemload = {31'b0,rmwval};
			end else if(setsel0)begin
				dcif.dmemload = rData0;
			end else if(setsel1)begin
				dcif.dmemload = rData1;
			end else begin
				dcif.dmemload = 32'h98765432;
			end
			//dcif.dmemload = (setsel0&&rData0) || (setsel1&&rData1);
		//end
	end


	word_t wData;
	int wDataDebug;
	//there is a write to invalid block and then a "under the hood load"
	always_comb begin
		//$display("start of wDataFirst");
		wDataDebug = 33;
		wData = 32'habcdef;
		if(dcif.dmemREN)begin
			wDataDebug = 17;
			wData = dload;
		end else if(dmemWENSync)begin
			if(storeMiss)begin
				if(blkStat==inBO)begin
					wDataDebug = 18;
					wData = dcif.dmemstore;
				end else begin
					wDataDebug = 19;
					wData = dload;
				end
			end else begin
				wDataDebug = 26;
				wData = dcif.dmemstore;
			end
		end else begin
			wDataDebug = 229;
			wData = 32'h11111111;
		end
	end
	//assign wData = dload&&dmemREN || dcif.dmemstore&&dmemWENSync;
	logic [25:0] wTag;
	assign wTag = dpTag;

	word_t rAddr0 , rAddr1;
	assign rAddr0 = {rTag0,inIndex,inBO,inByteO};
	assign rAddr1 = {rTag1,inIndex,inBO,inByteO};

	// blkStat - block status, 0 if read/writing to word0 of this block, 1 if --- word1 ---.
	// every mem read/write involves a blkStat goes from 0 to 1
	int blkStatDebug;
	always_ff@(posedge CLK or negedge nRST) begin : block_status
		////$display("start of block_status");
		blkStatDebug = 321;
		if(~nRST) begin
			blkStat <= 0;
			blkStatDebug = 337;
		// if only use !dwaitSync free state will be counted
		end else if(!dwaitSync & (dREN|ramdWEN))begin
			blkStat <= !blkStat;
			blkStatDebug = 999;
			////$display("1 of block_status");
		end else if(dmemWENSync)begin
			if(storeMiss&!blkStat)begin
				if(!inBO | !dwaitSync)begin
					blkStat <= 1'b1;
					blkStatDebug = 888;
				end
			end else if(!dwaitSync)begin
				blkStat <= !blkStat;
				blkStatDebug = 339;
			end
			////$display("2 of block_status");
		end else if(!(ramdWEN|dREN))begin
			blkStat <= 0;
			blkStatDebug = 455;
			////$display("3 of block_status");
		end
	end

	// word select: select left or right word in a block to writeto/readfrom
	logic wordSel;	// word sel is moved to the large mux to avoid loops...
	/*always_comb begin: word_select
		if(/*!dwaitSync & *\/ (dREN|ramdWEN))begin
			wordSel = blkStat;
		end else begin
			wordSel = inBO;
		end
	end*/


	int addrDebug;
	logic flushOut;

	always_comb begin : cc_daddr_mux
	/*assign daddr = ( ((rAddr0&setsel0) | (rAddr1&setsel1))&ramdWEN )	// store addr
		|	(dREN & (dcif.dmemaddr) );*/
		//$display("start of cc_daddr_mux");
		if(!dcif.halt)begin
			if(ccwait)begin	// cc flush state
				daddr = {cctag , ccindex , ccFlushWord , 2'b00};
				addrDebug = 996;


			end else begin
				addrDebug = 998;
				if(flushOut)begin
					addrDebug = 889;
					// this is a exclusive case for that:
					// when both sets are dirty, then have to write one set to ram
					// only in this case cache need to write to mem
					if(setsel0)begin	// normal
						addrDebug = 452;
						daddr = {rTag0,inIndex,blkStat,inByteO};
					end else if(setsel1)begin
						addrDebug = 464;
						daddr = {rTag1,inIndex,blkStat,inByteO};
					end else begin
						addrDebug = 474;
						daddr = 32'hbaddaddd;	// indicate wrong
					end
				end else if(dREN)begin
					addrDebug = 731;
					daddr = {dcif.dmemaddr[31:3] , blkStat , dcif.dmemaddr[1:0]};
				/*end else begin
					addrDebug = 409;
					daddr = 32'hbaddaddd;
				end*/
				end else if(cctrans)begin	// use ccif.daddr as snoopaddr to invalidate
					daddr = dcif.dmemaddr;	// the other cache
				end else begin
					daddr = 32'habcdabcd;
				end
			end
		end else begin
			addrDebug = 666;
			daddr = flushaddr;
		end
	end

	always_comb begin : dstore_mux
		//$display("start of dstore_mux");
		if(!dcif.halt)begin
			if(ccwait)begin
				if(ccset==0)begin
					dstore = rData0;
				end else if(ccset==1)begin
					dstore = rData1;
				end else begin
					dstore = 32'bx;
				end
			end else begin
				if(setsel0)begin
					dstore = rData0;
				end else if(setsel1)begin
					dstore = rData1;
				end else begin
					dstore = 32'bx;
				end
			end
		end else begin
			dstore = flushdata;
		end
	end

	logic[7:0] onevar;


	//logic actualWordSel , flushwordSel;
	always_comb begin : wordSel_comb
		if(dcif.halt)begin
			actualWordSel = flushwordSel;
		end else begin
			actualWordSel = wordSel;
		end
	end




	logic wDirtyEN;
	// exclusively write dirty bit to a cache block, used for transition of state very dirty to regular replace

	genvar ii;
	generate
		for(ii = 0; ii < 8; ii++)begin: block_gen
			assign onevar[ii] = set[ii];
			dblock #(.rstval('h0)) oneBlock(
				CLK,
				nRST,
				writData0[ii], // wData,
				writTag0[ii], // setTag,
				writValid0[ii],
				/*!dcif.dhit &*/ cWEN0[ii],		/*set[ii] & setsel0,*/
				readData0[ii],
				readTag0[ii],
				readValid0[ii],
				writDirty0[ii],
				readDirty0[ii],
				writRecentlyUsed0[ii],
				readRecentlyUsed0[ii],
				syncRUEN[ii],
				rBO,
				//blkStat,
				actualWordSel,
				wDirtyEN,
				dcif.dhit,
				wValidEN,
				inv[ii][0]
			);


			dblock #(.rstval('h1)) twoBlock(
				CLK,
				nRST,
				writData1[ii], // wData,
				writTag1[ii], // setTag,
				writValid1[ii],
				/*!dcif.dhit & */cWEN1[ii],		/*set[ii] & setsel1,*/
				readData1[ii],
				readTag1[ii],
				readValid1[ii],
				writDirty1[ii],
				readDirty1[ii],
				writRecentlyUsed1[ii],
				readRecentlyUsed1[ii],
				syncRUEN[ii],
				rBO,
				//blkStat,
				actualWordSel,
				wDirtyEN,
				dcif.dhit,
				wValidEN,
				inv[ii][1]
			);
		end
	endgenerate

	logic hitCen;
	word_t hitcount;
	always_ff@(posedge CLK or negedge nRST) begin : hit_counter
		//$display("start of hit_counter");
		if(~nRST) begin
			hitcount = 0;
		end else if(hitCen & actualHit)begin
			hitcount += 1;
		end
	end


	logic SLstate;	// 0 is store, 1 is writ, store first writ then
	logic SLtrigger;	// when trigger is assterted SLstate start to count
	always_ff@(posedge CLK or negedge nRST) begin :cache_load_sw_rememberer
		//$display("start of cache_load_sw_rememberer");
		if(~nRST)begin
			SLstate = 0;
		end else begin
			if(SLtrigger)begin	// when program need to count state
				if(!dwaitSync & !SLstate & blkStat)begin
				// in frist state(system store) when first hit received goto next state(system load)
					SLstate = 1;
				end	// else state no change
			end else begin	// program doesn't need this state, reset back to init
				SLstate = 0;
			end
		end
	end

	logic fakeHit;	// fake hit is the hit when there is only one word per block
	// real dhit is asserted at second fakeHit(after two words are both loaded)
	//assign actualHit = fakeHit&blkStat;

	logic faststate;	// when store to a missed block, system get stucked at storing to
	// block offset=1 because no actualHit is asserted for this case. need to make a actualHit
	// here
	assign faststate = storeMiss&(inBO==1'b1);

	always_ff@(posedge CLK , negedge nRST)begin
		if(!nRST)begin
			actualHit = 0;
		end else begin
			if(dREN | ramdWEN | storeMiss)begin
				actualHit = (fakeHit|faststate)&blkStat;
			end else begin
				actualHit = fakeHit&!actualHit;	// dhit can only be asserted for one period
			end
		end
	end


	always_ff@(posedge CLK , negedge nRST)begin
		if(!nRST)begin
			hitWen = 0;
		end else begin
			if(actualHit&hitWen)begin
				hitWen = 0;
			end else begin
				hitWen = 1;
			end
		end
	end



	// cc flush: when cc is in flush state and signals a ccwait, this cache will spit out
	// its word and invalidates itself
	// and stops all other cache operations(by remove dcif.dmemR/WEN)
	//logic ccFlushWord;
	always_ff@(posedge CLK or negedge nRST) begin : _cc_flush_word_rememberer
		if(~nRST) begin
			ccFlushWord = 0;
		end else if(ccwait&!dwait)begin
			ccFlushWord = !ccFlushWord;
		end
	end


	int mainCase;	// debug
	always_comb begin:main_select
		//$display("start of main_select");
		fakeHit = 1;
		wen0 = 0;
		wen1 = 0;



		setsel0 = 0;
		setsel1 = 0;
		ramdWEN = 0;
		SLtrigger = 0;

		wValid0 = rValid0;
		wValid1 = rValid1;

		wDirty0 = rDirty0;
		wDirty1 = rDirty1;
		wRU0 = 0;
		wRU1 = 0;

		hitCen = 0;

		wordSel = inBO;	// word select


		storeMiss = 0;

		mainCase = 77;
		wDirtyEN = 0;

		veryDirtyTransition = 0;
		veryHit = 0;
		wValidEN = 0;
		flush2 = 0;
		flushOut = 0;

		ccwrite = 0;
		cctrans = 0;

		if(dmemWENSync & !ccwait)begin


			// handle sc fail
			if(!rmwval&dcif.datomic)begin	// sc fail, give dhit without store
				dREN = 0;
				wen0 = 0;		// try not to change anything
				wRU0 = rRU0;
				wValidEN = 0;
				wDirty0 = rDirty0;
				mainCase = 9023;
				ccwrite = 0;
			end

			else

			if((rTag0==dpTag)&rValid0)begin	// perfect, write hit
				dREN = 0;
				hitCen = 1;
				wen0 = !actualHit&hitWen;
				wRU0 = 1;
				wDirty0 = 1;
				wordSel = inBO;
				mainCase = 11;
				veryHit = 1;
				cctrans = 1;
			end else if((rTag1==dpTag)&rValid1)begin	// same write hit
				dREN = 0;
				hitCen = 1;
				wen1 = !actualHit&hitWen;
				wRU1 = 1;
				wDirty1 = 1;
				wordSel = inBO;
				mainCase = 12;
				veryHit = 1;
				cctrans = 1;


			end else if(!rValid0)begin    // 0 block is free to be written
				// this is a cache miss, need to load another word from ram to avoid cache hole
				dREN = (inBO!=blkStat);
				hitCen = 0;
				wen0 = 1;
				wRU0 = 1;
				wValid0 = 1;
				wValidEN = 1;
				wordSel = blkStat;
				storeMiss = 1;
				fakeHit = !dwaitSync;
				wDirty0 = 1;
				mainCase = 21;
				ccwrite = 1;
			end else if(!rValid1)begin
				dREN = (inBO!=blkStat);
				hitCen = 0;
				wen1 = 1;
				wRU1 = 1;
				wValid1 = 1;
				wValidEN = 1;
				wordSel = blkStat;
				storeMiss = 1;
				fakeHit = !dwaitSync;
				wDirty1 = 1;
				ccwrite = 1;
				mainCase = 22;

			end else begin  // neither block is free to writ, need to force writ one anyway
				// match tag first, even the block is dirty if tag match, can writ anyway

				mainCase = 25;

				if(rTag0==dpTag)begin	// writ to block 1
					dREN = 0;
					hitCen = 0;
					wen0 = 1;
					wRU0 = 1;
					wDirty0 = 1;
					wordSel = blkStat;

					mainCase = 31;

				end else if(rTag1==dpTag)begin
					dREN = 0;
					hitCen = 0;
					wen1 = 1;
					wRU1 = 1;
					wDirty1 = 1;
					wordSel = blkStat;


					mainCase = 32;

				end else begin	// no tag match, have to rewrit a valid, not it self value
					hitCen = 0;
					mainCase = 35;
					// this is the case where all blocks are dirty and tag not match
					// have to send one of them to ram
					if(!rRU0)begin
						if(rDirty0)begin	// flush this word
							flushOut = 1;	// tell ccif.addr to flush a cache block
							ramdWEN = 1;
							SLtrigger = 1;
							setsel0 = 1;
							wen0 = 0;// & !dwaitSync;
							wRU0 = 1;
							wRU1 = 0;
							fakeHit = 0;	// don't need hit here, hit will be send after state transit to
							// others
							wValid0 = 0;
							wordSel = blkStat;
							// use this instead of wen so that only dirty bit is cleared,
							wValidEN = 1'b1;
							mainCase = 179;
							flush2 = 1;
							wDirty0 = blkStat & !dwaitSync;// clear dirty bit
							dREN = 0;
						end else begin	// don't need to flush any word
							dREN = (inBO!=blkStat);
							wen0 = 1;
							wRU0 = 1;
							wDirty0 = 1;
							wordSel = blkStat;
							fakeHit =  !dwaitSync;
							mainCase = 41;
							storeMiss = 1;
						end
					end else begin
						if(rDirty1)begin
							dREN = 0;
							flushOut = 1;
							ramdWEN = 1;
							SLtrigger = 1;
							setsel1 = 1;
							wen1 = 0;
							wRU1 = 0;
							wRU1 = 1;
							fakeHit = 0;	// don't need hit here, hit will be send after state transit to
							// others
							wValid1 = 0;
							wordSel = blkStat;
						// use this instead of wen so that only dirty bit is cleared,
							wValidEN = 1'b1;
							mainCase = 199;
							flush2 = 1;
							wDirty1 = blkStat & !dwaitSync;// clear dirty bit
						end else begin
							dREN = (inBO!=blkStat);
							wen1 = 1;
							wRU1 = 1;
							wDirty1 = 1;
							wordSel = blkStat;
							fakeHit = !dwaitSync;

							mainCase = 42;
							storeMiss = 1;
						end
					end
				end
			end
		end else if(dcif.dmemREN  & !ccwait)begin
			mainCase = 111;

			if(rValid0&(dpTag==rTag0))begin   // c0 hit
				dREN = 0;
				setsel0 = 1;
				wRU0 = 1;
				hitCen = 1;
				wordSel = inBO;	// word select

				mainCase = 131;
				veryHit = 1;

			end else if(rValid1&(dpTag==rTag1))begin  // c1 hit
				dREN = 0;
				setsel1 = 1;
				wRU1 = 1;
				hitCen = 1;
				wordSel = inBO;	// word select
				veryHit = 1;
				mainCase = 159;
			end else begin  // find invalid one and load data into it
				mainCase = 106;
				fakeHit = !dwaitSync;
				if(!rValid0)begin    // data -> c0
					wen0 = 1;//!dwaitSync;

					dREN = 1;
					wRU0 = 1;
					wordSel = blkStat;	// word select
					setsel0 = 1;
					mainCase = 437;

					fakeHit = !dwaitSync;

					wValid0 = 1;
					wValidEN = 1;

				end else if(!rValid1)begin   // data -> c1
					mainCase = 305;
					wen1 = 1;//!dwaitSync;
					dREN = 1;
					wRU1 = 1;
					wordSel = blkStat;
					setsel1 = 1;
					fakeHit = !dwaitSync;
					wValid1 = 1;
					wValidEN = 1;

				end else begin      // both valid(not free), need to replace one
					mainCase = 444;
					if(!rRU0)begin
						if(rDirty0)begin	// flush this word
							flushOut = 1;	// tell ccif.addr to flush a cache block
							dREN = 0;
							ramdWEN = 1;
							SLtrigger = 1;
							setsel0 = 1;
							wen0 = 0;// & !dwaitSync;
							wRU0 = 1;
							wRU1 = 0;
							fakeHit = 0;	// don't need hit here, hit will be send after state transit to
							// others
							wValid0 = 0;
							wordSel = blkStat;
							// use this instead of wen so that only dirty bit is cleared,
							wValidEN = 1'b1;
							mainCase = 179;
							flush2 = 1;
							wDirty0 = blkStat & !dwaitSync;// clear dirty bit
						end else begin	// don't need to flush any word
							dREN = 1;
							wen0 = 1;//!dwaitSync;
							wRU0 = 1;
							wordSel = blkStat;
							setsel0 = 1;
							fakeHit = !dwaitSync;
						end
					end else begin
						if(rDirty1)begin
							flushOut = 1;
							ramdWEN = 1;
							SLtrigger = 1;
							setsel1 = 1;
							wen1 = 0;
							wRU1 = 0;
							dREN = 0;
							wRU1 = 1;
							fakeHit = 0;	// don't need hit here, hit will be send after state transit to
							// others
							wValid1 = 0;
							wordSel = blkStat;
						// use this instead of wen so that only dirty bit is cleared,
							wValidEN = 1'b1;
							mainCase = 199;
							flush2 = 1;
							wDirty1 = blkStat & !dwaitSync;// clear dirty bit
						end else begin
							dREN = 1;
							wen1 = 1;//!dwaitSync;
							wRU1 = 1;
							wordSel = blkStat;
							setsel1 = 1;
							fakeHit = !dwaitSync;
						end
					end
				end
			end
		end else begin	// neigher w nor r
			hitCen = 0;
			fakeHit = 0;
			wen0 = 0;
			wen1 = 0;
			SLtrigger = 0;
			wValid0 = rValid0;
			wValid1 = rValid1;
			wDirty0 = rDirty0;
			wDirty1 = rDirty1;
			setsel0 = 1'dx;
			setsel1 = 1'dx;
			wRU0 = rRU0;
			wRU1 = rRU1;
			ramdWEN = 0;
			dREN = 0;
			wordSel = inBO;	// word select
			wValidEN = 0;
		end
	end

	assign cctag = ccsnoopaddr[31:6];
	assign ccindex = ccsnoopaddr[5:3];
	// cc read dirty
	always_comb begin: _cc_read_dirty
		ccdirty = 0;
		ccset = 1'bx;
		casez(ccindex)
		0:begin
			if(readDirty0[0]&readValid0[0]&(cctag==readTag0[0]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[0]&readValid1[0]&(cctag==readTag1[0]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		1:begin
			if(readDirty0[1]&readValid0[1]&(cctag==readTag0[1]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[1]&readValid1[1]&(cctag==readTag1[1]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		2:begin
			if(readDirty0[2]&readValid0[2]&(cctag==readTag0[2]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[2]&readValid1[2]&(cctag==readTag1[2]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		3:begin
			if(readDirty0[3]&readValid0[3]&(cctag==readTag0[3]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[3]&readValid1[3]&(cctag==readTag1[3]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		4:begin
			if(readDirty0[4]&readValid0[4]&(cctag==readTag0[4]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[4]&readValid1[4]&(cctag==readTag1[4]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		5:begin
			if(readDirty0[5]&readValid0[5]&(cctag==readTag0[5]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[5]&readValid1[5]&(cctag==readTag1[5]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		6:begin
			if(readDirty0[6]&readValid0[6]&(cctag==readTag0[6]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[6]&readValid1[6]&(cctag==readTag1[6]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		7:begin
			if(readDirty0[7]&readValid0[7]&(cctag==readTag0[7]))begin
				ccset = 0;
				ccdirty = 1;
			end else if(readDirty1[7]&readValid1[7]&(cctag==readTag1[7]))begin
				ccset = 1;
				ccdirty = 1;
			end
		end
		endcase
	end
	always_comb begin :_cc_invalid
		inv[0] = 0;
		inv[1] = 0;
		inv[2] = 0;
		inv[3] = 0;
		inv[4] = 0;
		inv[5] = 0;
		inv[6] = 0;
		inv[7] = 0;
		if(!ccwait)begin
			casez(ccindex)
				0:begin inv[0][0]=(cctag==readTag0[0])&ccinv;
						inv[0][1]=(cctag==readTag1[0])&ccinv;end
				1:begin inv[1][0]=(cctag==readTag0[1])&ccinv;
						inv[1][1]=(cctag==readTag1[1])&ccinv;end
				2:begin inv[2][0]=(cctag==readTag0[2])&ccinv;
						inv[2][1]=(cctag==readTag1[2])&ccinv;end
				3:begin inv[3][0]=(cctag==readTag0[3])&ccinv;
						inv[3][1]=(cctag==readTag1[3])&ccinv;end
				4:begin inv[4][0]=(cctag==readTag0[4])&ccinv;
						inv[4][1]=(cctag==readTag1[4])&ccinv;end
				5:begin inv[5][0]=(cctag==readTag0[5])&ccinv;
						inv[5][1]=(cctag==readTag1[5])&ccinv;end
				6:begin inv[6][0]=(cctag==readTag0[6])&ccinv;
						inv[6][1]=(cctag==readTag1[6])&ccinv;end
				7:begin inv[7][0]=(cctag==readTag0[7])&ccinv;
						inv[7][1]=(cctag==readTag1[7])&ccinv;end
			endcase
		end else begin
			casez(ccindex)
				0:begin inv[0][0]=(cctag==readTag0[0])&ccinv& (!dwait&ccFlushWord);
						inv[0][1]=(cctag==readTag1[0])&ccinv& (!dwait&ccFlushWord);end
				1:begin inv[1][0]=(cctag==readTag0[1])&ccinv& (!dwait&ccFlushWord);
						inv[1][1]=(cctag==readTag1[1])&ccinv& (!dwait&ccFlushWord);end
				2:begin inv[2][0]=(cctag==readTag0[2])&ccinv& (!dwait&ccFlushWord);
						inv[2][1]=(cctag==readTag1[2])&ccinv& (!dwait&ccFlushWord);end
				3:begin inv[3][0]=(cctag==readTag0[3])&ccinv& (!dwait&ccFlushWord);
						inv[3][1]=(cctag==readTag1[3])&ccinv& (!dwait&ccFlushWord);end
				4:begin inv[4][0]=(cctag==readTag0[4])&ccinv& (!dwait&ccFlushWord);
						inv[4][1]=(cctag==readTag1[4])&ccinv& (!dwait&ccFlushWord);end
				5:begin inv[5][0]=(cctag==readTag0[5])&ccinv& (!dwait&ccFlushWord);
						inv[5][1]=(cctag==readTag1[5])&ccinv& (!dwait&ccFlushWord);end
				6:begin inv[6][0]=(cctag==readTag0[6])&ccinv& (!dwait&ccFlushWord);
						inv[6][1]=(cctag==readTag1[6])&ccinv& (!dwait&ccFlushWord);end
				7:begin inv[7][0]=(cctag==readTag0[7])&ccinv& (!dwait&ccFlushWord);
						inv[7][1]=(cctag==readTag1[7])&ccinv& (!dwait&ccFlushWord);end
			endcase
		end
	end





	// llsc stuff
	word_t rmwstate;
	always_ff@(posedge CLK or negedge nRST) begin : _rmw_addr_ff
		if(~nRST)begin
			rmwstate = 32'hccacadda;
			rmwval = 0;
		end else if(dcif.datomic & dcif.dmemREN) begin	// ll
			rmwstate = dcif.dmemaddr;
			rmwval = 1;
		end else if(((ccsnoopaddr==rmwstate)&&(ccinv))			// coherent invalidate
					|((dcif.dmemaddr==rmwstate)&dmemWENSync&dcif.dhit))begin	// sc or sw match
			rmwstate = 32'hccacadda;
			rmwval = 0;
		end
	end



	int jj;
	always_comb begin: rData_gen

		rData0				=32'dx;
		rData1				=32'dx;
		rTag0				= 8'dx;
		rTag1				= 8'dx;
		rDirty0				= 8'dx;
		rDirty1				= 8'dx;
		rRU0				= 8'dx;
		rRU1				= 8'dx;
		////$display("start of rData");
		casez(inIndex)
			00:begin
				rData0					= readData0[00];
				rValid0					= readValid0[00];
				rTag0					= readTag0[00];
				rDirty0					= readDirty0[00];
				rRU0					= readRecentlyUsed0[00];
				rData1					= readData1[00];
				rValid1					= readValid1[00];
				rTag1					= readTag1[00];
				rDirty1					= readDirty1[00];
				rRU1					= readRecentlyUsed1[00];
			end
			01:begin
				rData0					= readData0[01];
				rValid0					= readValid0[01];
				rTag0					= readTag0[01];
				rDirty0					= readDirty0[01];
				rRU0					= readRecentlyUsed0[01];
				rData1					= readData1[01];
				rValid1					= readValid1[01];
				rTag1					= readTag1[01];
				rDirty1					= readDirty1[01];
				rRU1					= readRecentlyUsed1[01];
			end
			02:begin
				rData0 = readData0[02];
				rValid0 = readValid0[02];
				rTag0 = readTag0[02];
				rDirty0 = readDirty0[02];
				rRU0 = readRecentlyUsed0[02];

				rData1 = readData1[02];
				rValid1 = readValid1[02];
				rTag1 = readTag1[02];
				rDirty1 = readDirty1[02];
				rRU1 = readRecentlyUsed1[02];
			end
			03:begin
				rData0 = readData0[03];
				rValid0 = readValid0[03];
				rTag0 = readTag0[03];
				rDirty0 = readDirty0[03];
				rRU0 = readRecentlyUsed0[03];

				rData1 = readData1[03];
				rValid1 = readValid1[03];
				rTag1 = readTag1[03];
				rDirty1 = readDirty1[03];
				rRU1 = readRecentlyUsed1[03];
			end
			04:begin
				rData0 = readData0[04];
				rValid0 = readValid0[04];
				rTag0 = readTag0[04];
				rDirty0 = readDirty0[04];
				rRU0 = readRecentlyUsed0[04];

				rData1 = readData1[04];
				rValid1 = readValid1[04];
				rTag1 = readTag1[04];
				rDirty1 = readDirty1[04];
				rRU1 = readRecentlyUsed1[04];
			end
			05:begin
				rData0 = readData0[05];
				rValid0 = readValid0[05];
				rTag0 = readTag0[05];
				rDirty0 = readDirty0[05];
				rRU0 = readRecentlyUsed0[05];

				rData1 = readData1[05];
				rValid1 = readValid1[05];
				rTag1 = readTag1[05];
				rDirty1 = readDirty1[05];
				rRU1 = readRecentlyUsed1[05];
			end
			06:begin
				rData0 = readData0[06];
				rValid0 = readValid0[06];
				rTag0 = readTag0[06];
				rDirty0 = readDirty0[06];
				rRU0 = readRecentlyUsed0[06];

				rData1 = readData1[06];
				rValid1 = readValid1[06];
				rTag1 = readTag1[06];
				rDirty1 = readDirty1[06];
				rRU1 = readRecentlyUsed1[06];
			end
			07:begin
				rData0 = readData0[07];
				rValid0 = readValid0[07];
				rTag0 = readTag0[07];
				rDirty0 = readDirty0[07];
				rRU0 = readRecentlyUsed0[07];

				rData1 = readData1[07];
				rValid1 = readValid1[07];
				rTag1 = readTag1[07];
				rDirty1 = readDirty1[07];
				rRU1 = readRecentlyUsed1[07];
			end
			default:begin
				rData0	=32'dx;
				rData1	=32'dx;
				rTag0	= 1'dx;
				rTag1	= 1'dx;
				rDirty0	= 1'dx;
				rDirty1	= 1'dx;
				rRU0	= 1'dx;
				rRU1	= 1'dx;
				rValid0	=1'dx;
				rValid1	=1'dx;
			end
		endcase
	end
	always_comb begin : wdata_gen
		//$display("start of wData");
				RUEN				= 0;

				writValid0			= readValid0;
				writDirty0			= readDirty0;
				writRecentlyUsed0	= readRecentlyUsed0;
				writValid1			= readValid1;
				writDirty1			= readDirty1;
				writRecentlyUsed1	= readRecentlyUsed1;
				cWEN0				= 0;
				cWEN1				= 0;
writData0[0] = readData0[0]; writTag0[0] = readTag0[0]; writData1[0] = readData1[0]; writTag1[0] = readTag1[0];
writData0[1] = readData0[1]; writTag0[1] = readTag0[1]; writData1[1] = readData1[1]; writTag1[1] = readTag1[1];
writData0[2] = readData0[2]; writTag0[2] = readTag0[2]; writData1[2] = readData1[2]; writTag1[2] = readTag1[2];
writData0[3] = readData0[3]; writTag0[3] = readTag0[3]; writData1[3] = readData1[3]; writTag1[3] = readTag1[3];
writData0[4] = readData0[4]; writTag0[4] = readTag0[4]; writData1[4] = readData1[4]; writTag1[4] = readTag1[4];
writData0[5] = readData0[5]; writTag0[5] = readTag0[5]; writData1[5] = readData1[5]; writTag1[5] = readTag1[5];
writData0[6] = readData0[6]; writTag0[6] = readTag0[6]; writData1[6] = readData1[6]; writTag1[6] = readTag1[6];
writData0[7] = readData0[7]; writTag0[7] = readTag0[7]; writData1[7] = readData1[7]; writTag1[7] = readTag1[7];
		casez(inIndex)
			00:begin
				RUEN[00]				= 1;
				writData0[00]			= wData;
				writTag0[00]			= wTag;
				writValid0[00]			= wValid0;
				writDirty0[00]			= wDirty0;
				writRecentlyUsed0[00]	= wRU0;
				cWEN0[00]				= wen0;

				writData1[00]			= wData;
				writTag1[00]			= wTag;
				writValid1[00]			= wValid1;
				writDirty1[00]			= wDirty1;
				writRecentlyUsed1[00]	= wRU1;
				cWEN1[00]				= wen1;
			end
			01:begin
				RUEN[01]				= 1;
				writData0[01]			= wData;
				writTag0[01]			= wTag;
				writValid0[01]			= wValid0;
				writDirty0[01]			= wDirty0;
				writRecentlyUsed0[01]	= wRU0;
				cWEN0[01]				= wen0;

				writData1[01]			= wData;
				writTag1[01]			= wTag;
				writValid1[01]			= wValid1;
				writDirty1[01]			= wDirty1;
				writRecentlyUsed1[01]	= wRU1;
				cWEN1[01]				= wen1;
			end
			02:begin
				RUEN[02]				= 1;
				writData0[02]			= wData;
				writTag0[02]			= wTag;
				writValid0[02]			= wValid0;
				writDirty0[02]			= wDirty0;
				writRecentlyUsed0[02]	= wRU0;
				cWEN0[02]				= wen0;

				writData1[02]			= wData;
				writTag1[02]			= wTag;
				writValid1[02]			= wValid1;
				writDirty1[02]			= wDirty1;
				writRecentlyUsed1[02]	= wRU1;
				cWEN1[02]				= wen1;
			end
			03:begin
				RUEN[03]				= 1;
				writData0[03]			= wData;
				writTag0[03]			= wTag;
				writValid0[03]			= wValid0;
				writDirty0[03]			= wDirty0;
				writRecentlyUsed0[03]	= wRU0;
				cWEN0[03]				= wen0;

				writData1[03]			= wData;
				writTag1[03]			= wTag;
				writValid1[03]			= wValid1;
				writDirty1[03]			= wDirty1;
				writRecentlyUsed1[03]	= wRU1;
				cWEN1[03]				= wen1;
			end
			04:begin
				RUEN[04]				= 1;
				writData0[04]			= wData;
				writTag0[04]			= wTag;
				writValid0[04]			= wValid0;
				writDirty0[04]			= wDirty0;
				writRecentlyUsed0[04]	= wRU0;
				cWEN0[04]				= wen0;

				writData1[04]			= wData;
				writTag1[04]			= wTag;
				writValid1[04]			= wValid1;
				writDirty1[04]			= wDirty1;
				writRecentlyUsed1[04]	= wRU1;
				cWEN1[04]				= wen1;
			end
			05:begin
				RUEN[05]				= 1;
				writData0[05]			= wData;
				writTag0[05]			= wTag;
				writValid0[05]			= wValid0;
				writDirty0[05]			= wDirty0;
				writRecentlyUsed0[05]	= wRU0;
				cWEN0[05]				= wen0;

				writData1[05]			= wData;
				writTag1[05]			= wTag;
				writValid1[05]			= wValid1;
				writDirty1[05]			= wDirty1;
				writRecentlyUsed1[05]	= wRU1;
				cWEN1[05]				= wen1;
			end
			06:begin
				RUEN[06]				= 1;
				writData0[06]			= wData;
				writTag0[06]			= wTag;
				writValid0[06]			= wValid0;
				writDirty0[06]			= wDirty0;
				writRecentlyUsed0[06]	= wRU0;
				cWEN0[06]				= wen0;

				writData1[06]			= wData;
				writTag1[06]			= wTag;
				writValid1[06]			= wValid1;
				writDirty1[06]			= wDirty1;
				writRecentlyUsed1[06]	= wRU1;
				cWEN1[06]				= wen1;
			end
			07:begin
				RUEN[07]				= 1;
				writData0[07]			= wData;
				writTag0[07]			= wTag;
				writValid0[07]			= wValid0;
				writDirty0[07]			= wDirty0;
				writRecentlyUsed0[07]	= wRU0;
				cWEN0[07]				= wen0;

				writData1[07]			= wData;
				writTag1[07]			= wTag;
				writValid1[07]			= wValid1;
				writDirty1[07]			= wDirty1;
				writRecentlyUsed1[07]	= wRU1;
				cWEN1[07]				= wen1;
			end
		endcase
	end

/// flush logic
always_ff@(posedge CLK or negedge nRST)begin
	if(~nRST)begin
		count = 0;
		track = 0;
	end else begin
		//count = nextcount;
		if(flushdWEN)begin
			if(!dwait)begin
				track = nexttrack;
				count = nextcount;
			end
		end else begin
			track = nexttrack;
			count = nextcount;
		end
	end
end

always_comb begin
	nextcount = count;
	nexttrack =track;
	flushaddr = 'bx;
	flushdata = 'bx;
	flushdWEN = 0;
	flushwordSel = track[0];
	if(dcif.halt==1'b1)begin //How do I know there is a halt?
		case(count)
			0:
			begin
				if(readDirty0[0]|readDirty1[0])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[0],3'd0,1'b0,2'b00};
						flushdata = readData0[0];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[0];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[0],3'd0,1'b1,2'b00};
						flushdata = readData0[0];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[0];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[0],3'd0,1'b0,2'b00};
						flushdata = readData1[0];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[0];
					end else begin
						flushaddr = {readTag1[0],3'd0,1'b1,2'b00};
						flushdata = readData1[0];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[0];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			1:
			begin
				if(readDirty0[1]|readDirty1[1])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[1],3'd1,1'b0,2'b00};
						flushdata = readData0[1];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[1];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[1],3'd1,1'b1,2'b00};
						flushdata = readData0[1];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[1];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[1],3'd1,1'b0,2'b00};
						flushdata = readData1[1];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[1];
					end else begin
						flushaddr = {readTag1[1],3'd1,1'b1,2'b00};
						flushdata = readData1[1];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[1];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			2:
			begin
				if(readDirty0[2]|readDirty1[2])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[2],3'd2,1'b0,2'b00};
						flushdata = readData0[2];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[2];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[2],3'd2,1'b1,2'b00};
						flushdata = readData0[2];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[2];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[2],3'd2,1'b0,2'b00};
						flushdata = readData1[2];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[2];
					end else begin
						flushaddr = {readTag1[2],3'd2,1'b1,2'b00};
						flushdata = readData1[2];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[2];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			3:
			begin
				if(readDirty0[3]|readDirty1[3])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[3],3'd3,1'b0,2'b00};
						flushdata = readData0[3];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[3];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[3],3'd3,1'b1,2'b00};
						flushdata = readData0[3];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[3];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[3],3'd3,1'b0,2'b00};
						flushdata = readData1[3];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[3];
					end else begin
						flushaddr = {readTag1[3],3'd3,1'b1,2'b00};
						flushdata = readData1[3];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[3];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			4:
			begin
				if(readDirty0[4]|readDirty1[4])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[4],3'd4,1'b0,2'b00};
						flushdata = readData0[4];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[4];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[4],3'd4,1'b1,2'b00};
						flushdata = readData0[4];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[4];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[4],3'd4,1'b0,2'b00};
						flushdata = readData1[4];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[4];
					end else begin
						flushaddr = {readTag1[4],3'd4,1'b1,2'b00};
						flushdata = readData1[4];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[4];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			5:
			begin
				if(readDirty0[5]|readDirty1[5])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[5],3'd5,1'b0,2'b00};
						flushdata = readData0[5];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[5];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[5],3'd5,1'b1,2'b00};
						flushdata = readData0[5];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[5];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[5],3'd5,1'b0,2'b00};
						flushdata = readData1[5];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[5];
					end else begin
						flushaddr = {readTag1[5],3'd5,1'b1,2'b00};
						flushdata = readData1[5];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[5];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			6:
			begin
				if(readDirty0[6]|readDirty1[6])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[6],3'd6,1'b0,2'b00};
						flushdata = readData0[6];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[6];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[6],3'd6,1'b1,2'b00};
						flushdata = readData0[6];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[6];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[6],3'd6,1'b0,2'b00};
						flushdata = readData1[6];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[6];
					end else begin
						flushaddr = {readTag1[6],3'd6,1'b1,2'b00};
						flushdata = readData1[6];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[6];
						nextcount = count+1;
					end
				end else begin
					nextcount = count+1;
				end
			end
			7:
			begin
				if(readDirty0[7]|readDirty1[7])begin
					//flushdWEN = 1;
					if((track == 2'b00))begin
						flushaddr = {readTag0[7],3'd7,1'b0,2'b00};
						flushdata = readData0[7];
						nexttrack = 2'b01;
						flushdWEN = readDirty0[7];
					end else if((track == 2'b01))begin
						flushaddr = {readTag0[7],3'd7,1'b1,2'b00};
						flushdata = readData0[7];
						nexttrack = 2'b10;
						flushdWEN = readDirty0[7];
					end else if((track == 2'b10))begin
						flushaddr = {readTag1[7],3'd7,1'b0,2'b00};
						flushdata = readData1[7];
						nexttrack = 2'b11;
						flushdWEN = readDirty1[7];
					end else begin
						flushaddr = {readTag1[7],3'd7,1'b1,2'b00};
						flushdata = readData1[7];
						nexttrack = 2'b00;
						flushdWEN = readDirty1[7];
						nextcount = count+1;
					end
				end else begin
					nextcount = count + 1;
				end
			end
			8:
			begin
				flushaddr = 32'h3100;
				flushdata = hitcount;
				nexttrack = 2'b00;
				//flushdWEN = 1;	// for dual core probably don't need this anymore
				nextcount = count+1;
			end
			9:begin
				nextcount = 9;
			end
		endcase
	end
end


endmodule