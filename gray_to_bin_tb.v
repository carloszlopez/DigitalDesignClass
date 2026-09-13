`timescale 1ns/1ps

module gray_to_bin_tb;

    /* Parameters */
    parameter WIDTH = 4;

    /* Signals */
    reg     [WIDTH - 1 : 0] SW;
    wire    [WIDTH - 1 : 0] LEDR;

    /* Expected result */
    reg     [WIDTH - 1 : 0] EXPECTED;

    /* Loop variable */
    integer i;

    /* Instance of module to test */
    gray_to_bin #(
        .WIDTH(WIDTH)
    ) dut (
        .SW(SW),
        .LEDR(LEDR)
    );


    initial begin
        for (i = 0; i < (1 << WIDTH) ; i = i + 1) begin

            /* Expected value */
            EXPECTED = i;
            /* Gray value */
            SW = EXPECTED ^ (EXPECTED >> 1);
            #1;

            /* Check obtained value against the expected value */
            if (LEDR == EXPECTED) begin
                $display("OK: Gray=%b, Obtained=%b, Expected=%b",
                    SW, LEDR, EXPECTED);
            end
            else begin
                $display(
                    "ERROR: Gray=%b, Obtained=%b, esperado=%b",
                    SW, LEDR, EXPECTED);
            end
            #19;
        end
        $stop;
    end
endmodule