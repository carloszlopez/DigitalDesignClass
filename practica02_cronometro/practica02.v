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
    // load counters
    // /////////////////////////////////////////////////////////////////////////
    reg editing;
    reg [2:0] selected_digit;
    reg [3:0] digit [0:5];

    // max value of selected digit
    wire [3:0] selected_max =
        (selected_digit == 3 || selected_digit == 5) ? 4'd5 : 4'd9;

    always @(posedge CLOCK_50) begin
        case (mode)
            `MODE_RESET: begin
                editing        <= 1'b0;
                selected_digit <= 3'd0;
                digit[0]       <= 4'd0;
                digit[1]       <= 4'd0;
                digit[2]       <= 4'd0;
                digit[3]       <= 4'd0;
                digit[4]       <= 4'd0;
                digit[5]       <= 4'd0;
            end

            `MODE_INIT: begin
                // toggle if edit key is pressed
                if (edit) begin
                    editing <= ~editing;
                end

                // left/right digit navigation
                if (!editing) begin
                    if (left_up) begin
                        selected_digit <= (selected_digit == 5) ?
                                        3'd0 : selected_digit + 3'd1;
                    end else if (right_down) begin
                        selected_digit <= (selected_digit == 0) ?
                                        3'd5 : selected_digit - 3'd1;
                    end

                // up/down digit navigation
                end else begin
                    if (left_up) begin
                        digit[selected_digit] <=
                            (digit[selected_digit] == selected_max) ?
                            4'd0 : digit[selected_digit] + 4'd1;
                    end else if (right_down) begin
                        digit[selected_digit] <=
                            (digit[selected_digit] == 0) ?
                            selected_max : digit[selected_digit] - 4'd1;
                    end
                end
            end
        endcase
    end

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

        // outputs
        .load((mode == `MODE_INIT) && start_pause),
        .cnt_in(19'd0),
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
        .hundredths_of_sec_in(digit[0]),
        .tenths_of_sec_in(digit[1]),
        .units_of_sec_in(digit[2]),
        .tens_of_sec_in(digit[3]),
        .units_of_min_in(digit[4]),
        .tens_of_min_in(digit[5]),

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
        .hundredths_of_sec_in(digit[0]),
        .tenths_of_sec_in(digit[1]),
        .units_of_sec_in(digit[2]),
        .tens_of_sec_in(digit[3]),
        .units_of_min_in(digit[4]),
        .tens_of_min_in(digit[5]),

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
        // Use initial digits
        hundredths_of_sec = digit[0];
        tenths_of_sec     = digit[1];
        units_of_sec      = digit[2];
        tens_of_sec       = digit[3];
        units_of_min      = digit[4];
        tens_of_min       = digit[5];
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
