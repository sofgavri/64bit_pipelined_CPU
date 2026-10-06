module control_unit (
	input  logic [31:0] Instruction,
	input  logic Zero, oVerflow, Negative,
	output logic [2:0] ALUop,
	output logic [1:0] SignEXop, // for I (00), B (01), CB (10), and D (11) types of instructions (2^2)
	output logic [1:0] PCsrc,    // for BR - branch to a register, another input needed; 
										  // 00: PC+4, 01: branch to calculated offset, 10: branch to address from a register
	output logic [1:0] Mem2Reg,  // needs another input for BL (X30 = PC + 4) on the next cc (save in WriteData)
	output logic Reg2Loc, RegWrite, ALUsrc,
	output logic MemWrite, MemRead,
	output logic SetFlags, RegWriteDest, // for writing back the register for BL
	output logic ID_wasRnRead, ID_wasRmRead, ID_Forw // for the hazard detection unit
);

	logic [10:0] opcode;
	assign opcode = Instruction[31:21];
	
	always_comb begin
		ALUop    = 3'b0;
		SignEXop = 2'b0; PCsrc    = 2'b0; Mem2Reg  = 2'b0;
		Reg2Loc  = 1'b0; RegWrite = 1'b0; ALUsrc   = 1'b0;
		MemWrite = 1'b0; MemRead  = 1'b0;
		SetFlags = 1'b0; RegWriteDest = 1'b0;
		ID_wasRnRead = 1'b0; ID_wasRmRead = 1'b0; ID_Forw = 1'b0;
		
		case (opcode) inside
			[11'h488 : 11'h489] : begin ALUop = 3'b010;   RegWrite = 1'b1; ALUsrc = 1'b1; ID_wasRnRead = 1'b1; end // ADDI
			 11'h558 			  : begin ALUop = 3'b010;   RegWrite = 1'b1; SetFlags = 1'b1; ID_wasRnRead = 1'b1; ID_wasRmRead = 1'b1; end // ADDS
			[11'h0A0 : 11'h0BF] : begin SignEXop = 2'b01; PCsrc  = 2'b01; end // B
			[11'h2A0 : 11'h2A7] : begin 
											SignEXop = 2'b10; // B.cond
											if (Instruction[4:0] == 5'h0B && Negative != oVerflow)
												begin PCsrc = 2'b01; end //for LT only
										 end 
			[11'h4A0 : 11'h4BF] : begin SignEXop = 2'b01; RegWrite = 1'b1; Mem2Reg = 2'b10;
												 PCsrc = 2'b01;    RegWriteDest = 1'b1; end // BL
												 
			11'h6B0 				  : begin Reg2Loc = 1'b1;   PCsrc = 2'b10;  ID_wasRmRead = 1'b1; ID_Forw = 1'b1; end // BR
			
			[11'h5A0 : 11'h5A7] : begin
											SignEXop = 2'b10; // CB type
											Reg2Loc = 1'b1; // get R[Rd]
											ID_wasRmRead = 1'b1; ID_Forw = 1'b1;
											if (Zero == 1'b1)
												begin PCsrc = 2'b01; end
										 end // CBZ
			11'h7C2 				  : begin RegWrite = 1'b1;  SignEXop = 2'b11; ALUsrc = 1'b1;
												 ALUop = 3'b010;   MemRead = 1'b1;   Mem2Reg = 2'b01; ID_wasRnRead = 1'b1; end // LDUR
			11'h7C0 				  : begin SignEXop = 2'b11; ALUsrc = 1'b1;
												 ALUop = 3'b010;   MemWrite = 1'b1;  Reg2Loc = 1'b1; ID_wasRnRead = 1'b1; ID_wasRmRead = 1'b1; end // STUR
			11'h758             : begin ALUop = 3'b011;   RegWrite = 1'b1;  SetFlags = 1'b1;  ID_wasRnRead = 1'b1; ID_wasRmRead = 1'b1;end // SUBS
		endcase
	end

	
endmodule // control_unit

module control_unit_tb ();
	logic	[31:0]	Instruction;
	logic				Zero, oVerflow, Negative;
	logic	[2:0]		ALUop;
	logic	[1:0]		SignEXop, PCsrc, Mem2Reg;
	logic				Reg2Loc, RegWrite, ALUsrc, MemWrite, MemRead, SetFlags, RegWriteDest;
	logic				ID_wasRnRead, ID_wasRmRead, ID_Forw;
 
	// assembly for test
	parameter ADDI = 32'h910020E6, // ADDI X6, X7, #8
				 ADDS = 32'hAB020023, // ADDS X3, X1, X2
				 SUBS = 32'hEB030085, // SUBS X5, X4, X3
				 LDUR = 32'hF8410149, // LDUR X9, [X10, #16]
				 STUR = 32'hF8010149, // STUR X9, [X10, #16]
				 B    = 32'h14000004, // B 4
				 BL   = 32'h94000008, // BL -8
				 BR   = 32'hD600001E, // BR X30
				 CBZ  = 32'hB4FFFF68, // CBZ X8, -5
				 BLT  = 32'h5400020B; // B.LT 16
 
	control_unit dut (.*);
 
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	parameter delay = 100000;
 
	initial begin
 
		Zero = 0; oVerflow = 0; Negative = 0;
 
		// ADDI
		$display("%t testing ADDI", $time);
		Instruction = ADDI; #(delay);
		assert(ALUop == 3'b010   && SignEXop == 2'b00 && PCsrc == 2'b00 && Mem2Reg == 2'b00
					&& Reg2Loc == 0 && RegWrite == 1     && ALUsrc == 1    && MemWrite == 0
					&& MemRead == 0 && SetFlags == 0     && RegWriteDest == 0);
		// ADDS
		$display("%t testing ADDS", $time);
		Instruction = ADDS; #(delay);
		assert(ALUop == 3'b010    && ALUsrc == 0  && RegWrite == 1 && SetFlags == 1
					&& MemWrite == 0 && MemRead == 0 && PCsrc == 2'b00);
		// SUBS
		$display("%t testing SUBS", $time);
		Instruction = SUBS; #(delay);
		assert(ALUop == 3'b011    && ALUsrc == 0  && RegWrite == 1 && SetFlags == 1
					&& MemWrite == 0 && MemRead == 0 && PCsrc == 2'b00);
		// LDUR
		$display("%t testing LDUR", $time);
		Instruction = LDUR; #(delay);
		assert(ALUop == 3'b010   && SignEXop == 2'b11 && ALUsrc == 1 && RegWrite == 1
					&& MemRead == 1 && Mem2Reg == 2'b01  && MemWrite == 0);
		// STUR
		$display("%t testing STUR", $time);
		Instruction = STUR; #(delay);
		assert(ALUop == 3'b010 && SignEXop == 2'b11 && ALUsrc == 1 && RegWrite == 0
					&& MemWrite == 1 && Reg2Loc == 1 && MemRead == 0);
		// B
		$display("%t testing B", $time);
		Instruction = B; #(delay);
		assert(PCsrc == 2'b01 && SignEXop == 2'b01 && RegWrite == 0 && MemWrite == 0);
		// BL
		$display("%t testing BL", $time);
		Instruction = BL; #(delay);
		assert(PCsrc == 2'b01 && SignEXop == 2'b01 && RegWrite == 1
					&& RegWriteDest == 1 && Mem2Reg == 2'b10);
		// BR
		$display("%t testing BR", $time);
		Instruction = BR; #(delay);
		assert(PCsrc == 2'b10 && Reg2Loc == 1 && RegWrite == 0);
 
		// CBZ not taken
		$display("%t testing CBZ not taken", $time);
		Zero = 0; Instruction = CBZ; #(delay);
		assert(PCsrc == 2'b00 && SignEXop == 2'b10 && Reg2Loc == 1 && RegWrite == 0 && SetFlags == 0);
		
		// taken
		$display("%t testing CBZ taken", $time);
		Zero = 1; Instruction = CBZ; #(delay);
		assert(PCsrc == 2'b01 && SignEXop == 2'b10 && Reg2Loc == 1);
		
		Zero = 0;
		
		// B.LT not taken
		$display("%t testing B.LT not taken", $time);
		Negative = 0; oVerflow = 0; Instruction = BLT; #(delay);
		assert(PCsrc == 2'b00 && SignEXop == 2'b10);
		// taken
		$display("%t testing B.LT taken", $time);
		Negative = 1; oVerflow = 0; Instruction = BLT; #(delay);
		assert(PCsrc == 2'b01 && SignEXop == 2'b10);
		Negative = 0; oVerflow = 0;
 
		$stop;
	end
endmodule