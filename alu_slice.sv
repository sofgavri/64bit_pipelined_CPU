`timescale 1ps / 1fs

module alu_slice (
	input  logic cin,
	input  logic A, B,
	input  logic [2:0] cntrl,
	output logic cout,
	output logic result
);
	wire nB, and1, or1, xor1;
	wire sum, selB, add_sub_result;
	
	// choose add/subtract for B
	not #50 g1 (nB, B);
	
	and #50 g2 (and1, A, B);
	or  #50 g3 (or1, A, B);
	xor #50 g4 (xor1, A, B);
	
	// select for ADD/SUB operation
	mux2_1 add_sub (B, nB, cntrl[0], selB);
	
	// get result from the adder
	full_adder f_add (.cin, .a(A), .b(selB), .cout, .sum(add_sub_result));
	
	// select an operation
	mux8_1 m8_1 (.i000(B),        .i001(1'b0),     .i010(add_sub_result), .i011(add_sub_result),
			 	  	 .i100(and1),     .i101(or1),      .i110(xor1),           .i111(1'b0),
			   	 .sel0(cntrl[0]), .sel1(cntrl[1]), .sel2(cntrl[2]),       .out(result));
	
endmodule // alu_slice