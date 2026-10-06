/* a module containing 64 instances of 32-to-1 muxes */
module mux32_1x64 (
	input  logic [31:0][63:0] RegisterBits,
	input  logic [4:0] ReadRegister,
	output logic [63:0] ReadBits
	);
	
	// for each 64 bit of all registers (32 total), combine and pass to the 32-to-1 mux
   genvar i, j;
	generate
		for (i = 0; i < 64; i = i + 1) begin: eachRow
			wire [31:0] concatenation;
			for (j = 0; j < 32; j = j + 1) begin: eachCol
				// register j, bit i
				assign concatenation[j] = RegisterBits[j][i];
			end
			// instantiate mux32_1 64 times for each bit (for 32 registers)
			mux32_1 m32_1 (concatenation, ReadRegister, ReadBits[i]);
		end
	endgenerate

endmodule // mux32_1x64