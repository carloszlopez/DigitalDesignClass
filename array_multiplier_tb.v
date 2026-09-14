module array_multiplier_tb;
    /* Parameters */
    parameter width = 8;

    /* Signals */
    reg [width-1:0] a, b;
    reg [2*width-1:0] expected;
    wire [2*width-1:0] y;

    /* Loop variables */
    integer i,j,error;

    /* Instance to test */
    array_multiplier #(
        .width(width)
    ) dut_array_multiplier (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        error = 0;

        /* a loop */
        for (i = 0; i < (1<<width) ; i = i + 1) begin
            a = i;

            /* b loop */
            for (j = 0; j < (1<<width) ; j = j + 1) begin
                b = j;
                expected = a * b;
                #1;

                /* Check result */
                if (y == expected) begin
                    $display("OK: a=%0d b=%0d y=%0d expected=%0d",
                             a, b, y, expected);
                end
                else begin
                    error = error + 1;
                    $display("ERROR: a=%0d b=%0d y=%0d expected=%0d",
                             a, b, y, expected);
                end
            end
        end
        $display("Test completed. Errors: %0d", error);
        $stop;
    end
endmodule