/* instantiation of 64 4-to-1 muxes */
module mux4_1x64 (
	input  logic [63:0] i00, i01, i10, i11,
	input  logic sel0, sel1,
	output logic [63:0] out
	);
	
	// instantiate mux4_1 64 times for each bit
   genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin: muxes
			mux4_1 m4_1 (i00[i], i01[i], i10[i], i11[i], sel0, sel1, out[i]);
		end
	endgenerate

endmodule // mux4_1x64