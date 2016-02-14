`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module dblock(
	input logic CLK,
	input logic nRST,
	input word_t wData,
	input logic [25:0] wTag,
	input logic wValid,
	input logic cWEN,
	output word_t rDataOut,
	output logic [25:0] rTag,
	output logic rValid,
	input logic wDirty,
	output logic rDirty,
	input logic wRU,
	output logic rRU,
	input logic syncRUEN,
	input logic rBO,
	input logic wBO,
	input logic wDirtyEN,
	input logic dhit,
	input logic wValidEN,
	input logic inv
	//, parameter logic resetRU
	//,input logic resetRU
);
	word_t rData0 , rData1;
	parameter rstval;

	// haha this is a mealy machine
	always_comb begin : output_logic
		if(rBO==0)begin
			rDataOut = rData0;
		end else if(rBO==1)begin
			rDataOut = rData1;
		end else begin	// impossible
			rDataOut = 32'dx;
		end
	end

	always_ff@(posedge CLK or negedge nRST) begin : iblock_ff
		if(~nRST)begin
			rData0	= 32'dx;
			rData1	= 32'dx;
			rTag	= 26'dx;
			rValid	= 1'd0;
			rDirty	= 1'd0;
			rRU		= rstval;
		end else begin
			if(inv)begin	// cc invalid
				rValid	= 1'd0;
				rDirty	= 1'd0;
			end else begin
				if(cWEN&!dhit)begin
					if(wBO==0)begin
						rData0 = wData;
					end else if(wBO==1)begin
						rData1 = wData;
					end else begin	// for debug
						rData0 = 32'bx;
						rData1 = 32'bx;
					end
				end
				if(syncRUEN)begin	// these will be written after two block words are both filled
					rRU     = wRU;
				end
				if(syncRUEN&cWEN)begin
					rTag	= wTag;
				end
				if(syncRUEN&wValidEN)begin
					rValid	= wValid;
				end
				if(syncRUEN&(wDirtyEN|cWEN))begin
					rDirty	= wDirty;
				end
			end
		end
	end

endmodule


