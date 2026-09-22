`timescale 1ns/1ps

module binary_to_bcd_tb;

    parameter LENGTH = 8;

    reg [LENGTH-1:0] binary_value;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    binary_to_bcd #(.LENGTH(LENGTH)) dut (
        .binary_value(binary_value),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    initial begin
        binary_value = 8'd0;
        #10;

        binary_value = 8'd7;    // BCD: 0, 0, 7
        #10;

        binary_value = 8'd25;   // BCD: 0, 2, 5
        #10;

        binary_value = 8'd99;   // BCD: 0, 9, 9
        #10;

        binary_value = 8'd123;  // BCD: 1, 2, 3
        #10;

        binary_value = 8'd255;  // BCD: 2, 5, 5
        #10;

        $stop;
    end

endmodule