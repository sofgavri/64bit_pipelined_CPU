/* 64-bit register module */

// time unit / time precision
`timescale 1ps / 1fs

module register #(parameter N=64)(
	input  logic clk, reset, enable,
	input  logic [N-1:0] DataIn,
	output logic [N-1:0] DataOut
	);
	
	logic [N-1:0] d;
	
	//mux2_1xN
   genvar i;
	generate
		for (i = 0; i < N; i = i + 1) begin: muxes
			mux2_1 m2_1 (.i0(DataOut[i]), .i1(DataIn[i]), .sel(enable), .out(d[i])); // DataOut is q
		end
	endgenerate
	
	// generate N flip-flops
	genvar j;
	generate
		for (j = 0; j < N; j = j + 1) begin: D_FFs
			D_FF d_ff (DataOut[j], d[j], reset, clk); // q to d
		end
	endgenerate

endmodule // register