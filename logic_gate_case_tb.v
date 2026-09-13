`timescale 1ns/1ps

module logic_gate_case_tb;
    reg     [1 : 0] SW;
    wire    [4 : 0] RESULT;
    reg     [4 : 0] EXPECTED;

    /* Loop variable */
    integer i;

    /* Local parameters */
    localparam NAND_GATE = 0;
    localparam NOR_GATE  = 1;
    localparam XOR_GATE  = 2;
    localparam AND_GATE  = 3;
    localparam OR_GATE   = 4;

    /* Instances of module to test */
    logic_gate_case #(
        .LOGIC_GATE(NAND_GATE)
    ) dut_NAND_GATE (
        .SW(SW),
        .LEDR(RESULT[NAND_GATE])
    );
    logic_gate_case #(
        .LOGIC_GATE(NOR_GATE)
    ) dut_NOR_GATE (
        .SW(SW),
        .LEDR(RESULT[NOR_GATE])
    );
    logic_gate_case #(
        .LOGIC_GATE(XOR_GATE)
    ) dut_XOR_GATE (
        .SW(SW),
        .LEDR(RESULT[XOR_GATE])
    );
    logic_gate_case #(
        .LOGIC_GATE(AND_GATE)
    ) dut_AND_GATE (
        .SW(SW),
        .LEDR(RESULT[AND_GATE])
    );
    logic_gate_case #(
        .LOGIC_GATE(OR_GATE)
    ) dut_OR_GATE (
        .SW(SW),
        .LEDR(RESULT[OR_GATE])
    );

    initial begin

        /* Check for all input combinations */
        for (i = 0; i < 4 ; i = i + 1) begin
            SW = i;
            EXPECTED[NAND_GATE] = ~(SW[0] & SW[1]); // NAND
            EXPECTED[NOR_GATE]  = ~(SW[0] | SW[1]); // NOR
            EXPECTED[XOR_GATE]  =  (SW[0] ^ SW[1]); // XOR
            EXPECTED[AND_GATE]  =  (SW[0] & SW[1]); // AND
            EXPECTED[OR_GATE]   =  (SW[0] | SW[1]); // OR
            #10;

            /* Check for all results */
            if (RESULT == EXPECTED) begin
                $display("OK");
            end
            else begin
                $display("ERROR");
            end
                $display("NAND_GATE: SW[0]:%b SW[0]:%b = %b", 
                        SW[0],  SW[1], RESULT[NAND_GATE]);
                $display("NOR_GATE: SW[0]:%b SW[0]:%b = %b", 
                        SW[0],  SW[1], RESULT[NOR_GATE]);
                $display("XOR_GATE: SW[0]:%b SW[0]:%b = %b", 
                        SW[0],  SW[1], RESULT[XOR_GATE]);
                $display("AND_GATE: SW[0]:%b SW[0]:%b = %b", 
                        SW[0],  SW[1], RESULT[AND_GATE]);
                $display("OR_GATE: SW[0]:%b SW[0]:%b = %b", 
                        SW[0],  SW[1], RESULT[OR_GATE]);
        end
        $stop;
    end
endmodule