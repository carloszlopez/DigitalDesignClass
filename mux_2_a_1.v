module mux_2_a_1
(
    input  wire[8:0] SW,	 
    output wire[3:0] LEDR
);

	assign LEDR = SW[8] ? SW[7:4] : SW[3:0];
endmodule
