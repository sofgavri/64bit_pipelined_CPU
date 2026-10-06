/* instantiation of 64 2-to-1 muxes */
module mux8_1x64 (
	input  logic [63:0] i000, i001, i010, i011, i100, i101, i110, i111,
	input  logic sel0, sel1, sel2,
	output logic [63:0] out
	);
	
	// instantiate mux8_1 64 times for each bit
   genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin: muxes
			mux8_1 m8_1 (i000[i], i001[i], i010[i], i011[i],
							 i100[i], i101[i], i110[i], i111[i],
							 sel0, sel1, sel2, out[i]);
		end
	endgenerate

endmodule // mux8_1x64