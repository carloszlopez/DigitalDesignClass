module UART_Tx
(
    input [7:0] Tx_Data,
    input tx_send,
    input clk,
    input reset,
    input enable,

    output reg tx
);
    // /////////////////////////////////////////////////////////////////////////
    // transmit logic
    // /////////////////////////////////////////////////////////////////////////
    reg transmiting;
    reg parity;
    wire [9:0] half_bit_cnt;
    wire half_bit_tick;
    always @(posedge clk) begin
        if (reset) begin
            transmiting <= 1'b0;
            tx <= 1'b1;
            parity <= 1'b0;

        // no transmiting, handle the start of transmition and clear parity
        end else if (enable && !transmiting) begin
            transmiting <= tx_send;
            parity <= 1'b0;
        
        // transmiting, enable does not affect if transmiting started
        end else if (transmiting && half_bit_tick) begin
            // start, send start bit
            if ((half_bit_cnt == 4'd0)) begin
                tx <= 1'b0;
            
            // send d0 and calculate parity
            end else if (half_bit_cnt == 10'd2) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d1 and calculate parity
            end else if (half_bit_cnt == 10'd4) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d2 and calculate parity
            end else if (half_bit_cnt == 10'd6) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d3 and calculate parity
            end else if (half_bit_cnt == 10'd8) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d4 and calculate parity
            end else if (half_bit_cnt == 10'd10) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d5 and calculate parity
            end else if (half_bit_cnt == 10'd12) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d6 and calculate parity
            end else if (half_bit_cnt == 10'd14) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];

            // send d7 and calculate parity
            end else if (half_bit_cnt == 10'd16) begin
                tx <= Tx_Data[(half_bit_cnt - 2) >> 1];
                parity <= parity ^ Tx_Data[(half_bit_cnt - 2) >> 1];
            
            // send parity
            end else if (half_bit_cnt == 10'd18) begin
                tx <= parity;

            // send stop bit
            end else if (half_bit_cnt == 10'd20) begin
                tx <= 1'b1;

            // stop transmitting
            end else if (half_bit_cnt == 10'd22) begin
                transmiting <= 1'b0;
            end
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // Half bit counter
    // /////////////////////////////////////////////////////////////////////////
    // generate a tick every half bit

    counter #(
        .SIZE(4'd12),
        .MAX_CUT(12'd2604),
        .COUNT_DOWN(1'b0)
    )
    counter_half_bit (
        .clk(clk),
        .reset(reset || !transmiting),
        .enable(transmiting), // always enabled
        .load(1'b0), // never reload
        .cnt_in(1'b0), // never reload
        
        .cnt(), // not used
        .max_hit(half_bit_tick)
    );

    // counter the half bit ticks
    counter #(
        .SIZE(4'd10),
        .MAX_CUT(10'd22),
        .COUNT_DOWN(1'b0)
    )
    counter_half_bit_position (
        .clk(clk),
        .reset(reset || !transmiting),
        .enable(transmiting && half_bit_tick),
        .load(1'b0), // never reload
        .cnt_in(1'b0), // never reload
        
        .cnt(half_bit_cnt),
        .max_hit() // not used
    );

endmodule
