/* 16-bit wide OR gate  */
`timescale 1ps / 1fs

module ORx16 (
	input  logic [15:0] in,
	output logic out
);
	wire [3:0] temp;
	
	or #50 g1 (temp[0], in[0],  in[1],  in[2],  in[3]);
	or #50 g2 (temp[1], in[4],  in[5],  in[6],  in[7]);
	or #50 g3 (temp[2], in[8],  in[9],  in[10], in[11]);
	or #50 g4 (temp[3], in[12], in[13], in[14], in[15]);
	
	or #50 g5 (out, temp[0],  temp[1],  temp[2],  temp[3]);
  
endmodule // ORx16