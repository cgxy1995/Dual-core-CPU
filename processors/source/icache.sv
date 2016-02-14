
// interfaces
//`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

module icache (
	input logic CLK, nRST,
	//`ifndef MAPPED
		datapath_cache_if.icache dcif,
		input logic iwait,
		input logic [31:0] iload,
		output logic iREN,
		output logic [31:0] iaddr
	);
  	/*`else
		dcif.imemREN,
		word_t dcif.imemaddr,
		iwait,
		output logic dcif.ihit,
		output word_t dcif.imemload,
		output word_t iload,
		output logic iREN,
		output word_t iaddr
	`endif*/

	parameter CPUID = 0;

	// dcif:
	/*input   imemREN, imemaddr,
	output  ihit, imemload*/
	// ccif:
	/*input   iwait, iload,
	output  iREN, iaddr*/

	assign iaddr = dcif.imemaddr;
	//assign iREN  = 1'b1;	// always high, mem ctrl will handle



	logic[25:0] inTag;
	logic[25:0] cTag;
	logic[3:0] inIndex;
	logic cValid;
	assign inTag = dcif.imemaddr[31:6];
	assign inIndex = dcif.imemaddr[5:2];

	word_t cData;	// cache read data (pure mux output)

	logic [31:0] readData [15:0];
	logic [25:0] readTag [15:0];
	logic [15:0] readValid;

	logic [15:0] set;
	logic setEN;

	genvar ii;

	logic isLatch;


	always_comb begin : handle_miss
		//if(dcif.imemREN)begin
			isLatch = 1;
			if((cTag==inTag) & cValid)begin	// hit
				iREN = 0;
				dcif.ihit = 1;//&dcif.imemREN;
				dcif.imemload = cData;
				setEN = 0;
			end else begin	// miss
				iREN = dcif.imemREN;
				dcif.ihit = 0;//!iwait;
				dcif.imemload = iload;
				// write to cache, need to decide which block is least used..
				setEN = 1;
			end
		//end
	end

	logic[15:0] onevar;

	generate
		for(ii = 0; ii < 16; ii++)begin: block_gen
			assign onevar[ii] = set[ii] & setEN;

			iblock oneBlock(
				CLK,
				nRST,
				iload, // setData,
				inTag, // setTag,
				(!iwait) && set[ii] && setEN,
				readData[ii],
				readTag[ii],
				readValid[ii]
			);
		end
	endgenerate

	always_comb begin: cData_gen
		cData='dx;
		set=0;
		cValid = 0;
		casez(inIndex)
			00:begin cData=readData[00]; cValid=readValid[00]; cTag=readTag[00]; set[00]=1; end
			01:begin cData=readData[01]; cValid=readValid[01]; cTag=readTag[01]; set[01]=1; end
			02:begin cData=readData[02]; cValid=readValid[02]; cTag=readTag[02]; set[02]=1; end
			03:begin cData=readData[03]; cValid=readValid[03]; cTag=readTag[03]; set[03]=1; end
			04:begin cData=readData[04]; cValid=readValid[04]; cTag=readTag[04]; set[04]=1; end
			05:begin cData=readData[05]; cValid=readValid[05]; cTag=readTag[05]; set[05]=1; end
			06:begin cData=readData[06]; cValid=readValid[06]; cTag=readTag[06]; set[06]=1; end
			07:begin cData=readData[07]; cValid=readValid[07]; cTag=readTag[07]; set[07]=1; end
			08:begin cData=readData[08]; cValid=readValid[08]; cTag=readTag[08]; set[08]=1; end
			09:begin cData=readData[09]; cValid=readValid[09]; cTag=readTag[09]; set[09]=1; end
			10:begin cData=readData[10]; cValid=readValid[10]; cTag=readTag[10]; set[10]=1; end
			11:begin cData=readData[11]; cValid=readValid[11]; cTag=readTag[11]; set[11]=1; end
			12:begin cData=readData[12]; cValid=readValid[12]; cTag=readTag[12]; set[12]=1; end
			13:begin cData=readData[13]; cValid=readValid[13]; cTag=readTag[13]; set[13]=1; end
			14:begin cData=readData[14]; cValid=readValid[14]; cTag=readTag[14]; set[14]=1; end
			15:begin cData=readData[15]; cValid=readValid[15]; cTag=readTag[15]; set[15]=1; end
		endcase
	end
endmodule