module UART_Rx
(
    input rx,
    input rx_flag_clr,
    input clk,
    input reset,
    input enable,

    output reg parity_error,
    output reg rx_flag,
    output reg [7:0] Rx_Data
);
    // /////////////////////////////////////////////////////////////////////////
    // receiving logic
    // /////////////////////////////////////////////////////////////////////////
    reg receiving;
    reg parity;
    wire [4:0] half_bit_cnt;
    wire half_bit_tick;
    always @(posedge clk) begin
        if (reset) begin
            rx_flag <= 1'b0;
            parity_error <= 1'b0;
            Rx_Data <= 8'd0;
            receiving <= 1'b0;
            parity <= 1'b0;

        // no receiving, hangle the rx_flag clear and start bit detection
        end else if (enable && !receiving) begin
            receiving <= !rx;
            rx_flag <= rx_flag_clr ? 1'b0 : rx_flag;
        
        // receiving, enable does not affect if there receiving started
        end else if (receiving && half_bit_tick) begin
            // start, prepare to receive data if start bit is valid
            if ((half_bit_cnt == 5'd0)) begin
                if (rx) begin
                    receiving <= 1'b0;
                end else begin
                    receiving <= !rx;
                    rx_flag <= 1'b0;
                    parity_error <= 1'b0;
                    Rx_Data <= 8'd0;
                    parity <= 1'b0;
                end
            
            // store d0 and calculate parity
            end else if (half_bit_cnt == 5'd2) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d1 and calculate parity
            end else if (half_bit_cnt == 5'd4) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d2 and calculate parity
            end else if (half_bit_cnt == 5'd6) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d3 and calculate parity
            end else if (half_bit_cnt == 5'd8) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d4 and calculate parity
            end else if (half_bit_cnt == 5'd10) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d5 and calculate parity
            end else if (half_bit_cnt == 5'd12) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d6 and calculate parity
            end else if (half_bit_cnt == 5'd14) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;

            // store d7 and calculate parity
            end else if (half_bit_cnt == 5'd16) begin
                Rx_Data[(half_bit_cnt - 5'd2) >> 1'b1] <= rx;
                parity <= parity ^ rx;
            
            // check parity
            end else if (half_bit_cnt == 5'd18) begin
                parity_error <= (parity != rx);

            // stop
            end else if (half_bit_cnt == 5'd20) begin
                receiving <= 1'b0;
                rx_flag <=1;
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
        .reset(reset || !receiving),
        .enable(receiving), // always enabled
        .load(1'b0), // never reload
        .cnt_in(12'd0), // never reload
        
        .cnt(), // not used
        .max_hit(half_bit_tick)
    );

    // counter the half bit ticks
    counter #(
        .SIZE(4'd5),
        .MAX_CUT(5'd22),
        .COUNT_DOWN(1'b0)
    )
    counter_half_bit_position (
        .clk(clk),
        .reset(reset || !receiving),
        .enable(receiving && half_bit_tick),
        .load(1'b0), // never reload
        .cnt_in(5'd0), // never reload
        
        .cnt(half_bit_cnt),
        .max_hit() // not used
    );

endmodule

