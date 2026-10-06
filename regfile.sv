/* register file module */
module regfile (
	input  logic [4:0] 	ReadRegister1, ReadRegister2, WriteRegister,
	input  logic [63:0]	WriteData,
	input  logic 			RegWrite, clk,
	output logic [63:0]	ReadData1, ReadData2
	);
	
	wire [31:0] RegisterEnable;
	wire [31:0][63:0] RegisterBits;
	
	// instantiate a decoder, get enables for registers
	decoder5_32 decoder (WriteRegister, RegWrite, RegisterEnable);
	
	// generate x32 64-bit registers
	genvar i;
	generate
		for (i = 0; i < 31; i = i + 1) begin : regs
			// access each 64-bit register with rows
			register r (.clk, .reset(1'b0), .enable(RegisterEnable[i]), 
							.DataIn(WriteData), .DataOut(RegisterBits[i]));
		end	
	endgenerate
	// hardwire register 31 to '0
	assign RegisterBits[31] = 64'b0;
	
	mux32_1x64 m1 (.RegisterBits, .ReadRegister(ReadRegister1), .ReadBits(ReadData1));
	mux32_1x64 m2 (.RegisterBits, .ReadRegister(ReadRegister2), .ReadBits(ReadData2));

endmodule // regfile