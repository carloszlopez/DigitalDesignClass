module practica02 (
    input wire [3:0] KEY,
    input wire [9:0] SW,
    input wire CLOCK_50,

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    // /////////////////////////////////////////////////////////////////////////
    // stopwatch
    // /////////////////////////////////////////////////////////////////////////
    wire [3:0] stopwatch_hundredths_of_sec, stopwatch_tenths_of_sec,
               stopwatch_units_of_sec, stopwatch_tens_of_sec, 
               stopwatch_units_of_min, stopwatch_tens_of_min;
    
    stopwatch stopwatch_inst (
        .clk(CLOCK_50), .reset(SW[0]), .start_pause(~KEY[0]),

        .hundredths_of_sec(stopwatch_hundredths_of_sec),
        .tenths_of_sec(stopwatch_tenths_of_sec), 
        .units_of_sec(stopwatch_units_of_sec), 
        .tens_of_sec(stopwatch_tens_of_sec),
        .units_of_min(stopwatch_units_of_min), 
        .tens_of_min(stopwatch_tens_of_min)
    );

    // /////////////////////////////////////////////////////////////////////////
    // timer
    // /////////////////////////////////////////////////////////////////////////
    wire [3:0] timer_hundredths_of_sec, timer_tenths_of_sec,
               timer_units_of_sec, timer_tens_of_sec,
               timer_units_of_min, timer_tens_of_min;

    timer timer_inst (
        .clk(CLOCK_50), .reset(~SW[0]), .start_pause(~KEY[0]),

        .hundredths_of_sec(timer_hundredths_of_sec),
        .tenths_of_sec(timer_tenths_of_sec), 
        .units_of_sec(timer_units_of_sec), 
        .tens_of_sec(timer_tens_of_sec),
        .units_of_min(timer_units_of_min), 
        .tens_of_min(timer_tens_of_min)
    );

    // /////////////////////////////////////////////////////////////////////////
    // display
    // /////////////////////////////////////////////////////////////////////////
    display_7_seg display_inst0 (
        .SW(SW[0] ? timer_hundredths_of_sec : stopwatch_hundredths_of_sec),
        .HEX0(HEX0)
    );
    display_7_seg display_inst1 (
        .SW(SW[0] ? timer_tenths_of_sec : stopwatch_tenths_of_sec),
        .HEX0(HEX1)
    );
    display_7_seg display_inst2 (
        .SW(SW[0] ? timer_units_of_sec : stopwatch_units_of_sec),
        .HEX0(HEX2)
    );
    display_7_seg display_inst3 (
        .SW(SW[0] ? timer_tens_of_sec : stopwatch_tens_of_sec),
        .HEX0(HEX3)
    );
    display_7_seg display_inst4 (
        .SW(SW[0] ? timer_units_of_min : stopwatch_units_of_min),
        .HEX0(HEX4)
    );
    display_7_seg display_inst5 (
        .SW(SW[0] ? timer_tens_of_min : stopwatch_tens_of_min),
        .HEX0(HEX5)
    );
endmodule
