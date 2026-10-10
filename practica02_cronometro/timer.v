`define TIMER_STATE_PAUSED 1'b0

module timer (
    input wire [3:0] KEY,
    input wire CLOCK_50,

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // pause start logic
    wire reset_n, start_pause_n;
    reg timer_state;
    assign reset_n = KEY[0];
    assign start_pause_n = KEY[1];

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
        // paused at reset
        timer_state <= `TIMER_STATE_PAUSED;
        
        // started if paused before
        // paused if started before
        end else if (!start_pause_n) begin
            timer_state <= ~timer_state;
        end
    end

    // clock divisor: counts to 10ms
    wire tick_10ms;
    counter #(.SIZE(19), .MAX_CUT(500000)) counter_inst0 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );

    // hundreths of seconds: counts to 9
    wire [3:0] hundredths_of_sec;
    wire tick_100ms;
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst1 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_10ms),
        .cnt(hundredths_of_sec), //unconnected
        .max_hit(tick_100ms)
    );

    display_7_seg display_inst0 (
        .SW(hundredths_of_sec),
        .HEX0(HEX0)
    );

    // just to generate RTL in quartus
    // assign HEX0 = timer_state ? 7'b1111001 : 7'b1000000;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
endmodule