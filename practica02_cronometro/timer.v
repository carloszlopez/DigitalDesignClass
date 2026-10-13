module timer (
    input clk, reset, enable, tick_10ms, load,
    input [3:0] hundredths_of_sec_in, tenths_of_sec_in, units_of_sec_in, tens_of_sec_in,
                 units_of_min_in, tens_of_min_in,

    output [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec,
                 units_of_min, tens_of_min
);
    // ////////////////////////////////////////////////////////////////////////
    // timer counters MM:SS.cc (Max 59:59:99) (start as 02:13.99)
    // ////////////////////////////////////////////////////////////////////////
    wire tick_100ms, tick_1s, tick_10s, tick_1min, tick_10min;
    counter #(.SIZE(3'd4), .MAX_CUT(4'd9), .COUNT_DOWN(1'b1)) counter_inst1 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_10ms),
        .load(load),
        .cnt_in(hundredths_of_sec_in),
        .cnt(hundredths_of_sec),
        .max_hit(tick_100ms)
    );    
    counter #(.SIZE(3'd4), .MAX_CUT(4'd9), .COUNT_DOWN(1'b1)) counter_inst2 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_100ms),
        .load(load),
        .cnt_in(tenths_of_sec_in),
        .cnt(tenths_of_sec),
        .max_hit(tick_1s)
    );
    counter #(.SIZE(3'd4), .MAX_CUT(4'd9), .COUNT_DOWN(1'b1)) counter_inst3 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_1s),
        .load(load),
        .cnt_in(units_of_sec_in),
        .cnt(units_of_sec),
        .max_hit(tick_10s)
    );
    counter #(.SIZE(3'd4), .MAX_CUT(3'd5), .COUNT_DOWN(1'b1)) counter_inst4 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_10s),
        .load(load),
        .cnt_in(tens_of_sec_in),
        .cnt(tens_of_sec),
        .max_hit(tick_1min)
    );
    counter #(.SIZE(3'd4), .MAX_CUT(4'd9), .COUNT_DOWN(1'b1)) counter_inst5 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_1min),
        .load(load),
        .cnt_in(units_of_min_in),
        .cnt(units_of_min),
        .max_hit(tick_10min)
    );
    counter #(.SIZE(3'd4), .MAX_CUT(3'd5), .COUNT_DOWN(1'b1)) counter_inst6 (
        .clk(clk),
        .reset(reset),
        .enable(enable & tick_10min),
        .load(load),
        .cnt_in(tens_of_min_in),
        .cnt(tens_of_min),
        .max_hit() // unconnected
    );
endmodule