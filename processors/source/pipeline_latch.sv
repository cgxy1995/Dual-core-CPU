/*
	pipeline latch.sv

	Mingfei Huang
	huang243@purdue.edu

*/

// all types
`include "cpu_types_pkg.vh"
`include "control_sel_pkg.vh"
`include "pipeline_latch_if.vh"
import cpu_types_pkg::*;
import control_sel_pkg::*;

module pipeline_latch(
	pipeline_front_if.ppl front,
	pipeline_back_if.ppl back,
	input logic CLK , nRST , ppEN , mewbEN , ifidKill/*synchronized reset*/
	,bubble
	//,logic [3:0] ppstop
);
logic [3:0] ppstop;
assign ppstop=0;
// stages:
	/* instruction fetch - instruction decode regs
		word_t imemload_IFID , PC4_IFID;
		o_0
	*/
	always_ff@(posedge CLK or negedge nRST) begin : if_id_latch
		if(~nRST) begin
			back.imemload_IFID <= NOP;
			back.PC4_IFID <= 'bx;
		end else if(ppEN&(!bubble)/*&(!ppstop[IFID])&(!ppstop[IDEX])&(!ppstop[EXME])*/)begin
			if(ifidKill)begin		// how bubble is done
				back.imemload_IFID <= NOP;
				back.PC4_IFID <= 32'haaaaaaaa;
			end else begin
				back.imemload_IFID <= front.imemload_IFID;
				back.PC4_IFID <= front.PC4_IFID;
			end
		end
	end

	/*	// instruction decode - execute
		word_t PC4_IDEX , PCelse_IDEX;		// PC stuff
		logic PC4EN_IDEX;
		word_t imemload_IDEX;	// from memory
		word_t rdat1_IDEX , rdat2_IDEX;		// to register file
		logic  cu_rWEN_IDEX;
		logic [1:0] wseles_IDEX , PCsel_IDEX , wdat_sel_IDEX , extmode_IDEX , op2sel_IDEX;	// mux selects
		logic [3:0] alucode_IDEX;
		logic  halt_IDEX , cu_dmemWEN_IDEX , cu_dmemREN_IDEX;
	*/
	always_ff@(posedge CLK or negedge nRST) begin : id_ex_latch
		if(~nRST) begin
			back.PC4_IDEX			<= 'bx;
			back.PCelse_IDEX		<= 'bx;
			back.PC4EN_IDEX			<= 1;
			back.imemload_IDEX		<= NOP;
			back.rdat1_IDEX			<= 'bx;
			back.rdat2_IDEX			<= 'bx;
			back.cu_rWEN_IDEX		<= 0;
			back.wseles_IDEX		<= 'bx;
			back.PCsel_IDEX			<= 'bx;
			back.wdat_sel_IDEX		<= 'bx;
			back.extmode_IDEX		<= 'bx;
			back.op2sel_IDEX		<= 'bx;
			back.alucode_IDEX		<= 'bx;
			back.halt_IDEX			<= 0;
			back.cu_dmemWEN_IDEX	<= 0;
			back.cu_dmemREN_IDEX	<= 0;
			back.wsel_IDEX			<= 'bx;
			back.wdat_IDEX			<= 'bx;
			back.wdat_ready_IDEX	<= 0;
			back.llsc_IDEX			<= 0;
		end else if(ppEN)begin
			if(bubble)begin
				back.PC4_IDEX			<= 0;
				back.PCelse_IDEX		<= 0;
				back.PC4EN_IDEX			<= 0;
				back.imemload_IDEX		<= 0;
				back.rdat1_IDEX			<= 0;
				back.rdat2_IDEX			<= 0;
				back.cu_rWEN_IDEX		<= 0;
				back.wseles_IDEX		<= 0;
				back.PCsel_IDEX			<= 0;
				back.wdat_sel_IDEX		<= 0;
				back.extmode_IDEX		<= 0;
				back.op2sel_IDEX		<= 0;
				back.alucode_IDEX		<= 0;
				back.halt_IDEX			<= 0;
				back.cu_dmemWEN_IDEX	<= 0;
				back.cu_dmemREN_IDEX	<= 0;
				back.wsel_IDEX			<= 0;
				back.wdat_IDEX			<= 0;
				back.wdat_ready_IDEX	<= 0;
				back.dmemstore_IMAGINARY_IDEX	<= 0;
				back.dmemstore_EARLY_IDEX		<= 0;
				back.llsc_IDEX			<= 0;
			end else begin
				back.PC4_IDEX			<= front.PC4_IDEX;
				back.PCelse_IDEX		<= front.PCelse_IDEX;
				back.PC4EN_IDEX			<= front.PC4EN_IDEX;
				back.imemload_IDEX		<= front.imemload_IDEX;
				back.rdat1_IDEX			<= front.rdat1_IDEX;
				back.rdat2_IDEX			<= front.rdat2_IDEX;
				back.cu_rWEN_IDEX		<= front.cu_rWEN_IDEX;
				back.wseles_IDEX		<= front.wseles_IDEX;
				back.PCsel_IDEX			<= front.PCsel_IDEX;
				back.wdat_sel_IDEX		<= front.wdat_sel_IDEX;
				back.extmode_IDEX		<= front.extmode_IDEX;
				back.op2sel_IDEX		<= front.op2sel_IDEX;
				back.alucode_IDEX		<= front.alucode_IDEX;
				back.halt_IDEX			<= front.halt_IDEX;
				back.cu_dmemWEN_IDEX	<= front.cu_dmemWEN_IDEX;
				back.cu_dmemREN_IDEX	<= front.cu_dmemREN_IDEX;
				back.wsel_IDEX			<= front.wsel_IDEX;
				back.wdat_IDEX			<= front.wdat_IDEX;
				back.wdat_ready_IDEX	<= front.wdat_ready_IDEX;
				back.dmemstore_IMAGINARY_IDEX	<= front.dmemstore_IMAGINARY_IDEX;
				back.dmemstore_EARLY_IDEX		<= front.dmemstore_EARLY_IDEX;
				back.llsc_IDEX			<= front.llsc_IDEX;
			end
		end
	end

	/*	// execute - memory
		// execute / memory
		word_t PC4_EXME , PCelse_EXME;		// pc stuff
		logic  PC4EN_EXME;
		word_t imemload_EXME;	// from memory
		word_t dmemstore_EXME , dmemaddr_EXME;	// to mem
		word_t rdat1_EXME, rdat2_EXME;		// to register file
		logic  cu_rWEN_EXME;
		logic [1:0] wseles_EXME, PCsel_EXME, wdat_sel_EXME, extmode_EXME;	// mux selects
		word_t alurst_EXME;			// alu stuff
		logic  zroflg_EXME;
		logic  halt_EXME, cu_dmemWEN_EXME, cu_dmemREN_EXME;
	*/
	always_ff@(posedge CLK or negedge nRST) begin : ex_me_latch
		if(~nRST) begin
			back.PC4_EXME			<= 'bx;
			back.PCelse_EXME		<= 'bx;
			back.PC4EN_EXME			<= 1;
			back.imemload_EXME		<= NOP;
			back.dmemstore_EXME		<= 'bx;
			back.dmemaddr_EXME		<= 'bx;
			back.rdat1_EXME			<= 'bx;
			back.rdat2_EXME			<= 'bx;
			back.cu_rWEN_EXME		<= 0;
			back.wseles_EXME		<= 'bx;
			back.PCsel_EXME			<= 'bx;
			back.wdat_sel_EXME		<= 'bx;
			back.extmode_EXME		<= 'bx;
			back.alurst_EXME		<= 'bx;
			back.zroflg_EXME		<= 'bx;
			back.halt_EXME			<= 0;
			back.cu_dmemWEN_EXME	<= 0;
			back.cu_dmemREN_EXME	<= 0;
			back.wsel_EXME			<= 'bx;
			back.wdat_EXME			<= 'bx;
			back.wdat_ready_EXME	<= 0;
			back.dmemstore_IMAGINARY_EXME	<= 0;
			back.dmemstore_EARLY_EXME		<= 0;
			back.llsc_EXME			<= 0;
		end else if(ppEN)begin
			back.PC4_EXME			<= front.PC4_EXME;
			back.PCelse_EXME		<= front.PCelse_EXME;
			back.PC4EN_EXME			<= front.PC4EN_EXME;
			back.imemload_EXME		<= front.imemload_EXME;
			back.dmemstore_EXME		<= front.dmemstore_EXME;
			back.dmemaddr_EXME		<= front.dmemaddr_EXME;
			back.rdat1_EXME			<= front.rdat1_EXME;
			back.rdat2_EXME			<= front.rdat2_EXME;
			back.cu_rWEN_EXME		<= front.cu_rWEN_EXME;
			back.wseles_EXME		<= front.wseles_EXME;
			back.PCsel_EXME			<= front.PCsel_EXME;
			back.wdat_sel_EXME		<= front.wdat_sel_EXME;
			back.extmode_EXME		<= front.extmode_EXME;
			back.alurst_EXME		<= front.alurst_EXME;
			back.zroflg_EXME		<= front.zroflg_EXME;
			back.halt_EXME			<= front.halt_EXME;
			back.cu_dmemWEN_EXME	<= front.cu_dmemWEN_EXME;
			back.cu_dmemREN_EXME	<= front.cu_dmemREN_EXME;
			back.wsel_EXME			<= front.wsel_EXME;
			back.wdat_EXME			<= front.wdat_EXME;
			back.wdat_ready_EXME	<= front.wdat_ready_EXME;
			back.dmemstore_IMAGINARY_EXME	<= front.dmemstore_IMAGINARY_EXME;
			back.dmemstore_EARLY_EXME		<= front.dmemstore_EARLY_EXME;
			back.llsc_EXME			<= front.llsc_EXME;
		end
	end

	/*	// memory - write back
		// memory / write back
		word_t PC4_MEWB;
		word_t imemload_MEWB, dmemload_MEWB;	// from memory
		logic  cu_rWEN_MEWB;
		logic [1:0] wseles_MEWB, wdat_sel_MEWB, extmode_MEWB;	// mux selects
		word_t alurst_MEWB;			// alu stuff
		logic  halt_MEWB, cu_dmemWEN_MEWB, cu_dmemREN_MEWB;
	*/
	always_ff@(posedge CLK or negedge nRST) begin : me_wb_latch
		if(~nRST) begin
			back.PC4_MEWB			<= 'bx;
			back.imemload_MEWB		<=  NOP;
			back.dmemload_MEWB		<= 'bx;
			back.cu_rWEN_MEWB		<=  0;
			back.wseles_MEWB		<= 'bx;
			back.wdat_sel_MEWB		<= 'bx;
			back.extmode_MEWB		<= 'bx;
			back.alurst_MEWB		<= 'bx;
			back.halt_MEWB			<=  0;
			back.cu_dmemWEN_MEWB	<=  0;
			back.cu_dmemREN_MEWB	<=  0;
			back.dhit_MEWB			<=  0;
			back.wsel_MEWB			<= 'bx;
			back.wdat_MEWB			<= 'bx;
			back.wdat_ready_MEWB	<= 0;
			back.llsc_MEWB			<= 0;
		end else if(/*mewbEN*/ppEN)begin					// NOTE HERE, THIS IS DIFFERENT!!
			back.PC4_MEWB			<= front.PC4_MEWB;
			back.imemload_MEWB		<= front.imemload_MEWB;
			back.dmemload_MEWB		<= front.dmemload_MEWB;
			back.cu_rWEN_MEWB		<= front.cu_rWEN_MEWB;
			back.wseles_MEWB		<= front.wseles_MEWB;
			back.wdat_sel_MEWB		<= front.wdat_sel_MEWB;
			back.extmode_MEWB		<= front.extmode_MEWB;
			back.alurst_MEWB		<= front.alurst_MEWB;
			back.halt_MEWB			<= front.halt_MEWB;
			back.cu_dmemWEN_MEWB	<= front.cu_dmemWEN_MEWB;
			back.cu_dmemREN_MEWB	<= front.cu_dmemREN_MEWB;
			back.dhit_MEWB			<= front.dhit_MEWB;
			back.wsel_MEWB			<= front.wsel_MEWB;
			back.wdat_MEWB			<= front.wdat_MEWB;
			back.wdat_ready_MEWB	<= front.wdat_ready_MEWB;
			back.llsc_MEWB			<= front.llsc_MEWB;
		end
	end
	always_ff@(posedge CLK or negedge nRST) begin : proc_
		if(~nRST) begin
			back.wdat_WBIM		<= 'bx;
			back.wsel_WBIM		<= 'bx;
			back.cu_rWEN_WBIM	<= 0;
		end else begin
			back.wdat_WBIM		<= front.wdat_WBIM;
			back.wsel_WBIM		<= front.wsel_WBIM;
			back.cu_rWEN_WBIM	<= front.cu_rWEN_WBIM;
		end
	end
endmodule
