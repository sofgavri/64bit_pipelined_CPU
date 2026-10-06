`timescale 1ps / 1fs

module full_adder (
	input logic  cin, a, b,
	output logic cout, sum
);
	wire xor1, and1, and2, and3, or1;
	
	// sum = A xor B xor C_in
	xor #50 g1 (xor1, a, b);
	xor #50 g2 (sum, xor1, cin);
	
	// carry out = A*B + B*C_in + A*C_in
	and #50 g3 (and1, a, b);
	and #50 g4 (and2, b, cin);
	and #50 g5 (and3, a, cin);
	
	or #50 g6 (or1, and1, and2);
	or #50 g7 (cout, or1, and3);
  
endmodule // full_adder