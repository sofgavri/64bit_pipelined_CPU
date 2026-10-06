`timescale 1ps / 1fs

module alu (
	input  logic [63:0] A, B,
	input  logic [2:0]  cntrl,
	output logic [63:0] result,
	output logic zero, overflow, carry_out, negative
);

	// temporary variable for cin/cout
	wire [64:0] temp;
	assign temp[0] = cntrl[0]; // 1st cin is determined by add/subtract
	
	// generate 64 1-bit ALU slices
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : eachSlice
			alu_slice slice (.cin(temp[i]), .A(A[i]), .B(B[i]), .cntrl,
								  .cout(temp[i + 1]), .result(result[i]));
		end
	endgenerate
	
	// CF (carry-out flag)
	assign carry_out = temp[64];
	
	// OF (overflow flag)
	xor #50 g1 (overflow, temp[63], temp[64]);
	
	// ZF (zero flag)
	NORx64 g2 (.in(result), .out(zero));
	
	// NF (negative flag)
	assign negative = result[63];
	
endmodule // alu