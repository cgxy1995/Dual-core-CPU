/*
	Eric Villasenor
	evillase@gmail.com

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

module Control_unit_tb;
	// import types
	import cpu_types_pkg::*;
	import control_sel_pkg::*;

	// pc init
	parameter PC_INIT = 0;

	// start from here is personal code


	parameter PERIOD = 10;

	logic CLK;
	logic nRST;
	string spec,opc;

// downward interfaces
	register_file_if rfif();
	control_hazard_alu_if chaif();
	register_file regfile(
		rfif,
		CLK,
		nRST
	);
	Alu alu(chaif);
	Control_unit CU(chaif);
	hazard_unit HU(CLK , nRST , chaif);
	fake_imem FI(chaif);

// temp values for easier expression
	logic [5:0] opcode;
	logic [4:0] rs;
	logic [4:0] rt;
	logic [4:0] rd;
	logic [4:0] sa;
	logic [15:0] imm;
	logic [25:0] JumpAddr;
	logic [15:0] offset;
	logic [5:0] rcode;
	logic [31:0] immext;
	assign opcode		 = chaif.imemload[31:26];
	assign rs			 = chaif.imemload[25:21];
	assign rt			 = chaif.imemload[20:16];
	assign rd			 = chaif.imemload[15:11];
	assign sa			 = chaif.imemload[10:06];
	assign imm			 = chaif.imemload[15:0];
	assign JumpAddr		 = chaif.imemload[25:0];
	assign offset		 = chaif.imemload[15:0];
	assign rcode		 = chaif.imemload[5:0];

	task printmsg (input [5:0] rcode , [5:0] op);
		if(op==0)begin
			case(rcode)
				6'b000000:spec="SLL";
				6'b000010:spec="SRL";
				6'b001000:spec="JR";
				6'b100000:spec="ADD";
				6'b100001:spec="ADDU";
				6'b100010:spec="SUB";
				6'b100011:spec="SUBU";
				6'b100100:spec="AND";
				6'b100101:spec="OR";
				6'b100110:spec="XOR";
				6'b100111:spec="NOR";
				6'b101010:spec="SLT";
				6'b101011:spec="SLTU";
				default:spec="UNKNOWN";
			endcase	// alucode print
		end else begin
			$sformat(spec, "%6b", rcode);
		end
		case(opcode)
			6'b000000:opc="RTYPE";
			6'b000010:opc="J";
			6'b000011:opc="JAL";
			6'b000100:opc="BEQ";
			6'b000101:opc="BNE";
			6'b001000:opc="ADDI";
			6'b001001:opc="ADDIU";
			6'b001010:opc="SLTI";
			6'b001011:opc="SLTIU";
			6'b001100:opc="ANDI";
			6'b001101:opc="ORI";
			6'b001110:opc="XORI";
			6'b001111:opc="LUI";
			6'b100011:opc="LW";
			6'b100100:opc="LBU";
			6'b100101:opc="LHU";
			6'b101000:opc="SB";
			6'b101001:opc="SH";
			6'b101011:opc="SW";
			6'b110000:opc="LL";
			6'b111000:opc="SC";
			6'b111111:opc="HALT";
			6'b000000:opc="SLL";
			6'b000010:opc="SRL";
			6'b001000:opc="JR";
			6'b100000:opc="ADD";
			6'b100001:opc="ADDU";
			6'b100010:opc="SUB";
			6'b100011:opc="SUBU";
			6'b100100:opc="AND";
			6'b100101:opc="OR";
			6'b100110:opc="XOR";
			6'b100111:opc="NOR";
			6'b101010:opc="SLT";
			6'b101011:opc="SLTU";
			default:opc="UNKNOWN!!";
		endcase
	endtask

	always #(PERIOD/2) CLK++;

	initial begin
		nRST = 0;
		#PERIOD;
		nRST = 1;
	end

// PC
	word_t PC;	// pc current state
	assign chaif.PC = PC;
	// program counter stuff
	word_t PCtemp , PCnxt , PC4 , PCelse;
	assign PC4 = PC + 4;
	always@(chaif.halt , chaif.ilast) begin : PC_next_state
		if(chaif.halt | !chaif.ilast)begin
			PCtemp=PC;
		end else begin
			PCtemp=PCnxt;
		end
	end

	assign PCnxt = chaif.PC4EN?PC4:PCelse;
	always@(posedge CLK or negedge nRST) begin
		if(~nRST) begin
			PC <= PC_INIT;
		end else begin
			PC <= PCtemp;
		end
	end

	logic haltff;
	always@(negedge CLK or negedge nRST) begin
		if(~nRST/* & ~chaif.halt*/) begin
				haltff <= 0;
		end else begin if(chaif.halt)begin
				haltff <= 1;
			end
		end
	end

	word_t dmemstore , dmemload , dmemaddr;
	logic dhit , ihit;
	assign chaif.dhit = dhit;
	assign chaif.ihit = ihit;
	always begin
		#(PERIOD*3);
		ihit = 1;
		#(PERIOD);
		ihit = 0;
	end

	logic dfin;
	always@(*)begin
		chaif.ilast = 0;
		if(~nRST)begin
			chaif.ilast = 0;
			dfin = 0;
		end else if(ihit)begin
			dfin = 0;
			chaif.ilast = 1;
		end else if(dhit)begin
			dfin = 1;
		end
	end



// datapth muxes
	assign chaif.oprnd1 = rfif.rdat1;
	assign dmemaddr = chaif.alurst;
	assign dmemstore = rfif.rdat2;
	assign rfif.rsel1 = rs;
	assign rfif.rsel2 = rt;
	assign rfif.WEN = chaif.cu_rWEN & (chaif.cu_dmemREN & chaif.dhit) | chaif.cu_rWEN&(!chaif.cu_dmemREN)&chaif.ilast;

	always@(chaif.op2sel) begin : oprnd2_mux
		if(chaif.op2sel == OP2_RDAT)begin
			chaif.oprnd2  = rfif.rdat2;
		end else if(chaif.op2sel == OP2_SA)begin
			chaif.oprnd2  = sa;
		end else if(chaif.op2sel == OP2_IMM)begin
			chaif.oprnd2  = immext;
		end else begin
			chaif.oprnd2  = 32'dx;
		end
	end

	always@(chaif.extmode) begin : imm_extender
		if(chaif.extmode == EXT_ZERO)begin
			immext = {16'b0 , imm};
		end else if(chaif.extmode == EXT_ONE)begin
			immext = {16'hffff , imm};
		end else if(chaif.extmode == EXT_SIGN)begin
			if(imm[15])begin
				immext = {16'hffff , imm};
			end else begin
				immext = {16'b0 , imm};
			end
		end else begin		// impossible case
			immext = 'dx;
		end
	end
	always@(chaif.wseles) begin : wsel_select
		if(chaif.wseles == WSEL_RT)begin
			rfif.wsel  = rt;
		end else if(chaif.wseles == WSEL_RD)begin
			rfif.wsel  = rd;
		end else if(chaif.wseles == WSEL_31)begin
			rfif.wsel  = 31;
		end else begin		// impossible case
			rfif.wsel  = 'dx;
		end
	end

	always@(chaif.wdat_sel) begin : wdat_select
		if(chaif.wdat_sel == WDAT_ALU)begin
			rfif.wdat  = chaif.alurst;
		end else if(chaif.wdat_sel == WDAT_LUI)begin
			rfif.wdat  = {imm , 16'b0};
		end else if(chaif.wdat_sel == WDAT_MEM)begin
			rfif.wdat  = dmemload;
		end else if(chaif.wdat_sel == WDAT_PC4)begin
			rfif.wdat  = PC4;
		end else begin
			rfif.wdat  = 'bx;
		end
	end

	always@(chaif.PCsel) begin : PCelse_select
		if(chaif.PCsel == PC_JR)begin
			PCelse =  rfif.rdat1;
		end else if(chaif.PCsel == PC_JI)begin
			PCelse =  {chaif.PC[31:28] , JumpAddr , 2'b00};
		end else if(chaif.PCsel == PC_BR)begin
			PCelse =  PC4+{immext[29:0] , 2'b00};
		end else begin	// halt , not sure for this..
			PCelse =  PC;
		end
	end




	always @(dmemstore,dmemaddr,chaif.dmemREN,chaif.dmemWEN)
	begin
		//#(PERIOD);
		printmsg(rcode , opcode);

		$monitor("
PC:%3d %3h:
%s rs=%d rt=%d rd=%d sa=%d %s
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
reg%2d:  %d:%h:%b
dmemstore=%b
dmemaddr= %b
imemREN = %b
dmemREN = %b
dmemWEN = %b"
, PC , PC
,opc , rs , rt , rd , sa , spec
, 00 , regfile.data[00] , regfile.data[00] , regfile.data[00]
, 01 , regfile.data[01] , regfile.data[01] , regfile.data[01]
, 02 , regfile.data[02] , regfile.data[02] , regfile.data[02]
, 03 , regfile.data[03] , regfile.data[03] , regfile.data[03]
, 04 , regfile.data[04] , regfile.data[04] , regfile.data[04]
, 05 , regfile.data[05] , regfile.data[05] , regfile.data[05]
, 31 , regfile.data[31] , regfile.data[31] , regfile.data[31]
, dmemstore
, dmemaddr
, chaif.imemREN
, chaif.dmemREN
, chaif.dmemWEN);

	end
endmodule
