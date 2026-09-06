module tarea03_mux_2_a_1
(
    input  wire[3:0] A, B,
    input  wire SEL0,	 
    output wire[3:0] S0
);

	assign S0 = SEL0 ? B : A;
endmodule
