
// cpu instructions
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

// mapped needs this
`include "control_hazard_alu_if.vh"


module fake_imem(control_hazard_alu_if.fi chaif);
	always_comb begin
		casez(chaif.PC)
			32'h00:chaif.imemload=32'h3401D269;
			32'h04:chaif.imemload=32'h340237F1;
			32'h08:chaif.imemload=32'h34150080;
			32'h0C:chaif.imemload=32'h341600F0;
			32'h10:chaif.imemload=32'h00221825;
			32'h14:chaif.imemload=32'h00222024;
			32'h18:chaif.imemload=32'h3025000F;
			32'h1C:chaif.imemload=32'h00223021;
			32'h20:chaif.imemload=32'h24678740;
			32'h24:chaif.imemload=32'h00824023;
			32'h28:chaif.imemload=32'h00A24826;
			32'h2C:chaif.imemload=32'h382AF33F;
			32'h30:chaif.imemload=32'h00205900;
			32'h34:chaif.imemload=32'h00206142;
			32'h38:chaif.imemload=32'h00226827;
			32'h3C:chaif.imemload=32'hFFFFFFFF;
			default:chaif.imemload=32'hFFFFFFFF;
		endcase
	end
endmodule