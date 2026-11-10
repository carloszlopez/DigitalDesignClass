module UART_Top
(
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,

    inout [35:0] GPIO,
    
    output [9:0] LEDR,
    output [6:0] HEX0, 
    output [6:0] HEX1 
);
    // /////////////////////////////////////////////////////////////////////////
    // key monitoring
    // /////////////////////////////////////////////////////////////////////////
    wire key1_pressed;
    
    key_monitor key1_monitor (
    .clk(CLOCK_50),
    .reset(~KEY[0]),
    .enable(1'b1), // always enable
    .key_n(KEY[1]),

    .key_pressed(key1_pressed)
    );

    wire key2_pressed;
    
    key_monitor key2_monitor (
    .clk(CLOCK_50),
    .reset(~KEY[0]),
    .enable(1'b1), // always enable
    .key_n(KEY[2]),

    .key_pressed(key2_pressed)
    );

    // /////////////////////////////////////////////////////////////////////////
    // uart
    // /////////////////////////////////////////////////////////////////////////
    wire [7:0] rx_data;

    UART uart_inst(
        .Tx_Data(SW[7:0]),
        .tx_send(key1_pressed),
        .rx(GPIO[4]),
        .rx_flag_clr(key2_pressed),
        .clk(CLOCK_50),
        .n_rst(KEY[0]),

        .tx(GPIO[6]),
        .parity_error(LEDR[1]),
        .rx_flag(LEDR[0]),
        .Rx_Data(rx_data)
    );

    // /////////////////////////////////////////////////////////////////////////
    // display
    // /////////////////////////////////////////////////////////////////////////
    display_7_seg display_inst0 (
        .SW(rx_data[3:0]),
        .HEX0(HEX0)
    );

    display_7_seg display_inst1 (
        .SW(rx_data[7:4]),
        .HEX0(HEX1)
    );

endmodule
