/* flip-flop module */
module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	always_ff @(posedge clk)
	if (reset)
		q <= 0; // on reset, set to 0
	else
		q <= d; // otherwise out = d

endmodule // D_FF