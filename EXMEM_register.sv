/* pipeline register module */

// time unit / time precision
`timescale 1ps / 1fs

module EXMEM_register (
	input  logic clk, reset, enable,
	input  logic EX_MemRead, EX_MemWrite, EX_RegWrite,
	input  logic [1:0]  EX_Mem2Reg,
	input  logic [4:0]  EX_Rd,
	input  logic [63:0] EX_PCplus4,
	input  logic [63:0] EX_ALUresult,
	input  logic [63:0] EX_OutMuxB,
	
	output logic MEM_MemRead, MEM_MemWrite, MEM_RegWrite,
	output logic [1:0]  MEM_Mem2Reg,
	output logic [4:0]  MEM_Rd,
	output logic [63:0] MEM_PCplus4,
	output logic [63:0] MEM_ALUresult,
	output logic [63:0] MEM_OutMuxB
	);
	
	// M (will be used within the next stage) - MemRead, MemWrite
	register #(.N(1)) R_register (.clk, .reset, .enable, .DataIn(EX_MemRead),  .DataOut(MEM_MemRead));
	register #(.N(1)) W_register (.clk, .reset, .enable, .DataIn(EX_MemWrite), .DataOut(MEM_MemWrite));
	
	//WB - RegWrite, Mem2Reg 
	register #(.N(1)) RW_register (.clk, .reset, .enable, .DataIn(EX_RegWrite), .DataOut(MEM_RegWrite));
	register #(.N(2)) MR_register (.clk, .reset, .enable, .DataIn(EX_Mem2Reg),  .DataOut(MEM_Mem2Reg));
	
	// 64-bit registers - ALUresult, ALUin2
	register ALUres_register (.clk, .reset, .enable, .DataIn(EX_ALUresult), .DataOut(MEM_ALUresult));
	register MuxB_register   (.clk, .reset, .enable, .DataIn(EX_OutMuxB),   .DataOut(MEM_OutMuxB));
	
	// register Rd
	register #(.N(5)) Rd_register (.clk, .reset, .enable, .DataIn(EX_Rd),  .DataOut(MEM_Rd));
	
	// PC plus 4
	register PCplus4_register (.clk, .reset, .enable, .DataIn(EX_PCplus4), .DataOut(MEM_PCplus4));
	
endmodule // EXMEM_register