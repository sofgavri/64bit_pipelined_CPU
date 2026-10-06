/* 32-to-1 mux module
	consists of instances of 2-to-1 muxes, generates a tree by layers */

// time unit / time precision
`timescale 1ps / 1fs

module mux32_1 (
	input  logic [31:0] RegisterBits,
   input  logic [4:0] ReadRegister,  // select
   output logic ReadBit
   );
	
	// 5 layers total: 16, 8, 4, 2, 1 muxes 2-to-1 on each
	wire [15:0] l1;
	wire [7:0]  l2;
	wire [3:0]  l3;
	wire [1:0]  l4;
	// wire l5; same as ReadBit
	
   genvar i;
   generate
	// layer one
		for (i = 0; i < 16; i = i + 1) begin : layerOne
			mux2_1 m2_1x16 (RegisterBits[2*i], RegisterBits[2*i + 1], ReadRegister[0], l1[i]);
		end
	
	// layer two
		for (i = 0; i < 8; i = i + 1) begin : layerTwo
			mux2_1 m2_1x8 (l1[2*i], l1[2*i + 1], ReadRegister[1], l2[i]);
		end
	
	// layer three
		for (i = 0; i < 4; i = i + 1) begin : layerThree
			mux2_1 m2_1x4 (l2[2*i], l2[2*i + 1], ReadRegister[2], l3[i]);
		end
	
	// layer four
		for (i = 0; i < 2; i++) begin : layerFour
			mux2_1 m2_1x2 (l3[2*i], l3[2*i + 1], ReadRegister[3], l4[i]);
		end
   endgenerate
	
	// layer five
	mux2_1 m2_1 (l4[0], l4[1], ReadRegister[4], ReadBit);
  
endmodule // mux32_1