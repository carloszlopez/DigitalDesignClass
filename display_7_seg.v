module display_7_seg
(
    input  wire A, B, C, D,
    output wire S0, S1, S2, S3, S4, S5, S6
);

	assign S0 =	(~A & ~B & ~C & D) | (~A & B & ~C & ~D) | (A & ~B & C & D) 
				| (A & B & ~C & D);
	assign S1 =	(~A & B & ~C & D) | (A & B & ~D) | (A & C & D) | (B & C & ~D);
	assign S2 =	(~A & ~B & C & ~D) | (A & B & C) | (A & B & ~D);
	assign S3 = (~A & ~B & ~C & D) | (~A & B & ~C & ~D) | (A & ~B & C & ~D) 
				| (B & C & D);
	assign S4 = (~A & B & ~C) | (~A & D) | (~B & ~C & D);
	assign S5 = (~A & ~B & C) | (~A & ~B & D) | (~A & C & D) | (A & B & ~C & D);
	assign S6 = (~A & ~B & ~C) | (A & B & ~C & ~D);

endmodule