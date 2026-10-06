/* pipeline register module */

// time unit / time precision
`timescale 1ps / 1fs

module IDEX_register (
	input  logic clk, reset, enable,
	input  logic ID_ALUsrc, ID_SetFlags, ID_MemRead, ID_MemWrite, ID_RegWrite,
	input  logic [1:0]  ID_Mem2Reg,
	input  logic [2:0]  ID_ALUop,
	input  logic [4:0]  ID_Rn, ID_Rm, ID_Rd,
	input  logic [63:0] ID_PCplus4,
	input  logic [63:0] ID_ReadData1,
	input  logic [63:0] ID_ReadData2,
	input  logic [63:0] ID_ExtendedImm,
	
	output logic EX_ALUsrc, EX_SetFlags, EX_MemRead, EX_MemWrite, EX_RegWrite,
	output logic [1:0]  EX_Mem2Reg,
	output logic [2:0]  EX_ALUop,
	output logic [4:0]  EX_Rn, EX_Rm, EX_Rd,
	output logic [63:0] EX_PCplus4,
	output logic [63:0] EX_ReadData1,
	output logic [63:0] EX_ReadData2,
	output logic [63:0] EX_ExtendedImm
	);
	
	// M - MemRead, MemWrite
	register #(.N(1)) R_register (.clk, .reset, .enable, .DataIn(ID_MemRead),  .DataOut(EX_MemRead));
	register #(.N(1)) W_register (.clk, .reset, .enable, .DataIn(ID_MemWrite), .DataOut(EX_MemWrite));
	
	//WB - RegWrite, Mem2Reg
	register #(.N(1)) RW_register (.clk, .reset, .enable, .DataIn(ID_RegWrite), .DataOut(EX_RegWrite));
	register #(.N(2)) MR_register (.clk, .reset, .enable, .DataIn(ID_Mem2Reg),  .DataOut(EX_Mem2Reg));
	
	// EX (will be used within the next stage) - ALUsrc, SetFlags, ALUop
	register #(.N(1)) ALUsrc_register (.clk, .reset, .enable, .DataIn(ID_ALUsrc),    .DataOut(EX_ALUsrc));
	register #(.N(1)) SF_register     (.clk, .reset, .enable, .DataIn(ID_SetFlags),  .DataOut(EX_SetFlags));
	register #(.N(3)) ALUop_register  (.clk, .reset, .enable, .DataIn(ID_ALUop),     .DataOut(EX_ALUop));
	
	// 64-bit registers - ReadData1, ReadData2, ExtendedImm
	register RD1_register (.clk, .reset, .enable, .DataIn(ID_ReadData1),   .DataOut(EX_ReadData1));
	register RD2_register (.clk, .reset, .enable, .DataIn(ID_ReadData2),   .DataOut(EX_ReadData2));
	register ExI_register (.clk, .reset, .enable, .DataIn(ID_ExtendedImm), .DataOut(EX_ExtendedImm));
	
	// register Rn
	register #(.N(5)) Rn_register (.clk, .reset, .enable, .DataIn(ID_Rn),  .DataOut(EX_Rn));
	
	// register Rm
	register #(.N(5)) Rm_register (.clk, .reset, .enable, .DataIn(ID_Rm),  .DataOut(EX_Rm));
	
	// register Rd
	register #(.N(5)) Rd_register (.clk, .reset, .enable, .DataIn(ID_Rd),  .DataOut(EX_Rd));
	
	// PC plus 4
	register PCplus4_register (.clk, .reset, .enable, .DataIn(ID_PCplus4), .DataOut(EX_PCplus4));
	
endmodule // IDEX_register