`timescale 1ns / 1ps
module UART_Top_tb ();

localparam BIT_TIME = 104167; // 9600 bauds in ns

reg CLOCK_50 = 1'b0;
reg [3:0] KEY;
reg [9:0] SW;
reg rx;
wire [35:0] GPIO;
wire [9:0] LEDR;
wire [6:0] HEX0, HEX1;

assign GPIO[4] = rx;
always #10 CLOCK_50 = ~CLOCK_50; // 20 ns period = 50 MHz

UART_Top UUT (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .GPIO(GPIO),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1)
);

// UUT receives "data" trough rx and transmit "data" trough tx.
task send_character;
    input [7:0] data;
    integer i;
    begin
        SW[7:0] = data;
        KEY[1] = 1'b0; // tx_send pulse
        #40;
        KEY[1] = 1'b1;

        rx = 1'b0; // Start
        #(BIT_TIME);
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i]; // LSB data
            #(BIT_TIME);
        end
        rx = ^data; // Even parity
        #(BIT_TIME);
        rx = 1'b1; // Stop
        #(BIT_TIME);

        KEY[2] = 1'b0; // Rx flag clean
        #60;
        KEY[2] = 1'b1;
        #2000000; // Pause 2 ms to allowed transmition finishing
    end
endtask

initial begin
    KEY = 4'b1110; // Reset is active, no buttons
    SW = 10'd0;
    rx = 1'b1; // RX line in idle
    #100;
    KEY[0] = 1'b1; // Deactivate reset
    #100;

    send_character(8'h61); // a
    send_character(8'h62); // b
    send_character(8'h63); // c

    $finish;
end
endmodule
