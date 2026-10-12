module stopwatch (
    input clk, reset, start_pause,

    output [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec,
                 units_of_min, tens_of_min
);
    // ////////////////////////////////////////////////////////////////////////
    // pause start logic
    // ////////////////////////////////////////////////////////////////////////
    reg start_pause_prev, timer_state, timer_state_prev, load;

    always @(posedge clk) begin
        if (reset) begin
            // timer state is paused on reset (1 means started, 0 means paused)
            timer_state <= 1'b0;
            start_pause_prev <= 1'b0;
        
        end else begin
            // get last start pause
            start_pause_prev <= start_pause;
            // toggle timer state only if start pause changed to pressed
            timer_state <= (start_pause & !start_pause_prev) ? 
                            ~timer_state : timer_state;
            timer_state_prev <= timer_state;

            // load counters only if timer state changed to started
            load <= (timer_state & !timer_state_prev) ? 1'b1 : 1'b0;
        end
    end

    // ////////////////////////////////////////////////////////////////////////
    // 10ms counter
    // ////////////////////////////////////////////////////////////////////////
    wire tick_10ms;
    counter #(.SIZE(19), .MAX_CUT(499999), .COUNT_DOWN(0)) counter_inst0 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state),
        .load(load),
        .cnt_in(19'd0),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );

    // ////////////////////////////////////////////////////////////////////////
    // timer counters MM:SS.cc (Max 59:59:99) (start as 02:13.99)
    // ////////////////////////////////////////////////////////////////////////
    wire tick_100ms, tick_1s, tick_10s, tick_1min, tick_10min;
    counter #(.SIZE(4), .MAX_CUT(9), .COUNT_DOWN(0)) counter_inst1 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_10ms),
        .load(load),
        .cnt_in(4'd9),
        .cnt(hundredths_of_sec),
        .max_hit(tick_100ms)
    );    
    counter #(.SIZE(4), .MAX_CUT(9), .COUNT_DOWN(0)) counter_inst2 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_100ms),
        .load(load),
        .cnt_in(4'd9),
        .cnt(tenths_of_sec),
        .max_hit(tick_1s)
    );
    counter #(.SIZE(4), .MAX_CUT(9), .COUNT_DOWN(0)) counter_inst3 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_1s),
        .load(load),
        .cnt_in(4'd3),
        .cnt(units_of_sec),
        .max_hit(tick_10s)
    );
    counter #(.SIZE(4), .MAX_CUT(5), .COUNT_DOWN(0)) counter_inst4 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_10s),
        .load(load),
        .cnt_in(4'd1),
        .cnt(tens_of_sec),
        .max_hit(tick_1min)
    );
    counter #(.SIZE(4), .MAX_CUT(9), .COUNT_DOWN(0)) counter_inst5 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_1min),
        .load(load),
        .cnt_in(4'd2),
        .cnt(units_of_min),
        .max_hit(tick_10min)
    );
    counter #(.SIZE(4), .MAX_CUT(5), .COUNT_DOWN(0)) counter_inst6 (
        .clk(clk),
        .reset(reset),
        .enable(timer_state & tick_10min),
        .load(load),
        .cnt_in(4'd0),
        .cnt(tens_of_min),
        .max_hit() // unconnected
    );
endmodule