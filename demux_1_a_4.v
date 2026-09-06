module demux_1_a_4
(
    input  wire [2:0] SW,
    output wire [3:0] LEDR
);

	assign LEDR[0] = SW[0] & ~SW[1] & ~SW[2];
	assign LEDR[1] = SW[0] &  SW[1] & ~SW[2];
	assign LEDR[2] = SW[0] & ~SW[1] &  SW[2];
	assign LEDR[3] = SW[0] &  SW[1] &  SW[2];

endmodule
