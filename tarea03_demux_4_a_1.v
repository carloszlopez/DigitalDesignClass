module tarea03_demux_4_a_1
(
    input  wire A, SEL0, SEL1,
    output wire S0, S1, S2, S3
);

	assign S0 = A & ~SEL0 & ~SEL1;
	assign S1 = A &  SEL0 & ~SEL1;
	assign S2 = A & ~SEL0 &  SEL1;
	assign S3 = A &  SEL0 &  SEL1;

endmodule
