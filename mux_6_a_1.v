module mux_6_a_1
(
    input  wire [8:0] SW, 
    output wire [0:0] LEDR
);

	assign LEDR[0] = SW[8] ? (SW[7] ? 1'b0 : (SW[6] ? SW[5] : SW[4])) 
                        : (SW[7] ? (SW[6] ? SW[3] : SW[2]) : (SW[6] ? SW[1] : SW[0]));
endmodule
