module UART 
(
    input [7:0] Tx_Data,
    input tx_send,
    input rx,
    input rx_flag_clr,
    input clk,
    input n_rst,

    output tx,
    output parity_error,
    output rx_flag,
    output [7:0] Rx_Data
);
    // /////////////////////////////////////////////////////////////////////////
    // uart receiver
    // /////////////////////////////////////////////////////////////////////////
    UART_Rx UART_Rx_Inst
    (
        .rx(rx),
        .rx_flag_clr(rx_flag_clr),
        .clk(clk),
        .reset(~n_rst),
        .enable(1'b1), // always enable

        .parity_error(parity_error),
        .rx_flag(rx_flag),
        .Rx_Data(Rx_Data)
    );

    // /////////////////////////////////////////////////////////////////////////
    // uart transmiter
    // /////////////////////////////////////////////////////////////////////////
    UART_Tx UART_Tx_Inst
    (
        .Tx_Data(Tx_Data),
        .tx_send(tx_send),
        .clk(clk),
        .reset(~n_rst),
        .enable(1'b1), // always enable

        .tx(tx)
    );

endmodule