/* pipeline register module */

// time unit / time precision
`timescale 1ps / 1fs

module MEMWB_register (
	input  logic clk, reset, enable,
	input  logic MEM_RegWrite,
	input  logic [1:0]  MEM_Mem2Reg,
	input  logic [4:0]  MEM_Rd,
	input  logic [63:0] MEM_PCplus4,
	input  logic [63:0] MEM_MemReadData,
	input  logic [63:0] MEM_ALUresult,
	
	output logic WB_RegWrite,
	output logic [1:0]  WB_Mem2Reg,
	output logic [4:0]  WB_Rd,
	output logic [63:0] WB_PCplus4,
	output logic [63:0] WB_MemReadData,
	output logic [63:0] WB_ALUresult
	);
	
	//WB - RegWrite, Mem2Reg 
	register #(.N(1)) RW_register (.clk, .reset, .enable, .DataIn(MEM_RegWrite), .DataOut(WB_RegWrite));
	register #(.N(2)) MR_register (.clk, .reset, .enable, .DataIn(MEM_Mem2Reg),  .DataOut(WB_Mem2Reg));
	
	// 64-bit registers - MemReadData, ALUresult
	register ALUres_register (.clk, .reset, .enable, .DataIn(MEM_MemReadData), .DataOut(WB_MemReadData));
	register MuxB_register   (.clk, .reset, .enable, .DataIn(MEM_ALUresult),  .DataOut(WB_ALUresult));
	
	// register Rd
	register #(.N(5)) Rd_register (.clk, .reset, .enable, .DataIn(MEM_Rd),  .DataOut(WB_Rd));

	// PC plus 4
	register PCplus4_register (.clk, .reset, .enable, .DataIn(MEM_PCplus4), .DataOut(WB_PCplus4));
	
endmodule // MEMWB_register