/* decoder
   made using 2-to-4 and 3-to-8 decoders,
	where each of their outputs is ANDed together with
	RegWrite, which is the control signal */
	
// time unit / time precision
`timescale 1ps / 1fs

module decoder5_32 (
	input  logic [4:0] WriteRegister,
	input  logic RegWrite,
   output logic [31:0] RegisterEnable
   );
	
	// temporary holders for decoders' outputs
	wire [3:0] out2_4;
	wire [7:0] out3_8;
	
	// upper 2 bits for the 2-to-4 decoder, the rest 3 for the 3-to-8 decoder
	decoder2_4 d2_4 (.in(WriteRegister[4:3]), .out(out2_4));
	decoder3_8 d3_8 (.in(WriteRegister[2:0]), .out(out3_8));
	
	// generate 32 AND gates and assign the output
	genvar i, j;
   generate
		for (i = 0; i < 4; i = i + 1) begin : eachRow
			for (j = 0; j < 8; j = j + 1) begin : eachCol
				// 3-input AND gate: control 
				and #50 g (RegisterEnable[i*8 + j], out2_4[i], out3_8[j], RegWrite);
			end
		end
	endgenerate
  
endmodule  // decoder5_32