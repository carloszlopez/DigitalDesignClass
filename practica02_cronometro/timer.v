`define TIMER_STATE_PAUSED 1'b0

module timer (
    input wire [3:0] KEY,
    input wire CLOCK_50,

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // pause start logic
    wire reset_n = KEY[0];
    reg start_pause_n, start_pause_n_prev, timer_state;

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
        // paused at reset
        timer_state <= `TIMER_STATE_PAUSED;
        start_pause_n <= 1'b1;
        start_pause_n_prev <= 1'b1;
        
        end else begin
            // toggle timer state only if start_pause_n changed from not 
            // pressed to pressed
            start_pause_n <= KEY[1];
            start_pause_n_prev <= start_pause_n;
            timer_state <= (!start_pause_n & start_pause_n_prev) ? 
                            ~timer_state : timer_state;
        end
    end

    // clock divisor: counts to 10ms
    wire tick_10ms;
    counter #(.SIZE(19), .MAX_CUT(499999)) counter_inst0 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );

    // timer counters MM:SS.cc (Max 59:59:99)
    wire [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec,
                units_of_min, tens_of_min;
    wire tick_100ms, tick_1s, tick_10s, tick_1min, tick_10min;
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst1 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_10ms),
        .cnt(hundredths_of_sec),
        .max_hit(tick_100ms)
    );    
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst2 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_100ms),
        .cnt(tenths_of_sec),
        .max_hit(tick_1s)
    );
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst3 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_1s),
        .cnt(units_of_sec),
        .max_hit(tick_10s)
    );
    counter #(.SIZE(4), .MAX_CUT(5)) counter_inst4 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_10s),
        .cnt(tens_of_sec),
        .max_hit(tick_1min)
    );
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst5 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_1min),
        .cnt(units_of_min),
        .max_hit(tick_10min)
    );
    counter #(.SIZE(4), .MAX_CUT(5)) counter_inst6 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enable(timer_state & tick_10min),
        .cnt(tens_of_min),
        .max_hit() // unconnected
    );

    // display
    display_7_seg display_inst0 (
        .SW(hundredths_of_sec),
        .HEX0(HEX0)
    );
    display_7_seg display_inst1 (
        .SW(tenths_of_sec),
        .HEX0(HEX1)
    );
    display_7_seg display_inst2 (
        .SW(units_of_sec),
        .HEX0(HEX2)
    );
    display_7_seg display_inst3 (
        .SW(tens_of_sec),
        .HEX0(HEX3)
    );
    display_7_seg display_inst4 (
        .SW(units_of_min),
        .HEX0(HEX4)
    );
    display_7_seg display_inst5 (
        .SW(tens_of_min),
        .HEX0(HEX5)
    );
endmodule