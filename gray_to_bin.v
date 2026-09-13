module gray_to_bin #(
	parameter WIDTH = 4
)(
    input [WIDTH-1:0] SW,
    output reg [WIDTH-1:0] LEDR
);


    /* Iteration */
    integer i;

	always @ * begin
        /* Most significant WIDTH-1 bit */
        LEDR[WIDTH-1] = SW[WIDTH-1];

        /* Bits WIDTH-2 to 0 */
        for (i = WIDTH-2; i >= 0 ; i = i - 1) begin
            LEDR[i] = SW[i] ^ LEDR[i+1];
        end
	end
endmodule