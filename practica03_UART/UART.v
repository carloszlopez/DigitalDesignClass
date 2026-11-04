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
)
    parameter BAUD_RATE = 9600;

    Shift_Register #(.width(8)) tx_shift_reg (
        .clk(clk),
        .n_rst(n_rst),
        .enable(tx_send),
        .d(Tx_Data[7]),
        .Q(tx_shift_out)
    );

    Shift_Register #(.width(8)) rx_shift_reg (
        .clk(clk),
        .n_rst(n_rst),
        .enable(rx_flag),
        .d(rx),
        .Q(rx_shift_out)
    );

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            // Reset logic
        end else begin
            // UART transmission and reception logic
        end
    end

endmodule