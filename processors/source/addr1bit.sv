// $Id: $
// File name:   addr1Bit.sv
// Created:     1/22/2013
// Author:      Mingfei Huang
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 1 bit adder lab 3
module addr1bit
(
input wire a,
input wire b,
input wire cin,
output wire s,
output wire cout
);

assign s = cin ^ (a ^ b);
assign cout = ((~ cin) & b & a) | (cin & (b | a));

endmodule
