/* top-level testbench */
`timescale 1ps / 1fs

module CPU_pipelined_tb ();
	logic clk, reset;
	
	CPU_pipelined dut (.*);
	
	// set up the clock
	parameter CLOCK_PERIOD = 100000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end
	
	initial begin
		reset <= 1'b1;  	@(posedge clk);
		reset <= 1'b0;		@(posedge clk);
		repeat (500)      @(posedge clk);
		$stop;
	end
	
endmodule // CPU_pipelined_tb