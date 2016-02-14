/*
	Mingfei Huang
	datapath testbench
*/

// cpu instructions
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
// mapped needs this
`include "register_file_if.vh"
// data path interface
`include "datapath_cache_if.vh"
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module datapath_tb;

	logic CLK , nRST;

	datapath_cache_if dpif();
	control_hazard_alu_if chaif();

	datapath DP_DUT(CLK , nRST , dpif);

	// fake stuff
	fake_imem FI_DUT(chaif);

	logic [5:0] op;
	logic [4:0] rs;
	logic [4:0] rt;
	logic [4:0] rd;
	logic [4:0] sa;
	logic [5:0] spe;
	assign {op , rs , rt , rd , sa , spe} = dpif.imemload;

	assign dpif.imemload = chaif.imemload;
	assign chaif.PC = dpif.imemaddr;

	parameter PERIOD = 10;

	string opc;
	string spec;

	assign dpif.dhit = 0;

/*	always@(posedge CLK or negedge nRST) begin
		if(~nRST) begin
			chaif.ilast <= 0;
		end else begin
			chaif.ilast <= chaif.ihit;
		end
	end*/

	task printmsg (input [5:0] spe , [5:0] op);
		if(op==0)begin
			case(spe)
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
			$sformat(spec, "%6b", spe);
		end
		case(op)
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

	always begin
		#(PERIOD*2);
		dpif.ihit = 1;
		#(PERIOD);
		dpif.ihit = 0;
	end


	initial begin
		CLK=0;
		nRST = 0;
		#PERIOD;
		nRST = 1;
	end

	always @(dpif.imemaddr , dpif.imemload,dpif.dmemstore,dpif.dmemaddr,dpif.imemREN,dpif.dmemREN,dpif.dmemWEN)
	begin
		//#(PERIOD);
		printmsg(spe , op);

		$monitor("\nPC:%3d %3h:\n%s rs=%d rt=%d rd=%d sa=%d %s\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\nreg%2d:  %d:%h:%b\ndmemstore=%b\ndmemaddr= %b\nimemREN = %b\ndmemREN = %b\ndmemWEN = %b"
		, dpif.imemaddr, dpif.imemaddr
		,opc , rs , rt , rd , sa , spec
		, 00 , DP_DUT.regfile.data[00] , DP_DUT.regfile.data[00] , DP_DUT.regfile.data[00]
		, 01 , DP_DUT.regfile.data[01] , DP_DUT.regfile.data[01] , DP_DUT.regfile.data[01]
		, 02 , DP_DUT.regfile.data[02] , DP_DUT.regfile.data[02] , DP_DUT.regfile.data[02]
		, 03 , DP_DUT.regfile.data[03] , DP_DUT.regfile.data[03] , DP_DUT.regfile.data[03]
		, 04 , DP_DUT.regfile.data[04] , DP_DUT.regfile.data[04] , DP_DUT.regfile.data[04]
		, 05 , DP_DUT.regfile.data[05] , DP_DUT.regfile.data[05] , DP_DUT.regfile.data[05]
		, 31 , DP_DUT.regfile.data[31] , DP_DUT.regfile.data[31] , DP_DUT.regfile.data[31]
		, dpif.dmemstore
		, dpif.dmemaddr
		, dpif.imemREN
		, dpif.dmemREN
		, dpif.dmemWEN);

	end

endmodule