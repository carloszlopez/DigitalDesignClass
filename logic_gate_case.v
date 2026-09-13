module logic_gate_case #(
	parameter integer LOGIC_GATE = 0
)(
    input [1:0] SW,
    output reg [0:0] LEDR
);

    localparam NAND_GATE = 0;
    localparam NOR_GATE  = 1;
    localparam XOR_GATE  = 2;
    localparam AND_GATE  = 3;
    localparam OR_GATE   = 4;

	always @ * begin
        case (LOGIC_GATE)
            NAND_GATE:
                LEDR = ~(SW[0] & SW[1]);
            NOR_GATE:
                LEDR = ~(SW[0] | SW[1]);
            XOR_GATE:
                LEDR = SW[0] ^ SW[1];
            AND_GATE:
                LEDR = SW[0] & SW[1];
            OR_GATE:
                LEDR = SW[0] | SW[1];
            default: 
            LEDR = 1'b0;
        endcase
	end
endmodule