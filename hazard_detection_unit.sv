/* hazard detection unit - since forwarding can't fix load-use and load-branch,
	we have to stall the pipeline */

module hazard_detection_unit (
	input  logic ID_RegWrite, ID_MemWrite, ID_MemRead, ID_SetFlags,
	input  logic ID_wasRnRead, ID_wasRmRead,
	input  logic [4:0] ID_Rn, ID_Rm,
	input  logic ID_Forw, // is forwarding needed in ID for branching
	input  logic EX_MemRead, MEM_MemRead,
	input  logic [4:0] EX_Rd, MEM_Rd,
	output logic ID_RegWrite_clean, ID_MemWrite_clean, ID_MemRead_clean, ID_SetFlags_clean,
	output logic PCenable, IFIDenable
);

	logic isEXload, isMEMload;
	logic RnConflict, RmConflict;
	logic EX2Branch, MEM2Branch;
	logic LoadUse, LoadBranch;
	
	// load in stages where destination is valid
	assign isEXload  = (EX_MemRead == 1'b1) && (EX_Rd  != 5'd31);
	assign isMEMload = (MEM_MemRead == 1'b1) && (MEM_Rd != 5'd31);
	
	// if in ID register is read and its written into in EX
	assign RnConflict = (ID_wasRnRead == 1'b1) && (EX_Rd == ID_Rn);
	assign RmConflict = (ID_wasRmRead == 1'b1) && (EX_Rd == ID_Rm);
	
	// LDUR in EX inputs ID's instruction
	assign LoadUse = (isEXload == 1'b1) && (RnConflict || RmConflict);
	
	// load data not ready, but ID needs it now
	assign EX2Branch  = (isEXload == 1'b1)  && (EX_Rd  == ID_Rm);
	assign MEM2Branch = (isMEMload == 1'b1) && (MEM_Rd == ID_Rm);
	
	// branch in ID, load in EX or MEM
	assign LoadBranch = ID_Forw && (EX2Branch || MEM2Branch);
	
	always_comb begin
		PCenable          = 1'b1;
		IFIDenable        = 1'b1;
		ID_RegWrite_clean = ID_RegWrite;
		ID_MemWrite_clean = ID_MemWrite;
		ID_MemRead_clean  = ID_MemRead;
		ID_SetFlags_clean = ID_SetFlags;
		
		if (LoadUse || LoadBranch) begin
			PCenable          = 1'b0; // hold PC
			IFIDenable        = 1'b0; // hold the instr in ID
			// send nop to EX
			ID_RegWrite_clean = 1'b0;
			ID_MemWrite_clean = 1'b0;
			ID_MemRead_clean  = 1'b0;
			ID_SetFlags_clean = 1'b0;
		end
	end
	
endmodule // hazard_detection_unit