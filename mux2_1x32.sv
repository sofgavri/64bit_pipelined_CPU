/* instantiation of 32 2-to-1 muxes */
module mux2_1x32 (
	input  logic [31:0] i0, i1,
	input  logic sel,
	output logic [31:0] out
	);
	
	// instantiate mux2_1 64 times for each bit
   genvar i;
	generate
		for (i = 0; i < 32; i = i + 1) begin: muxes
			mux2_1 m2_1 (i0[i], i1[i], sel, out[i]);
		end
	endgenerate

endmodule // mux2_1x32