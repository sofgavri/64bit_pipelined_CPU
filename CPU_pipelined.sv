/* pipelined 64-bit CPU in LEGv8 ISA with forwarding only */
`timescale 1ps / 1fs

module CPU_pipelined (
	input logic clk, reset
);
	/* internal connections */
	
	logic negative_clk;
	// PC and Flags registers
	logic [63:0] Address, NextAddress; // current and next PC (Address)
	logic [63:0] PCplus4, PCcalculated; // inputs to PC
	// Register File
	logic [4:0]  ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0] ReadData1, ReadData2, WriteData;
	logic [4:0]  Rm, Rd;
	// Sign-Extender
	logic [63:0] ExtendedImm;
	// control unit
	logic [1:0] SignEXop, PCsrc;
   logic Reg2Loc, RegWriteDest;
	// ALU
	logic [3:0]  d_flags, q_flags; // Zero (i3), oVerflow (i2), Carry (i1), Negative (i0)
	logic [63:0] ALUin2;
	// Data Memory
	logic [63:0] MemReadData;
	// temporary
	logic [63:0] Mem2Reg_out, PCsrc_out;
	
	
	// variables for pipelining
	
	// IFID
	logic [31:0] IF_Instruction, ID_Instruction; // current instruction
	logic [63:0] ID_PC, ID_PCplus4;

	// forwarding in ID
	logic [3:0] ID_flags;
	
	// controls
	logic [1:0] ID_Mem2Reg;
	logic [2:0] ID_ALUop;
	logic ID_ALUsrc, ID_SetFlags, ID_MemRead, ID_MemWrite, ID_RegWrite;
	
	logic [1:0] EX_Mem2Reg;
	logic [2:0] EX_ALUop;
	logic EX_ALUsrc, EX_SetFlags, EX_MemRead, EX_MemWrite, EX_RegWrite;
	
	logic [1:0] MEM_Mem2Reg;
	logic MEM_MemRead, MEM_MemWrite, MEM_RegWrite;
	
	logic [1:0] WB_Mem2Reg;
	logic WB_RegWrite;
	
	// IDEX
	logic [1:0] ForwardA, ForwardB;
	
	// hazard detection
	logic PCenable, IFIDenable;
	logic ID_wasRnRead, ID_wasRmRead, ID_Forw;
	logic ID_RegWrite_clean, ID_MemWrite_clean, ID_MemRead_clean, ID_SetFlags_clean;
	logic Flush, Taken;
	logic [31:0] IF_Instruction_clean;
	
	// EXMEM
	logic [63:0] EX_OutMuxA, EX_OutMuxB, MEM_OutMuxB;
	logic [4:0]  EX_Rn, EX_Rm, EX_Rd, MEM_Rd, WB_Rd;
	
	logic [63:0] EX_ALUresult;
	logic [63:0] EX_PCplus4, EX_ReadData1, EX_ReadData2, EX_ExtendedImm;
	
	logic [63:0] MEM_PCplus4, MEM_ALUresult, MEM_MemReadData;
	
	logic [63:0] WB_PCplus4, WB_ALUresult, WB_MemReadData;
	
	logic [63:0] ID_BranchData, ID_MuxForw;
	logic ID_ForwEX, ID_ForwMEM;
	
	
	/* ------------------------------------------STAGE 1------------------------------------------ */
	
	/* Program Counter */
	register PC (.clk, .reset, .enable(PCenable), .DataIn(NextAddress), .DataOut(Address));
	
	/* Instructional Memory */
	instructmem InstructionalMemory (.address(Address), .instruction(IF_Instruction), .clk);
	
	// for flushing
	mux2_1x32 IFFLUSH (.i0(IF_Instruction), .i1(32'b0), .sel(Flush), .out(IF_Instruction_clean));
	
	/* Adder for PC + 4 */
	alu adder (.A(Address), .B(64'd4), .cntrl(3'b010), .result(PCplus4),
				  .zero(), .overflow(), .carry_out(), .negative());
				  
	/* IF/ID - intstruction fetch/decode register */
	IFID_register IF_ID (.clk, .reset, .enable(IFIDenable), .IF_Instruction(IF_Instruction_clean),
	                     .IF_PC(Address), .IF_PCplus4(PCplus4), .ID_Instruction, .ID_PC, .ID_PCplus4);
	
	/* ------------------------------------------STAGE 2------------------------------------------ */
	
	/* Control Unit */
	
	// additional forwarding since moved branch to ID
	mux2_1x64 IDFORW_1 (.i0(ReadData2),  .i1(MEM_ALUresult), .sel(ID_ForwMEM), .out(ID_MuxForw));
	mux2_1x64 IDFORW_2 (.i0(ID_MuxForw), .i1(EX_ALUresult),  .sel(ID_ForwEX),  .out(ID_BranchData));
	
	// for forwarding - pass the flags from the ALU 
	mux2_1x4 FLAFORW (.i0(q_flags), .i1(d_flags), .sel(EX_SetFlags), .out(ID_flags));
	
	// check if R[Rt] == 64'b0
	logic isZero;
	NORx64 isRdZero (ID_BranchData, isZero);
	
	control_unit CU (.Instruction(ID_Instruction),
					     .Zero(isZero),             .oVerflow(ID_flags[2]), .Negative(ID_flags[0]),
						  .ALUop(ID_ALUop),          .SignEXop,              .PCsrc,                .Mem2Reg(ID_Mem2Reg),
						  .Reg2Loc,                  .RegWrite(ID_RegWrite), .ALUsrc(ID_ALUsrc), 
						  .MemWrite(ID_MemWrite),    .MemRead(ID_MemRead), 
						  .SetFlags(ID_SetFlags),    .RegWriteDest,
						  .ID_wasRnRead,             .ID_wasRmRead,          .ID_Forw);
						  
	/* Register File */
	
	// Reg2Loc					  
	assign ReadRegister1 = ID_Instruction[9:5]; // Rn
	assign Rm = ID_Instruction[20:16];
	assign Rd = ID_Instruction[4:0];
	mux2_1x5 REG2LOC (.i0(Rm), .i1(Rd), .sel(Reg2Loc), .out(ReadRegister2));
	
	// RegWriteDest
	mux2_1x5 REGWRITEDEST (.i0(Rd), .i1(5'd30), .sel(RegWriteDest), .out(WriteRegister));
	
	
	// INVERTED THE CLOCK FOR REGFILE
	not g1 (negative_clk, clk);
	regfile RegisterFile (.ReadRegister1,  .ReadRegister2, .WriteRegister(WB_Rd), .WriteData,
								 .RegWrite(WB_RegWrite), .clk(negative_clk), .ReadData1, .ReadData2);
				  
	/* Sign Extender */
	sign_extender SignExtender (.Instruction(ID_Instruction), .SignEXop, .Extended(ExtendedImm));
				  
	/* Adder/Subtractor for address calculations */
	alu alu_address (.A(ID_PC), .B(ExtendedImm), .cntrl(3'b010), .result(PCcalculated),
						  .zero(), .overflow(), .carry_out(), .negative());
	
	// PCsrc
	mux2_1x64 PCSRC_1 (.i0(PCplus4), .i1(PCcalculated), .sel(PCsrc[0]), .out(PCsrc_out));
	mux2_1x64 PCSRC_2 (.i0(PCsrc_out), .i1(ID_BranchData), .sel(PCsrc[1]), .out(NextAddress));
	
	// if taken, the instruction fetched is wrong
	or  #50 g2 (Taken, PCsrc[0], PCsrc[1]); // PCsrc != 00 (00 is for PC+4)
	// stalls override flushes 
	and #50 g3 (Flush, Taken, IFIDenable);
	
	hazard_detection_unit hazard (.ID_Rn(ReadRegister1),        .ID_Rm(ReadRegister2),
	                              .ID_wasRnRead, .ID_wasRmRead, .ID_Forw,
	                              .EX_MemRead,   .MEM_MemRead,  .EX_Rd, .MEM_Rd,
	                              .ID_RegWrite,  .ID_MemWrite,  .ID_MemRead, .ID_SetFlags,
	                              .ID_RegWrite_clean,           .ID_MemWrite_clean, .ID_MemRead_clean, .ID_SetFlags_clean,
	                              .PCenable,     .IFIDenable);
	
	IDEX_register ID_EX (.clk, .reset,   .enable(1'b1),
								.ID_ALUsrc,     .ID_SetFlags(ID_SetFlags_clean), .ID_MemRead(ID_MemRead_clean),
								.ID_MemWrite(ID_MemWrite_clean),  .ID_RegWrite(ID_RegWrite_clean),
								.ID_Mem2Reg,    .ID_ALUop,
			               .ID_PCplus4,    .ID_Rn(ReadRegister1),     .ID_Rm(ReadRegister2),        .ID_Rd(WriteRegister),
								.ID_ReadData1(ReadData1),     .ID_ReadData2(ReadData2),   .ID_ExtendedImm(ExtendedImm),
								.EX_ALUsrc,     .EX_SetFlags, .EX_MemRead, .EX_MemWrite,  .EX_RegWrite,  .EX_Mem2Reg, .EX_ALUop,
								.EX_Rn, .EX_Rm, .EX_Rd,       .EX_PCplus4, .EX_ReadData1, .EX_ReadData2, .EX_ExtendedImm);
	
	/* ------------------------------------------STAGE 3------------------------------------------ */
	
	logic [63:0] MuxA_out, MuxB_out;
	
	forwarding_unit forward_unit (.ID_Rm(ReadRegister2), .EX_Rn, .EX_Rm, .EX_RegWrite, .MEM_RegWrite, .WB_RegWrite,
	                              .EX_Rd, .MEM_Rd, .WB_Rd, .ForwardA, .ForwardB, .ID_ForwEX, .ID_ForwMEM);
	// Forward A
	mux2_1x64 AFORW_1 (.i0(EX_ReadData1), .i1(WriteData),     .sel(ForwardA[0]), .out(MuxA_out));
	mux2_1x64 AFORW_2 (.i0(MuxA_out),     .i1(MEM_ALUresult), .sel(ForwardA[1]), .out(EX_OutMuxA));
	// Forward B
	mux2_1x64 BFORW_1 (.i0(EX_ReadData2), .i1(WriteData),     .sel(ForwardB[0]), .out(MuxB_out));
	mux2_1x64 BFORW_2 (.i0(MuxB_out),     .i1(MEM_ALUresult), .sel(ForwardB[1]), .out(EX_OutMuxB));
	
	/* Arithmetic Logic Unit Main */
	
	// ALUsrc
	mux2_1x64 ALUSRC (.i0(EX_OutMuxB), .i1(EX_ExtendedImm), .sel(EX_ALUsrc), .out(ALUin2));
	
	alu alu_main (.A(EX_OutMuxA),  .B(ALUin2), .cntrl(EX_ALUop), .result(EX_ALUresult),
					  .zero(d_flags[3]), .overflow(d_flags[2]), .carry_out(d_flags[1]), .negative(d_flags[0]));
					  
	// save flags into the register
	flags_register Flags (.clk, .reset, .enable(EX_SetFlags), .DataIn(d_flags), .DataOut(q_flags));
	
	EXMEM_register EX_MEM (.clk, .reset, .enable(1'b1),
								  .EX_MemRead,  .EX_MemWrite,  .EX_RegWrite,  .EX_Mem2Reg,  .EX_Rd,  .EX_PCplus4,  .EX_ALUresult,  .EX_OutMuxB,
								  .MEM_MemRead, .MEM_MemWrite, .MEM_RegWrite, .MEM_Mem2Reg, .MEM_Rd, .MEM_PCplus4, .MEM_ALUresult, .MEM_OutMuxB);
	
	/* ------------------------------------------STAGE 4------------------------------------------ */
	
	// Data Memory
	datamem DataMemory (.address(MEM_ALUresult),  .write_enable(MEM_MemWrite), .read_enable(MEM_MemRead),
	                    .write_data(MEM_OutMuxB), .clk, .xfer_size(4'd8),      .read_data(MEM_MemReadData));
							  // for the current set of instructions we transfer 8 bytes
	
	MEMWB_register MEM_WB (.clk, .reset,  .enable(1'b1),
								  .MEM_RegWrite, .MEM_Mem2Reg, .MEM_Rd, .MEM_PCplus4, .MEM_MemReadData, .MEM_ALUresult,
								  .WB_RegWrite,  .WB_Mem2Reg,  .WB_Rd,  .WB_PCplus4, .WB_MemReadData,   .WB_ALUresult);
								  
	/* ------------------------------------------STAGE 5------------------------------------------ */
	
	// Mem2Reg
	
	/* 00 - ALUresult, 01 - MemrReadData, 10 - PCplus4 ->
	      1st 2-1mux: 0 - ALUresult, 1 - MemReadData; 2nd 2-1mux: 0 - output of the 1st, 1 - PCplus4
			mux 1 - bit 0, mux 2 - bit 1 */
	mux2_1x64 MEM2REG_1 (.i0(WB_ALUresult), .i1(WB_MemReadData), .sel(WB_Mem2Reg[0]), .out(Mem2Reg_out));
	mux2_1x64 MEM2REG_2 (.i0(Mem2Reg_out),   .i1(WB_PCplus4),    .sel(WB_Mem2Reg[1]), .out(WriteData));
							
	
	
endmodule // CPU_pipelined