module display_control #(
    parameter DIGIT_NUM = 6
)(
    input clk,
    input reset,
    input enable,
    input load,
    input [DIGIT_NUM-1:0] blink_control,
    input [DIGIT_NUM*4-1:0] digits,

    output reg [DIGIT_NUM*7-1:0] hex
);
    // ////////////////////////////////////////////////////////////////////////
    // 250ms tick generation
    // ////////////////////////////////////////////////////////////////////////
    wire tick_250ms;
    reg blink_signal;

    counter #(.SIZE(5'd24), .MAX_CUT(24'd12499999),
              .COUNT_DOWN(1'b0)) counter_blink (
        // inputs
        .clk(clk),
        .reset(reset),
        .enable(enable),

        // outputs
        .load(load),
        .cnt_in(24'd0),
        .cnt(), //unconnected
        .max_hit(tick_250ms)
    );

    // toggle blink_signal every tick_250ms
    always @(posedge clk) begin
        if (reset) begin
            blink_signal <= 1'b0;

        end else if (tick_250ms) begin
            blink_signal <= ~blink_signal;
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // register outputs, display is off on reset and on blink functionality
    // /////////////////////////////////////////////////////////////////////////
    genvar i;

    generate
        for (i = 0; i < DIGIT_NUM; i = i + 1) begin : gen_display
            wire [6:0] next_hex;

            display_7_seg decoder (
                .SW(digits[i*4 +: 4]),
                .HEX0(next_hex)
            );

        always @(posedge clk) begin
            if (reset)
                hex[i*7 +: 7] <= 7'b1111111;
            else if (enable)
                hex[i*7 +: 7] <=
                    (blink_control[i] && blink_signal) ? 7'b1111111 : next_hex;
        end
    end
    endgenerate
endmodule