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

    // Transition logic for UART state machine
    parameter UART_IN_IDLE = 2b00;
    parameter UART_IN_TX = 2b01;
    parameter UART_IN_RX = 2b10;
    parameter UART_IN_START_TX = 2b11;
    parameter UART_IN_STOP_TX = 2b11;

    wire [2:0] UART_state;
    wire [2:0] UART_state_next;

    always @(*) begin
        UART_state_next = UART_state;
        case (UART_state)
            UART_IN_IDLE:
            |   if (tx_send) UART_state_next = UART_IN_START_TX;
                else if (rx_flag) UART_state_next = UART_IN_START_RX;
            UART_IN_START_TX:
                if (tx_send) UART_state_next = UART_IN_TX;
            UART_IN_STOP_TX:
                if (tx_send) UART_state_next = UART_IN_IDLE;
            UART_IN_TX:
                if  (tx_send) UART_state_next = UART_IN_STOP_TX;
            UART_IN_RX: 
            default:
                UART_state_next = UART_IN_IDLE;
        endcase
    end


    // Instantiate the parallel_to_serial and serial_to_parallel modules
    parallel_to_serial #(.width(8)) tx_parallel_to_serial (
        .clk(clk),
        .n_rst(n_rst),
        .enable(tx_send),
        .d(Tx_Data),
        .serialQ(tx)
    );

    serial_to_parallel #(.width(8)) rx_serial_to_parallel (
        .clk(clk),
        .n_rst(n_rst),
        .enable(rx_flag),
        .d(rx),
        .Q(Rx_Data)
    );

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            // Reset logic
        end else begin
            // UART transmission and reception logic
        end
    end

endmodule