/*
  Mingfei Huang
  huang243@purdue.edu

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
// register file interface
`include "register_file_if.vh"
// control unit hazard unit alu interface
`include "control_hazard_alu_if.vh"
// control signal selects
`include "control_sel_pkg.vh"
// import types
import cpu_types_pkg::*;
import control_sel_pkg::*;
module datapath (
	input logic CLK, nRST,
	datapath_cache_if.dp dpif
);

	// pc init
	parameter PC_INIT = 0;

	// start from here is personal code

// downward interfaces and modules
	logic ppEN , mewbEN , ifidKill;
// bubble insertion
	logic sgbb , dbbb;	// single bubble , double bubble
	logic dbbb_last;	// latch double bubble for one pipeline period

	logic [3:0] ppstop;
	logic bubble;
	assign bubble = sgbb|dbbb|dbbb_last;

	logic sgbbLast;
	always_ff@(posedge CLK or negedge nRST) begin : sgbb_latch
		if(~nRST) begin
			sgbbLast = 0;
		end else begin
			sgbbLast = sgbb;
		end
	end



	register_file_if rfif();
	control_hazard_alu_if chaif();
	register_file regfile(rfif,CLK,nRST);
	Alu alu(chaif);
	Control_unit CU(chaif);
	hazard_unit HU(CLK , nRST , chaif);

	pipeline_front_if front();
	pipeline_back_if back();
	pipeline_latch PL(front , back , CLK , nRST , ppEN , mewbEN , ifidKill , bubble/*, ppstop*/);
//	pipeline_front_latch pfif();
//	pipeline_back_latch pbif();

// instruction fields
	// instruction decode phase
		logic [5:0] opcode_IFID;
		logic [4:0] rs_IFID;
		logic [4:0] rt_IFID;
		logic [4:0] rd_IFID;
		logic [4:0] sa_IFID;
		logic [15:0] imm_IFID;
		logic [25:0] JumpAddr_IFID;
		logic [15:0] offset_IFID;
		logic [5:0] rcode_IFID;
		logic [31:0] immext_IFID;
		assign opcode_IFID		= back.imemload_IFID[31:26];
		assign rs_IFID			= back.imemload_IFID[25:21];
		assign rt_IFID			= back.imemload_IFID[20:16];
		assign rd_IFID			= back.imemload_IFID[15:11];
		assign sa_IFID			= back.imemload_IFID[10:06];
		assign imm_IFID			= back.imemload_IFID[15:0];
		assign JumpAddr_IFID	= back.imemload_IFID[25:0];
		assign offset_IFID		= back.imemload_IFID[15:0];
		assign rcode_IFID		= back.imemload_IFID[5:0];

	// execute phase
		logic [5:0] opcode_IDEX;
		logic [4:0] rs_IDEX;
		logic [4:0] rt_IDEX;
		logic [4:0] rd_IDEX;
		logic [4:0] sa_IDEX;
		logic [15:0] imm_IDEX;
		logic [25:0] JumpAddr_IDEX;
		logic [15:0] offset_IDEX;
		logic [5:0] rcode_IDEX;
		logic [31:0] immext_IDEX;
		assign opcode_IDEX		= back.imemload_IDEX[31:26];
		assign rs_IDEX			= back.imemload_IDEX[25:21];
		assign rt_IDEX			= back.imemload_IDEX[20:16];
		assign rd_IDEX			= back.imemload_IDEX[15:11];
		assign sa_IDEX			= back.imemload_IDEX[10:06];
		assign imm_IDEX			= back.imemload_IDEX[15:0];
		assign JumpAddr_IDEX	= back.imemload_IDEX[25:0];
		assign offset_IDEX		= back.imemload_IDEX[15:0];
		assign rcode_IDEX		= back.imemload_IDEX[5:0];

	// memory phase
		logic [5:0] opcode_EXME;
		logic [4:0] rs_EXME;
		logic [4:0] rt_EXME;
		logic [4:0] rd_EXME;
		logic [4:0] sa_EXME;
		logic [15:0] imm_EXME;
		logic [25:0] JumpAddr_EXME;
		logic [15:0] offset_EXME;
		logic [5:0] rcode_EXME;
		logic [31:0] immext_EXME;
		assign opcode_EXME		= back.imemload_EXME[31:26];
		assign rs_EXME			= back.imemload_EXME[25:21];
		assign rt_EXME			= back.imemload_EXME[20:16];
		assign rd_EXME			= back.imemload_EXME[15:11];
		assign sa_EXME			= back.imemload_EXME[10:06];
		assign imm_EXME			= back.imemload_EXME[15:0];
		assign JumpAddr_EXME	= back.imemload_EXME[25:0];
		assign offset_EXME		= back.imemload_EXME[15:0];
		assign rcode_EXME		= back.imemload_EXME[5:0];

	// write back register phase
		logic [5:0] opcode_MEWB;
		logic [4:0] rs_MEWB;
		logic [4:0] rt_MEWB;
		logic [4:0] rd_MEWB;
		logic [4:0] sa_MEWB;
		logic [15:0] imm_MEWB;
		logic [25:0] JumpAddr_MEWB;
		logic [15:0] offset_MEWB;
		logic [5:0] rcode_MEWB;
		logic [31:0] immext_MEWB;
		assign opcode_MEWB		= back.imemload_MEWB[31:26];
		assign rs_MEWB			= back.imemload_MEWB[25:21];
		assign rt_MEWB			= back.imemload_MEWB[20:16];
		assign rd_MEWB			= back.imemload_MEWB[15:11];
		assign sa_MEWB			= back.imemload_MEWB[10:06];
		assign imm_MEWB			= back.imemload_MEWB[15:0];
		assign JumpAddr_MEWB	= back.imemload_MEWB[25:0];
		assign offset_MEWB		= back.imemload_MEWB[15:0];
		assign rcode_MEWB		= back.imemload_MEWB[5:0];

// PC
	word_t PC;	// pc current state
	// program counter stuff
	word_t PCnxt , PC4;// , PCelse;
	assign PC4 = PC + 4;
	assign ppEN = chaif.ihit & !back.halt_MEWB;// | chaif.dhit;//chaif.ilast;// | ((!back.cu_dmemREN_EXME & !back.cu_dmemWEN_EXME) | chaif.dfin);	// make system wait  for memory
	//assign mewbEN = chaif.dhit & back.cu_dmemREN_EXME;

	logic imemSameErr;
	assign imemSameErr=(back.imemload_IFID==back.imemload_IDEX);
	// same instruction loaded twice error



	assign PCnxt = (chaif.PC4EN)?PC4:chaif.PCelse;//back.PCelse_IDEX;

	//assign PCnxt = chaif.PC4EN?PC4:chaif.PCelse;//back.PCelse_IDEX;
	always_ff@(posedge CLK or negedge nRST) begin
		if(~nRST) begin
			PC <= PC_INIT;
		end else if(chaif.ihit /*& !chaif.halt*/ & !bubble)begin
			PC <= PCnxt;
			//PC <= PCtemp;
		end
	end

// halt
	logic haltff;
	always_ff@(negedge CLK or negedge nRST) begin
		if(~nRST/* & ~chaif.halt*/) begin
				haltff <= 0;
		end else begin if(back.halt_MEWB)begin
				haltff <= 1;
			end
		end
	end

// dpif stuff

	logic dmemRENPosEdge , dmemRENLast;
	assign dmemRENPosEdge = !dmemRENLast&chaif.cu_dmemREN_EXME;
	always_ff@(posedge CLK or negedge nRST) begin : cu_dmemREN_sync
		if(~nRST) begin
			dmemRENLast = 0;
		end else begin
			dmemRENLast = chaif.cu_dmemREN_EXME;
		end
	end

	logic dmemWENPosEdge , dmemWENLast;
	assign dmemWENPosEdge = !dmemWENLast&chaif.cu_dmemWEN_EXME;
	always_ff@(posedge CLK or negedge nRST) begin : cu_dmemWEN_sync
		if(~nRST) begin
			dmemWENLast = 0;
		end else begin
			dmemWENLast = chaif.cu_dmemWEN_EXME;
		end
	end








	assign dpif.imemaddr = PC;

	assign chaif.halt_MEWB = back.halt_MEWB;
//	assign dmemload	= dpif.dmemload;
	assign chaif.imemload = back.imemload_IFID;
//	assign dpif.imemREN		= chaif.imemREN;

//	assign dpif.dmemREN		= chaif.dmemREN;
//	assign dpif.dmemWEN		= chaif.dmemWEN;

	assign dpif.imemREN		= !haltff;//!bubble;
	assign dpif.dmemREN		= (chaif.dmemREN|dmemRENPosEdge);//&(!dpif.ihit);
	assign dpif.dmemWEN		= (chaif.dmemWEN|dmemWENPosEdge);//&(!dpif.ihit);

	assign chaif.cu_dmemREN_EXME = back.cu_dmemREN_EXME;
	assign chaif.cu_dmemWEN_EXME = back.cu_dmemWEN_EXME;

//	assign dpif.dmemstore	= dmemstore;
//	assign dpif.dmemaddr	= dmemaddr;
	assign dpif.dmemaddr	= back.dmemaddr_EXME;


	assign dpif.datomic		= 1'b1 & back.llsc_EXME;
	// not sure why but "make system" get stuck without the first part


	assign dpif.halt		= haltff;// & nRST;

	assign chaif.dhit = dpif.dhit;
	assign chaif.ihit = dpif.ihit&!(dpif.dmemREN|dpif.dmemWEN);

// instruction fetch
	/* instruction fetch - instruction decode regs
		word_t imemload_IFID , PC4_IFID;
		o_0
	*/
		assign front.imemload_IFID = dpif.imemload;
		assign front.PC4_IFID = PC4;// + 4;

// instruction decode
	/*	// instruction decode - execute
		word_t PC4_IDEX , PCelse_IDEX;		// PC stuff
		logic PC4EN_IDEX;
		word_t imemload_IDEX;	// from memory
		word_t rdat1_IDEX , rda2t_IDEX;		// to register file
		logic [0:0] cu_rWEN_IDEX;
		logic [1:0] wseles_IDEX , PCsel_IDEX , wdat_sel_IDEX , extmode_IDEX , op2sel_IDEX;	// mux selects
		logic [3:0] alucode_IDEX;
		logic [0:0] halt_IDEX , cu_dmemWEN_IDEX , cu_dmemREN_IDEX;
	*/
		assign front.PC4_IDEX			= back.PC4_IFID;
		assign front.PCelse_IDEX		= chaif.PCelse;
		assign front.PC4EN_IDEX			= chaif.PC4EN;
		assign front.imemload_IDEX		= back.imemload_IFID;
		assign front.rdat1_IDEX			= rfif.rdat1;
		assign front.rdat2_IDEX			= rfif.rdat2;
		assign front.cu_rWEN_IDEX		= chaif.cu_rWEN;
		assign front.wseles_IDEX		= chaif.wseles;
		assign front.PCsel_IDEX			= chaif.PCsel;
		assign front.wdat_sel_IDEX		= chaif.wdat_sel;
		assign front.extmode_IDEX		= chaif.extmode;
		assign front.op2sel_IDEX		= chaif.op2sel;
		//assign front.alucode_IDEX		= chaif.op2sel;
		assign front.alucode_IDEX		= chaif.alucode;
		assign chaif.alucode_IDEX		= back.alucode_IDEX;
		assign front.halt_IDEX			= chaif.halt;
		assign front.cu_dmemWEN_IDEX	= chaif.cu_dmemWEN_IFID;
		assign front.cu_dmemREN_IDEX	= chaif.cu_dmemREN_IFID;
		assign front.wsel_IDEX			= chaif.wsel_IFID;
		assign front.llsc_IDEX			= chaif.llsc;

// execute
	/*	// execute - memory
		// execute / memory
		word_t PC4_EXME , PCelse_EXME;		// pc stuff
		logic [0:0] PC4EN_EXME;
		word_t imemload_EXME;	// from memory
		word_t dmemstore_EXME , dmemaddr_EXME;	// to mem
		word_t rdat1_EXME, rdat2_EXME;		// to register file
		logic [0:0] cu_rWEN_EXME;
		logic [1:0] wseles_EXME, PCsel_EXME, wdat_sel_EXME, extmode_EXME;	// mux selects
		word_t alurst_EXME;			// alu stuff
		logic [0:0] zroflg_EXME;
		logic [0:0] halt_EXME, cu_dmemWEN_EXME, cu_dmemREN_EXME;
	*/
		assign front.PC4_EXME			= back.PC4_IDEX;
		assign front.PCelse_EXME		= back.PCelse_IDEX;
		assign front.PC4EN_EXME			= back.PC4EN_IDEX;
		assign front.imemload_EXME		= back.imemload_IDEX;
		assign front.dmemstore_EXME		= back.rdat2_IDEX;
		assign front.dmemaddr_EXME		= chaif.alurst;
		assign front.rdat1_EXME			= back.rdat1_IDEX;
		assign front.rdat2_EXME			= back.rdat2_IDEX;
		assign front.cu_rWEN_EXME		= back.cu_rWEN_IDEX;
		assign front.wseles_EXME		= back.wseles_IDEX;
		assign front.PCsel_EXME			= back.PCsel_IDEX;
		assign front.wdat_sel_EXME		= back.wdat_sel_IDEX;
		assign front.extmode_EXME		= back.extmode_IDEX;
		assign front.alurst_EXME		= chaif.alurst;
		assign front.zroflg_EXME		= chaif.zroflg;
		assign front.halt_EXME			= back.halt_IDEX;
		assign front.cu_dmemWEN_EXME	= back.cu_dmemWEN_IDEX;
		assign front.cu_dmemREN_EXME	= back.cu_dmemREN_IDEX;
		assign front.wsel_EXME			= back.wsel_IDEX;
		//assign front.dmemstore_IMAGINARY_EXME	= back.dmemstore_IMAGINARY_IDEX;
		//assign front.dmemstore_EARLY_EXME		= back.dmemstore_EARLY_IDEX;
		assign front.llsc_EXME			= back.llsc_IDEX;

// memory
	/*	// memory - write back
		word_t PC4_MEWB;
		word_t imemload_MEWB, dmemload_MEWB;	// from memory
		logic [0:0] cu_rWEN_MEWB;
		logic [1:0] wseles_MEWB, wdat_sel_MEWB, extmode_MEWB;	// mux selects
		word_t alurst_MEWB;			// alu stuff
		logic [0:0] halt_MEWB, cu_dmemWEN_MEWB, cu_dmemREN_MEWB;
	*/
		assign front.PC4_MEWB			= back.PC4_EXME;
		assign front.imemload_MEWB		= back.imemload_EXME;
		assign front.dmemload_MEWB		= dpif.dmemload;
		assign front.cu_rWEN_MEWB		= back.cu_rWEN_EXME;
		assign front.wseles_MEWB		= back.wseles_EXME;
		assign front.wdat_sel_MEWB		= back.wdat_sel_EXME;
		assign front.extmode_MEWB		= back.extmode_EXME;
		assign front.alurst_MEWB		= back.alurst_EXME;
		assign front.halt_MEWB			= back.halt_EXME;
		assign front.cu_dmemWEN_MEWB	= back.cu_dmemWEN_EXME;
		assign front.cu_dmemREN_MEWB	= back.cu_dmemREN_EXME;
		assign front.dhit_MEWB			= chaif.dhit;
		assign front.wsel_MEWB			= back.wsel_EXME;
		assign front.llsc_MEWB			= back.llsc_EXME;

		assign front.wdat_WBIM			= back.wdat_MEWB;
		assign front.wsel_WBIM			= back.wsel_MEWB;
		assign front.cu_rWEN_WBIM		= back.cu_rWEN_MEWB;
// dmemload buffer
	word_t dmemload_buffer;
	always_ff@(posedge CLK or negedge nRST) begin : dmemload_buffer_reg
		if(~nRST) begin
			dmemload_buffer = 0;
		end else if(chaif.dhit) begin
			dmemload_buffer = dpif.dmemload;
		end
	end



// datapath muxes
	assign rfif.rsel1 = rs_IFID;
	assign rfif.rsel2 = rt_IFID;

/*	always_comb begin : rfifWEN
		rfif.WEN = 0;
		if(back.cu_rWEN_MEWB)begin
			if(back.cu_dmemREN_MEWB)begin			// when load occurs..
				rfif.WEN = back.dhit_MEWB;		// edge trigger for load
			end else begin
				rfif.WEN = 1;					// level trigger for r type
			end
		end
	end*/
	assign rfif.WEN = back.cu_rWEN_MEWB;

	always_comb begin : mewb_pipeline_latch_enable
		mewbEN = 0;
		if(back.cu_dmemREN_EXME)begin			// when load occurs..
			mewbEN = chaif.dhit;
		end else begin
			mewbEN = chaif.ihit;
		end
	end

//	assign rfif.WEN = back.cu_rWEN_MEWB &(	(back.cu_dmemREN_MEWB & back.dhit_MEWB)
//											|
//						(!back.cu_dmemREN_MEWB & ppEN)/*
//											|
//						(chaif.dlast & back.cu_dmemREN_MEWB)*/);
//						/*(chaif.dhit & back.cu_dmemREN_EXME)*/
//

// dmemstore merge:
	/*
	do the same thing for dememstore as wdat

	*/
	always_comb begin : dmemstore_early_arrive_deside	// a me to ex stage forward unit
		front.dmemstore_IMAGINARY_EXME = 'bx;
		front.dmemstore_EARLY_EXME = 0;
		if((rt_IDEX==back.wsel_MEWB)
			&& (rt_IDEX!=0)
			&& (back.cu_rWEN_MEWB!=0)
			)begin
			front.dmemstore_IMAGINARY_EXME = back.wdat_MEWB;
			front.dmemstore_EARLY_EXME = 1;
		end
	end

	int whatIsGlueLogic;//(temp)
	always_comb begin : dmemstore_merge
		dpif.dmemstore  = 32'habcdefdc;	// impossible case delatch
		if((back.wsel_MEWB==rt_EXME)&&(back.wsel_MEWB!=0)&&(back.cu_rWEN_MEWB!=0))begin	// exme hazard case
			dpif.dmemstore = back.wdat_MEWB;
			whatIsGlueLogic = 1;
		end else if(back.dmemstore_EARLY_EXME)begin	// mewb was on bus but is sent into rf now
			dpif.dmemstore = back.dmemstore_IMAGINARY_EXME;
			whatIsGlueLogic = 2;
		end else begin				// no hazard
			dpif.dmemstore = back.rdat2_EXME;
			whatIsGlueLogic = 3;
		end
	end

// wdat merge
	/*
		wdat merge:
			pipe a 32 bits wdat register from idex to mewb, along with a one bit wdat ready signal.
			the wdat register will be given value as early as possible depending on the wdat_sel signal
			given by control unit. once the wdat is given the corrent value for the instruction, the
			wdat_ready signal will be asserted so that the following stages will know the wdat does not need
			to be muxed again.

	*/
	always_comb begin : wdat_merge_id
		front.wdat_IDEX = 'bx;
		front.wdat_ready_IDEX = 0;
		// in this stage value to wdat is always yet to be written
			if(chaif.wdat_sel == WDAT_PC4)begin
				front.wdat_IDEX = back.PC4_IFID;
				front.wdat_ready_IDEX = 1;	// assert ready flag
			end else if(chaif.wdat_sel == WDAT_LUI)begin
				front.wdat_IDEX = {imm_IFID , 16'b0};
				front.wdat_ready_IDEX = 1;
			end
	end
	always_comb begin : wdat_merge_ex
		front.wdat_EXME = back.wdat_IDEX;
		front.wdat_ready_EXME = back.wdat_ready_IDEX;
		if(!back.wdat_ready_IDEX)begin	// value to wdat is yet to be written
			if(back.wdat_sel_IDEX == WDAT_ALU)begin
				front.wdat_EXME = chaif.alurst;
				front.wdat_ready_EXME = 1;	// assert ready flag
			end else if(back.wdat_sel_IDEX == WDAT_MEM)begin	// if it's mem load,put alu result into wdat bus for supplying address to future
				front.wdat_EXME = chaif.alurst;					// but data is not ready..
			end
		end
	end

	always_comb begin : wdat_merge_me
		front.wdat_MEWB = back.wdat_EXME;
		front.wdat_ready_MEWB = back.wdat_ready_EXME;
		if(!back.wdat_ready_EXME)begin	// logically this should be an always taken
			if(back.wdat_sel_EXME == WDAT_MEM)begin
				front.wdat_MEWB = dmemload_buffer;
				front.wdat_ready_MEWB = 1;	// assert ready flag, but not actually useful at this point..
			end
		end
	end
	assign rfif.wdat = back.wdat_MEWB;

// data hazard
	logic ppErr[10];	// just to incase
	/*
		DATA HAZARD!!!
		oprand 1:
			oprand 1 always select rdat from sa so if rs_IDEX == wseles_EXME(not literally)
			then forward wdat to oprand1
		oprand 1 used to be:
			assign chaif.oprnd1 = back.rdat1_IDEX;
		note:
			all dataforward need to be && with WEN

		NOTE:::::
			Everything related to register read(op1,op2,dstore..)
			are put into this giant block..probably not a very good styel..
	*/

	/*
		dmemstore also need forward since it involves register read
		original dmemstore:
		assign dpif.dmemstore = back.rdat2_EXME;
	*/
	word_t brop1 , brop2;	// BRanch OPerand
	int debug;
	always_comb begin : register_directions//dmemstore_forward
		ppstop = 0;

	//end
	//always_comb begin : oprnd1_forward
		ppErr[1] = 0;
		chaif.oprnd1  = 32'habcdefdc;	// impossible case delatch
		if((back.wsel_EXME==rs_IDEX)&&(back.wsel_EXME!=0)&&(back.cu_rWEN_EXME!=0))begin	// exme foward
				chaif.oprnd1 = back.wdat_EXME;
				debug = 1;
		end else if((rfif.wsel==rs_IDEX)&&(rfif.wsel!=0)&&(back.cu_rWEN_MEWB!=0))begin // forward from MEWB latch
			chaif.oprnd1 = rfif.wdat;
			debug = 0;
		end else if((back.wsel_WBIM==rs_IDEX)&&(back.wsel_WBIM!=0)&&(back.cu_rWEN_WBIM!=0))begin // forward from MEWB latch
			debug = 6;
			chaif.oprnd1 = back.wdat_WBIM;
		end else begin
			debug = 2;
			chaif.oprnd1 = back.rdat1_IDEX;
		end
	//end



	//	oprand2:
	//		basically same as oprand 1


	//always_comb begin : oprnd2_mux_and_forward
		chaif.oprnd2  = 32'habcdefdc;	// impossible case delatch
		if(back.op2sel_IDEX == OP2_RDAT)begin	// only this if branch need to be changed for data forward
			if((back.wsel_EXME==rt_IDEX)&&(back.wsel_EXME!=0)&&(back.cu_rWEN_EXME!=0))begin	// forward from EXME latch
					chaif.oprnd2 = back.wdat_EXME;
			end else if((rfif.wsel==rt_IDEX)&&(rfif.wsel!=0)&&(back.cu_rWEN_MEWB!=0))begin // forward from MEWB latch
				chaif.oprnd2 = rfif.wdat;
			end else begin
				chaif.oprnd2 = back.rdat2_IDEX;
			end
		end else if(back.op2sel_IDEX == OP2_SA)begin
			chaif.oprnd2  = {27'd0 , sa_IDEX};
		end else if(back.op2sel_IDEX == OP2_IMM)begin
			chaif.oprnd2  = immext_IDEX;
		end else begin
			chaif.oprnd2  = 32'dx;
		end
	//end


	//	branch operands:
	//		these are even earlier than alu operand

	//always_comb begin
		brop1 = 32'hfedcba98;
		brop2 = 32'hfedcba98;


		// new stuff to solve LUI followed by branch - monday Sep30
		// Nov01: added &&back.cu_rWEN_IDEX to every branch of this block to solve a SW$12,$12,0x1000->bne$12,$0..
		if((back.wsel_IDEX==rfif.rsel1)&&(back.wsel_IDEX!=0)&&back.cu_rWEN_IDEX)begin
			if(back.wdat_ready_IDEX)begin
				brop1 = back.wdat_IDEX;
			end else begin
				brop1 = 32'haaaaaacb;
			end
		end else
		// end new stuff

		if((back.wsel_EXME==rfif.rsel1)&&(back.wsel_EXME!=0)&&back.cu_rWEN_EXME)begin		// branch condition is in exme latch
			if(back.wdat_sel_EXME == WDAT_ALU)begin
				brop1  = back.alurst_EXME;
			end else if(back.wdat_sel_EXME == WDAT_LUI)begin
				brop1  = {imm_EXME , 16'b0};
			end else if(back.wdat_sel_EXME == WDAT_MEM)begin		// need bubble here...
				brop1  = 32'hfedabeca;		// need to fix this but don't know how...
			end else if(back.wdat_sel_EXME == WDAT_PC4)begin
				brop1  = back.PC4_EXME;
			end else begin
				brop1 = 32'h76576576;
			end
		end else if((rfif.wsel==rfif.rsel1)&&back.cu_rWEN_MEWB)begin	// branch condition is in mewb stage
			brop1 = rfif.wdat;
		end else begin
			brop1 = rfif.rdat1;
		end


		// new stuff to solve LUI followed by branch - monday Sep30
		if((back.wsel_IDEX==rfif.rsel2)&&(back.wsel_IDEX!=0)&&back.cu_rWEN_IDEX)begin
			if(back.wdat_ready_IDEX)begin
				brop2 = back.wdat_IDEX;
			end
		end else
		// end new stuff

		if((back.wsel_EXME==rfif.rsel2)&&(back.wsel_EXME!=0)&&back.cu_rWEN_EXME)begin		// branch condition is in exme latch
			if(back.wdat_sel_EXME == WDAT_ALU)begin
				brop2  = back.alurst_EXME;
			end else if(back.wdat_sel_EXME == WDAT_LUI)begin
				brop2  = {imm_EXME , 16'b0};
			end else if(back.wdat_sel_EXME == WDAT_MEM)begin		// need bubble here...
				brop2  = 32'hfedabeca;		// need to fix this but don't know how...
			end else if(back.wdat_sel_EXME == WDAT_PC4)begin
				brop2  = back.PC4_EXME;
			end
		end else if((rfif.wsel==rfif.rsel2)&&back.cu_rWEN_MEWB)begin
			brop2 = rfif.wdat;
		end else begin
			brop2 = rfif.rdat2;
		end
	end

// simple muxes
	always_comb begin : imm_idex_extender
		if(back.extmode_IDEX == EXT_ZERO)begin
			immext_IDEX = {16'b0 , imm_IDEX};
		end else if(back.extmode_IDEX == EXT_ONE)begin
			immext_IDEX = {16'hffff , imm_IDEX};
		end else if(back.extmode_IDEX == EXT_SIGN)begin
			if(imm_IDEX[15])begin
				immext_IDEX = {16'hffff , imm_IDEX};
			end else begin
				immext_IDEX = {16'b0 , imm_IDEX};
			end
		end else begin		// impossible case
			immext_IDEX = 'dx;
		end
	end

	always_comb begin : imm_ifid_extender
		if(chaif.extmode == EXT_ZERO)begin
			immext_IFID = {16'b0 , imm_IFID};
		end else if(chaif.extmode == EXT_ONE)begin
			immext_IFID = {16'hffff , imm_IFID};
		end else if(chaif.extmode == EXT_SIGN)begin
			if(imm_IFID[15])begin
				immext_IFID = {16'hffff , imm_IFID};
			end else begin
				immext_IFID = {16'b0 , imm_IFID};
			end
		end else begin		// impossible case
			immext_IFID = 'dx;
		end
	end

	// generate wsel in ID stage and propagate to others since wsel is already calculate-able in ID
	always_comb begin:wsel_Generate
		if(chaif.wseles==WSEL_RT)chaif.wsel_IFID = rt_IFID;
		else if(chaif.wseles==WSEL_RD)chaif.wsel_IFID = rd_IFID;
		else if(chaif.wseles==WSEL_31)chaif.wsel_IFID = 31;
		else chaif.wsel_IFID = 0;
	end

	assign rfif.wsel = back.wsel_MEWB;
	/*
		current design
		program counter next state value is caluclated at
		instruction decode phase, different from book
		same as last design in lecture slide,to minimize
		pipeline dump after BEQ BNE condition taken and
		J JR instruction decode, BEQ BNE condition is
		realized in ID phase by taken=(rdat1==rdat2)
	*/


	always_comb begin : PCelse_select
		if(chaif.PCsel == PC_JR)begin	// this thing needs forward too..

			if((back.wsel_EXME==rfif.rsel1)&&(back.wsel_EXME!=0)&&back.cu_rWEN_EXME)begin		// jump addr is in exme latch
				if(back.wdat_sel_EXME == WDAT_ALU)begin
					chaif.PCelse  = back.alurst_EXME;
				end else if(back.wdat_sel_EXME == WDAT_LUI)begin
					chaif.PCelse  = {imm_EXME , 16'b0};
				//end else if(back.wdat_sel_EXME == WDAT_MEM)begin		// need bubble here...
				//	chaif.PCelse  = 32'hfedabeca;		// this does not exist because there will be bubble
				end else if(back.wdat_sel_EXME == WDAT_PC4)begin
					chaif.PCelse  = back.PC4_EXME;
				end else begin
					chaif.PCelse = 32'h76576576;
				end
			end else if((rfif.wsel==rfif.rsel1)&&back.cu_rWEN_MEWB)begin	// branch condition is in mewb stage
				chaif.PCelse = rfif.wdat;
			end else begin
				chaif.PCelse = rfif.rdat1;
			end
		end else if(chaif.PCsel == PC_JI)begin
			chaif.PCelse =  {back.PC4_IFID[31:28] , JumpAddr_IFID , 2'b00};
		end else if(chaif.PCsel == PC_BEQ)begin
			if(brop1==brop2)begin
				chaif.PCelse = back.PC4_IFID+{immext_IFID[29:0] , 2'b00};
			end else begin
				chaif.PCelse = back.PC4_IFID;
			end
		end else if(chaif.PCsel == PC_BNE)begin
			if(brop1==brop2)begin
				chaif.PCelse = back.PC4_IFID;
			end else begin
				chaif.PCelse = back.PC4_IFID+{immext_IFID[29:0] , 2'b00};
			end
		end else begin		// this is a impossible case, only used for anti-latch
			chaif.PCelse = PC4;
		end
	end

	/*
		ifidKill:
		// if branch or jump, flush IFID latch, jump might need more..
		// the previous cases all need to flush immeload in IFID latch
	*/

	assign ifidKill = !chaif.PC4EN;
	/*
		idrequest: register read request at Instruction Decode stage,
		coming from instruction=(branch/jr),is a way to detect bubble needed
	*/
	logic idrequest;
	assign idrequest = !chaif.PC4EN&(chaif.PCsel != PC_JI);
	logic LW_IDEX;	// detect a lw at IDex stage,used for bubbling
	assign LW_IDEX = back.cu_dmemREN_IDEX | (back.cu_dmemWEN_IDEX&back.llsc_IDEX);		// need to handle both LW and SC, added second part 11/13/2013
	logic ID_read;	// indicates there is a register read request at ID stage, might cause a data hazard, might need bubble
	assign ID_read = !((opcode_IFID==LUI)|(opcode_IFID==JAL)|(opcode_IFID==J));
	logic IF_write;	// indicates there is a register write request at ID stage, might cause a data hazard, might need bubble
	assign IF_write = back.cu_rWEN_IDEX;

	logic LW_EXME;
	assign LW_EXME = back.cu_dmemREN_EXME | (back.cu_dmemWEN_EXME&back.llsc_EXME);		// need to handle both LW and SC, added second part 11/13/2013

	//logic sgbb , dbbb;
	assign sgbb = (
					(LW_IDEX & ID_read &
						(
							( (rfif.rsel1==back.wsel_IDEX)&(rfif.rsel1!=0) )
							|( (rfif.rsel2==back.wsel_IDEX)&(rfif.rsel2!=0) )


						)
					)
					|(IF_write & idrequest &
						(
							((rfif.rsel1==back.wsel_IDEX)&(rfif.rsel1!=0))
							|((rfif.rsel2==back.wsel_IDEX)&(rfif.rsel2!=0))

						)
					)
					|(
						LW_EXME & idrequest &
						(
							// cannot believe this thing is wrong...
							// corrected from wsel_IDEX to EXME on 11/14/2013
							((rfif.rsel1==back.wsel_EXME)&(rfif.rsel1!=0))
							|((rfif.rsel2==back.wsel_EXME)&(rfif.rsel2!=0))
						)
					)
				);
	assign dbbb = LW_IDEX & idrequest & (((rfif.rsel1==back.wsel_IDEX)&(rfif.rsel1!=0)) | ((rfif.rsel2==back.wsel_IDEX)&(rfif.rsel2!=0)) );


	// latch double bubble for one pipeline period
	always_ff@(posedge CLK or negedge nRST) begin : double_bubble_register
		if(~nRST) begin
			dbbb_last = 0;
		end else if(ppEN) begin
			dbbb_last = dbbb;
		end
	end

endmodule
