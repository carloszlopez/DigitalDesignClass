module tarea03_mux_6_a_1
(
    input  wire A, B, C, D, E, F, SEL0, SEL1, SEL2, 
    output wire S0
);

	assign S0 = SEL2 ? (SEL1 ? 1'b0 : (SEL0 ? F : E)) 
                        : (SEL1 ? (SEL0 ? D : C) : (SEL0 ? B : A));
endmodule
