`include "common_defines.vh"

module practica02 (
    input [3:0] KEY,
    input [9:0] SW,
    input CLOCK_50,

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    // /////////////////////////////////////////////////////////////////////////
    // system control
    // /////////////////////////////////////////////////////////////////////////
    wire [1:0] mode;
    wire fnc_selected, fnc_finished_latched;
    wire start_pause, edit, right_down, left_up;
    wire stopwatch_finished, timer_finished, tick_10ms;
    wire fnc_selector = SW[0];
    wire fnc_finished = fnc_selected ? timer_finished : stopwatch_finished;

    system_control system_control (
        // inputs
        .clk(CLOCK_50),
        .reset(~SW[9]),
        .enable(1'b1), // always enabled
        .start_pause(start_pause),
        .fnc_selector(fnc_selector),
        .fnc_finished(fnc_finished),

        // outputs
        .mode(mode),
        .fnc_selected(fnc_selected),
        .fnc_finished_latched(fnc_finished_latched)
    );

    // /////////////////////////////////////////////////////////////////////////
    // keys monitor
    // /////////////////////////////////////////////////////////////////////////

    keys_monitor keys_monitor (
        // inputs
        .clk(CLOCK_50),
        .reset(mode == `MODE_RESET),
        .enable(mode != `MODE_RESET),
        .keys(~KEY),

        // outputs
        .start_pause(start_pause),
        .edit(edit),
        .right_down(right_down),
        .left_up(left_up)
    );

    // /////////////////////////////////////////////////////////////////////////
    // navigation
    // /////////////////////////////////////////////////////////////////////////
    wire [2:0] selected_digit;
    wire [23:0] init_digits;

    navigation navigation (
        // inputs
        .clk(CLOCK_50), 
        .reset(mode != `MODE_INIT),
        .enable(mode == `MODE_INIT),
        .edit(edit),
        .right_down(right_down), 
        .left_up(left_up),

        // outputs
        .init_digits(init_digits),
        .selected_digit(selected_digit)
    );

    // /////////////////////////////////////////////////////////////////////////
    // stopwatch and timer instances
    // /////////////////////////////////////////////////////////////////////////
    // 10ms counter
    counter #(.SIZE(5'd19), .MAX_CUT(19'd499999),
              .COUNT_DOWN(1'b0)) counter_inst0 (
        // inputs
        .clk(CLOCK_50),
        .reset((mode == `MODE_RESET)),
        .enable((mode == `MODE_STARTED)),
        .load((mode == `MODE_INIT) && start_pause),
        .cnt_in(19'd0),

        // outputs
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );

    // stopwatch function
    wire [3:0] stopwatch_hundredths_of_sec, stopwatch_tenths_of_sec,
               stopwatch_units_of_sec, stopwatch_tens_of_sec,
               stopwatch_units_of_min, stopwatch_tens_of_min;

    stopwatch stopwatch_inst (
        // inputs
        .clk(CLOCK_50),
        .reset(mode == `MODE_RESET),
        .enable(!fnc_selected && mode == `MODE_STARTED),
        .tick_10ms(tick_10ms),
        .load((mode == `MODE_INIT) && start_pause),
        .hundredths_of_sec_in(init_digits[3:0]),
        .tenths_of_sec_in(init_digits[7:4]),
        .units_of_sec_in(init_digits[11:8]),
        .tens_of_sec_in(init_digits[15:12]),
        .units_of_min_in(init_digits[19:16]),
        .tens_of_min_in(init_digits[23:20]),

        // outputs
        .hundredths_of_sec(stopwatch_hundredths_of_sec),
        .tenths_of_sec(stopwatch_tenths_of_sec),
        .units_of_sec(stopwatch_units_of_sec),
        .tens_of_sec(stopwatch_tens_of_sec),
        .units_of_min(stopwatch_units_of_min),
        .tens_of_min(stopwatch_tens_of_min),
        .finished(stopwatch_finished)
    );

    // timer function
    wire [3:0] timer_hundredths_of_sec, timer_tenths_of_sec,
               timer_units_of_sec, timer_tens_of_sec,
               timer_units_of_min, timer_tens_of_min;

    timer timer_inst (
        // inputs
        .clk(CLOCK_50),
        .reset(mode == `MODE_RESET),
        .enable(fnc_selected && mode == `MODE_STARTED),
        .tick_10ms(tick_10ms),
        .load((mode == `MODE_INIT) && start_pause),
        .hundredths_of_sec_in(init_digits[3:0]),
        .tenths_of_sec_in(init_digits[7:4]),
        .units_of_sec_in(init_digits[11:8]),
        .tens_of_sec_in(init_digits[15:12]),
        .units_of_min_in(init_digits[19:16]),
        .tens_of_min_in(init_digits[23:20]),

        // outputs
        .hundredths_of_sec(timer_hundredths_of_sec),
        .tenths_of_sec(timer_tenths_of_sec),
        .units_of_sec(timer_units_of_sec),
        .tens_of_sec(timer_tens_of_sec),
        .units_of_min(timer_units_of_min),
        .tens_of_min(timer_tens_of_min),
        .finished(timer_finished)
    );

    // ////////////////////////////////////////////////////////////////////////
    // display control
    // ////////////////////////////////////////////////////////////////////////
    // Route digits
    reg [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec,
        units_of_min, tens_of_min;

    always @(*) begin
        case (mode)         
            `MODE_STARTED, `MODE_PAUSED: 
                // use timer digits
                if (fnc_selected) begin
                    hundredths_of_sec = timer_hundredths_of_sec;
                    tenths_of_sec     = timer_tenths_of_sec;
                    units_of_sec      = timer_units_of_sec;
                    tens_of_sec       = timer_tens_of_sec;
                    units_of_min      = timer_units_of_min;
                    tens_of_min       = timer_tens_of_min;
                    
                // use stopwatch digits
                end else begin
                    hundredths_of_sec = stopwatch_hundredths_of_sec;
                    tenths_of_sec     = stopwatch_tenths_of_sec;
                    units_of_sec      = stopwatch_units_of_sec;
                    tens_of_sec       = stopwatch_tens_of_sec;
                    units_of_min      = stopwatch_units_of_min;
                    tens_of_min       = stopwatch_tens_of_min;
                end

            // Use initial digits
            default: begin
                hundredths_of_sec = init_digits[3:0];
                tenths_of_sec     = init_digits[7:4];
                units_of_sec      = init_digits[11:8];
                tens_of_sec       = init_digits[15:12];
                units_of_min      = init_digits[19:16];
                tens_of_min       = init_digits[23:20];
            end
        endcase
    end

    wire [41:0] hex;
    assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;
    display_control #(.DIGIT_NUM(6)) display_control (
        // inputs
        .clk(CLOCK_50),
        .reset((mode == `MODE_RESET)),
        .enable((mode != `MODE_RESET)),
        .load((mode == `MODE_INIT) && start_pause),
        .blink_control((mode == `MODE_INIT) ? 
                        (6'b000001 << selected_digit) : {6{fnc_finished_latched}}),
        .digits({tens_of_min, units_of_min, tens_of_sec, units_of_sec, 
                 tenths_of_sec, hundredths_of_sec}),

        // outputs
        .hex(hex)
    );
endmodule
