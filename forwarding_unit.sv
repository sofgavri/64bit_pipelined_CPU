/* forwarding unit */

module forwarding_unit (
	input  logic [4:0] ID_Rm,
	input  logic [4:0] EX_Rn,  EX_Rm,
	input  logic EX_RegWrite, MEM_RegWrite, WB_RegWrite,
	input  logic [4:0] EX_Rd, MEM_Rd, WB_Rd,
	output logic [1:0] ForwardA,
	output logic [1:0] ForwardB,
	output logic ID_ForwEX, ID_ForwMEM
);

	logic isEXvalid, isMEMvalid, isWBvalid;
	
	// bits indicating whether the instructions at those stages can be forwarded from
	// must write to a register AND must not be X31 (zero register)
	assign isEXvalid  = (EX_RegWrite  == 1'b1) && (EX_Rd  != 5'd31);
	assign isMEMvalid = (MEM_RegWrite == 1'b1) && (MEM_Rd != 5'd31);
	assign isWBvalid  = (WB_RegWrite  == 1'b1) && (WB_Rd  != 5'd31);
	
	// selects for additional forwarding (ID stage) since
	// branching was moved to stage ID - need to be handled too
	assign ID_ForwEX  = (isEXvalid  == 1'b1) && (EX_Rd  == ID_Rm);
	assign ID_ForwMEM = (isMEMvalid == 1'b1) && (MEM_Rd == ID_Rm);

	always_comb begin
	
		ForwardA = 2'b0;
		ForwardB = 2'b0;
		
		/* for the case when both MEM and EX hazards are present, EX hazard overwrites MEM
		   (since we don't want reading/writing into the same register) */
			
		// for Rn
		if (isMEMvalid && (MEM_Rd == EX_Rn)) begin
			ForwardA = 2'b10; end // EX hazard		
		else if (isWBvalid && (WB_Rd == EX_Rn)) begin
			ForwardA = 2'b01; end // MEM hazard
		
		// for Rm
		if (isMEMvalid && (MEM_Rd == EX_Rm)) begin
			ForwardB = 2'b10; end// EX hazard
		else if (isWBvalid && (WB_Rd == EX_Rm)) begin
			ForwardB = 2'b01; end // MEM hazard
	end
	
endmodule // forwarding_unit