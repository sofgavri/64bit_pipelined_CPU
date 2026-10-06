/* 3-to-8 decoder */

// time unit / time precision
`timescale 1ps / 1fs

module decoder3_8 (
   input  logic [2:0] in,
   output logic [7:0] out
   );
   // for NOT gates
   wire n0, n1, n2;
   
   // add inverters to input bits
   not #50 g1 (n0, in[0]);
   not #50 g2 (n1, in[1]);
   not #50 g3 (n2, in[2]);
   
   // use AND gates for each output bit
   and #50 g4  (out[0], n2, n1, n0);          // bit 0
   and #50 g5  (out[1], n2, n1, in[0]);       // bit 1
   and #50 g6  (out[2], n2, in[1], n0);       // bit 2
   and #50 g7  (out[3], n2, in[1], in[0]);    // bit 3
   
   and #50 g8  (out[4], in[2], n1, n0);       // bit 4
   and #50 g9  (out[5], in[2], n1, in[0]);    // bit 5
   and #50 g10 (out[6], in[2], in[1], n0);    // bit 6
   and #50 g11 (out[7], in[2], in[1], in[0]); // bit 7
  
endmodule  // decoder3_8