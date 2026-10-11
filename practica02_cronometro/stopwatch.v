`define TIMER_STATE_PAUSED 1'b0

module stopwatch (
    input clk, reset_n, start_pause_n,

    output [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec,
                 units_of_min, tens_of_min
);

    // pause start logic
    reg start_pause_n_prev, timer_state;

    always @(posedge clk) begin
        if (!reset_n) begin
        // paused at reset
        timer_state <= `TIMER_STATE_PAUSED;
        start_pause_n_prev <= 1'b1;
        
        end else begin
            // toggle timer state only if start_pause_n changed from not 
            // pressed to pressed
            start_pause_n_prev <= start_pause_n;
            timer_state <= (!start_pause_n & start_pause_n_prev) ? 
                            ~timer_state : timer_state;
        end
    end

    // clock divisor: counts to 10ms
    wire tick_10ms;
    counter #(.SIZE(19), .MAX_CUT(499999)) counter_inst0 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );

    // timer counters MM:SS.cc (Max 59:59:99)
    wire tick_100ms, tick_1s, tick_10s, tick_1min, tick_10min;
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst1 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_10ms),
        .cnt(hundredths_of_sec),
        .max_hit(tick_100ms)
    );    
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst2 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_100ms),
        .cnt(tenths_of_sec),
        .max_hit(tick_1s)
    );
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst3 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_1s),
        .cnt(units_of_sec),
        .max_hit(tick_10s)
    );
    counter #(.SIZE(4), .MAX_CUT(5)) counter_inst4 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_10s),
        .cnt(tens_of_sec),
        .max_hit(tick_1min)
    );
    counter #(.SIZE(4), .MAX_CUT(9)) counter_inst5 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_1min),
        .cnt(units_of_min),
        .max_hit(tick_10min)
    );
    counter #(.SIZE(4), .MAX_CUT(5)) counter_inst6 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(timer_state & tick_10min),
        .cnt(tens_of_min),
        .max_hit() // unconnected
    );
endmodule