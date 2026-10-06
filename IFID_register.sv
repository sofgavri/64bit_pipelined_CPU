/* pipeline register module */

// time unit / time precision
`timescale 1ps / 1fs

module IFID_register (
	input  logic clk, reset, enable,
	input  logic [31:0] IF_Instruction,
	input  logic [63:0] IF_PC, IF_PCplus4,
	output logic [31:0] ID_Instruction,
	output logic [63:0] ID_PC, ID_PCplus4
	);

	// 32-bit instruction register
	register #(.N(32)) instruction_register (.clk, .reset, .enable,
														  .DataIn(IF_Instruction), .DataOut(ID_Instruction));
	// 64-bit instruction register
	register PC_register      (.clk, .reset, .enable, .DataIn(IF_PC),      .DataOut(ID_PC));
	register PCplus4_register (.clk, .reset, .enable, .DataIn(IF_PCplus4), .DataOut(ID_PCplus4));

endmodule // IFID_register