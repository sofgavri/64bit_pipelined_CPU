/* 64-bit wide NOR gate, implemented w/ four 16-bit OR gates and a NOR gate */
`timescale 1ps / 1fs

module NORx64 (
	input  logic [63:0] in,
	output logic out
);
	wire [3:0] temp;
	
	ORx16 g1 (in[15:0], temp[0]);
	ORx16 g2 (in[31:16], temp[1]);
	ORx16 g3 (in[47:32], temp[2]);
	ORx16 g4 (in[63:48], temp[3]);
	
	nor #50 g5 (out, temp[0], temp[1], temp[2], temp[3]);
  
endmodule // NORx64

module NORx64_tb ();
	logic [63:0] in;
	logic out;
	NORx64 dut (in, out);   // positional: (in, out) — match your module's port order
 
	integer i;
	initial begin
		// Case 1: all zeros -> out should be 1
		in = 64'h0000000000000000; #100;
		assert (out === 1'b1) else $error("all-zero: expected out=1, got %b", out);
 
		// Case 2: lowest bit set -> out should be 0
		in = 64'h0000000000000001; #100;
		assert (out === 1'b0) else $error("bit0 set: expected out=0, got %b", out);
 
		// Case 3: highest bit set -> out should be 0
		in = 64'h8000000000000000; #100;
		assert (out === 1'b0) else $error("bit63 set: expected out=0, got %b", out);
 
		// Case 4: all ones -> out should be 0
		in = 64'hFFFFFFFFFFFFFFFF; #100;
		assert (out === 1'b0) else $error("all-ones: expected out=0, got %b", out);
 
		// Case 5: a mid pattern -> out should be 0
		in = 64'h00000000000000FF; #100;
		assert (out === 1'b0) else $error("0xFF: expected out=0, got %b", out);
 
		// Case 6: single bit set in the middle -> out should be 0
		in = 64'h0000000100000000; #100;
		assert (out === 1'b0) else $error("bit32 set: expected out=0, got %b", out);
 
		// Case 7: walk a single 1 through every bit position -> all should give out=0
		for (i = 0; i < 64; i = i + 1) begin
			in = 64'b0;
			in[i] = 1'b1;
			#100;
			assert (out === 1'b0) else $error("walking-one bit %0d: expected out=0, got %b", i, out);
		end
 
		// Case 8: back to all zeros -> out should be 1 again
		in = 64'h0000000000000000; #100;
		assert (out === 1'b1) else $error("all-zero (again): expected out=1, got %b", out);
 
		$display("NORx64 testbench complete.");
		$stop;
	end
endmodule // NORx64_tb