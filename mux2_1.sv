/* 2-to-1 mux module */

// time unit / time precision
`timescale 1ps / 1fs

module mux2_1 (
	input  logic i0, i1, sel,
	output logic out
   );
  
	wire a, b, c;
	// out = (i1 & sel) | (i0 & ~sel)
   and #50 g1(a, i1, sel);
   not #50 g2(c, sel);
   and #50 g3(b, i0, c);
   or  #50 g4(out, a, b);
  
endmodule // mux2_1

module mux2_1_tb ();
	logic out;
   logic i0, i1, sel;

   // instantiate device under test (dut)
   mux2_1 dut (.*);
	
	// Set up the clock
	logic clk;
   parameter CLOCK_PERIOD = 100;
   initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end
 
   // test input sequence
	initial begin
		sel=0; i0=0; i1=0; @(posedge clk);
		sel=0; i0=0; i1=1; @(posedge clk);
		sel=0; i0=1; i1=0; @(posedge clk);
		sel=0; i0=1; i1=1; @(posedge clk);
		sel=1; i0=0; i1=0; @(posedge clk);
		sel=1; i0=0; i1=1; @(posedge clk);
		sel=1; i0=1; i1=0; @(posedge clk);
		sel=1; i0=1; i1=1; @(posedge clk);
      
		$stop;
  end

	
endmodule