/* 4-bit flags register module */

// time unit / time precision
`timescale 1ps / 1fs

module flags_register (
	input  logic clk, reset, enable,
	input  logic [3:0] DataIn,
	output logic [3:0] DataOut
	);
	
	logic [3:0] d;
	
	mux2_1x4 muxes (.i0(DataOut), .i1(DataIn), .sel(enable), .out(d)); // DataOut is q
	
	// generate 4 flip-flops
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin: D_FFs
			D_FF d_ff (DataOut[i], d[i], reset, clk); // q to d
		end
	endgenerate

endmodule // flags_register