`include "register_file_if.vh"
//import register_file_if::*;

module register_file
(
	register_file_if.rf rfif,
	input logic CLK,
	input logic nRST
);

	logic [31:0] en;
	logic [31:0] data [31:0];

	// decoder
    always_comb begin
        en = 0;
        if(rfif.WEN)begin
            casez(rfif.wsel)
                00: en[00] = 2'b0;  // location 0 has constant 0 value
                01: en[01] = 2'b1;
                02: en[02] = 2'b1;
                03: en[03] = 2'b1;
                04: en[04] = 2'b1;
                05: en[05] = 2'b1;
                06: en[06] = 2'b1;
                07: en[07] = 2'b1;
                08: en[08] = 2'b1;
                09: en[09] = 2'b1;
                10: en[10] = 2'b1;
                11: en[11] = 2'b1;
                12: en[12] = 2'b1;
                13: en[13] = 2'b1;
                14: en[14] = 2'b1;
                15: en[15] = 2'b1;
                16: en[16] = 2'b1;
                17: en[17] = 2'b1;
                18: en[18] = 2'b1;
                19: en[19] = 2'b1;
                20: en[20] = 2'b1;
                21: en[21] = 2'b1;
                22: en[22] = 2'b1;
                23: en[23] = 2'b1;
                24: en[24] = 2'b1;
                25: en[25] = 2'b1;
                26: en[26] = 2'b1;
                27: en[27] = 2'b1;
                28: en[28] = 2'b1;
                29: en[29] = 2'b1;
                30: en[30] = 2'b1;
                31: en[31] = 2'b1;
                default:en = 0;
            endcase
        end
        else begin
            en = 0;
        end
    end


	// generate regs
    genvar i;
    generate
        for(i = 1; i <= 31; i = i + 1)//skip $0
        begin:blahname
            Regs regs (
                /*rfif.*/rfif.wdat,
                en[i],
                /*rfif.*/CLK,
                nRST,
                data[i]
            );
        end
    endgenerate

    assign data[0] = 0; //$0=0

    // mux1
    always_comb begin
        casez(rfif.rsel1)
            00: rfif.rdat1 = data[00];
            01: rfif.rdat1 = data[01];
            02: rfif.rdat1 = data[02];
            03: rfif.rdat1 = data[03];
            04: rfif.rdat1 = data[04];
            05: rfif.rdat1 = data[05];
            06: rfif.rdat1 = data[06];
            07: rfif.rdat1 = data[07];
            08: rfif.rdat1 = data[08];
            09: rfif.rdat1 = data[09];
            10: rfif.rdat1 = data[10];
            11: rfif.rdat1 = data[11];
            12: rfif.rdat1 = data[12];
            13: rfif.rdat1 = data[13];
            14: rfif.rdat1 = data[14];
            15: rfif.rdat1 = data[15];
            16: rfif.rdat1 = data[16];
            17: rfif.rdat1 = data[17];
            18: rfif.rdat1 = data[18];
            19: rfif.rdat1 = data[19];
            20: rfif.rdat1 = data[20];
            21: rfif.rdat1 = data[21];
            22: rfif.rdat1 = data[22];
            23: rfif.rdat1 = data[23];
            24: rfif.rdat1 = data[24];
            25: rfif.rdat1 = data[25];
            26: rfif.rdat1 = data[26];
            27: rfif.rdat1 = data[27];
            28: rfif.rdat1 = data[28];
            29: rfif.rdat1 = data[29];
            30: rfif.rdat1 = data[30];
            31: rfif.rdat1 = data[31];
            default:rfif.rdat1 = 0;
        endcase
    end

    // mux2
    always_comb begin
        casez(rfif.rsel2)
            00: rfif.rdat2 = data[00];
            01: rfif.rdat2 = data[01];
            02: rfif.rdat2 = data[02];
            03: rfif.rdat2 = data[03];
            04: rfif.rdat2 = data[04];
            05: rfif.rdat2 = data[05];
            06: rfif.rdat2 = data[06];
            07: rfif.rdat2 = data[07];
            08: rfif.rdat2 = data[08];
            09: rfif.rdat2 = data[09];
            10: rfif.rdat2 = data[10];
            11: rfif.rdat2 = data[11];
            12: rfif.rdat2 = data[12];
            13: rfif.rdat2 = data[13];
            14: rfif.rdat2 = data[14];
            15: rfif.rdat2 = data[15];
            16: rfif.rdat2 = data[16];
            17: rfif.rdat2 = data[17];
            18: rfif.rdat2 = data[18];
            19: rfif.rdat2 = data[19];
            20: rfif.rdat2 = data[20];
            21: rfif.rdat2 = data[21];
            22: rfif.rdat2 = data[22];
            23: rfif.rdat2 = data[23];
            24: rfif.rdat2 = data[24];
            25: rfif.rdat2 = data[25];
            26: rfif.rdat2 = data[26];
            27: rfif.rdat2 = data[27];
            28: rfif.rdat2 = data[28];
            29: rfif.rdat2 = data[29];
            30: rfif.rdat2 = data[30];
            31: rfif.rdat2 = data[31];
            default:rfif.rdat2 = 0;
        endcase
    end

endmodule
