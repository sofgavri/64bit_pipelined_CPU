/* 2-to-4 decoder */

// time unit / time precision
`timescale 1ps / 1fs

module decoder2_4 (
	input  logic [1:0] in,
	output logic [3:0] out
   );
   // for NOT gates
   wire n0, n1;
  
   // add inverters to input bits
   not #50 g1 (n0, in[0]);
   not #50 g2 (n1, in[1]);
   
   // use AND gates for each output bit
   and #50 g3 (out[0], n1, n0);       // bit 0
   and #50 g4 (out[1], n1, in[0]);    // bit 1
   and #50 g5 (out[2], in[1], n0);    // bit 2
   and #50 g6 (out[3], in[1], in[0]); // bit 3
  
endmodule  // decoder2_4