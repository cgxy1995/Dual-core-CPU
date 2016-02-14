/*
	hazard unit
	Mingfei Huang
	huang243@purdue.edu

*/
// mapped needs this
`include "control_hazard_alu_if.vh"

module hazard_unit(
	input logic CLK , nRST,
	control_hazard_alu_if.hu chaif);

	logic imemREN_nxt , dmemREN_nxt , dmmeWEN_nxt;
	assign imemREN_nxt = ~chaif.ihit;


	assign chaif.instEN = chaif.ilast;


	logic chaif_dmemREN_ff;
	logic chaif_dmemWEN_ff;

	assign chaif.dmemREN = ((chaif_dmemREN_ff&(chaif.cu_dmemREN_EXME)) | (chaif.cu_dmemREN_EXME&!chaif.dfin));
	assign chaif.dmemWEN = ((chaif_dmemWEN_ff&(chaif.cu_dmemWEN_EXME)) | (chaif.cu_dmemWEN_EXME&!chaif.dfin));

	always_ff@(posedge CLK or negedge nRST) begin : proc_
		if(~nRST) begin
			chaif.imemREN	= 0;
			chaif_dmemREN_ff	= 0;
			chaif_dmemWEN_ff	= 0;
			//chaif.instEN		= 0;
			chaif.dfin = 0;
			chaif.ilast = 0;
			chaif.dlast = 0;
		end else begin
			chaif.dlast = chaif.dhit;
			chaif.ilast = 0;
			chaif.imemREN = 1;/*!chaif_dmemREN_ff;*/
			//chaif.instEN = ilast&(~(chaif.cu_dmemREN_EXME|chaif.cu_dmemREN_EXME)) | chaif.dhit;
			if(!chaif.halt_MEWB)begin
			//	chaif.imemREN	= ~(chaif.cu_dmemREN_EXME | chaif.cu_dmemREN_EXME);
				chaif_dmemREN_ff	= chaif.cu_dmemREN_EXME & !chaif.dfin;
				chaif_dmemWEN_ff	= chaif.cu_dmemWEN_EXME & !chaif.dfin;
				//chaif.instEN		= 0;
				if(chaif.ihit)begin      // instruction done
					//chaif.instEN	= 1;
					chaif.ilast = 1;
					if(chaif.cu_dmemREN_EXME)begin
						chaif_dmemREN_ff = 1;
					end else if(chaif.cu_dmemWEN_EXME)begin
						chaif_dmemWEN_ff = 1;
					end
					chaif.dfin = 0;
				end else if(chaif.dhit)begin
					chaif.dfin = 1;
					chaif_dmemREN_ff = 0;
					chaif_dmemWEN_ff = 0;
					chaif.imemREN = 1;
				end
			end else begin
				chaif.imemREN = 0;
				chaif_dmemREN_ff = 0;
				chaif_dmemWEN_ff = 0;
				//chaif.instEN  = 0;
			end
		end
	end
endmodule

