// KEY DEFINES
`define KEY_START_PAUSE (4'd0)
`define KEY_EDIT        (4'd1)
`define KEY_RIGHT_DOWN  (4'd2)
`define KEY_LEFT_UP     (4'd3)
`define KEY_MAX         (4'd4)

//SWITCH DEFINES
`define SW_RESET    (4'd9)
`define SW_SELECTOR (4'd0)

// digits
`define DIGIT_MAX_NUM (4'd6)

//SYSTEM MODES DEFINES
`define SYSTEM_MODE_RESET     (2'd0)
`define SYSTEM_MODE_INIT      (2'd1)
`define SYSTEM_MODE_STARTED   (2'd2)
`define SYSTEM_MODE_PAUSED    (2'd3)

module practica02 (
    input wire [3:0] KEY,
    input wire [9:0] SW,
    input wire CLOCK_50,

    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    // /////////////////////////////////////////////////////////////////////////
    // keys
    // /////////////////////////////////////////////////////////////////////////
    reg [`KEY_MAX-1:0] key_prev;
    wire [`KEY_MAX-1:0] key_pressed;
    assign key_pressed = (~KEY) & ~key_prev;

    always @(posedge CLOCK_50) begin
        if (SW[`SW_RESET]) begin
            key_prev    <= {`KEY_MAX{1'b0}};
        end else begin
            key_prev    <= ~KEY;
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // system mode transitions
    // /////////////////////////////////////////////////////////////////////////
    reg [1:0] system_mode;
    reg fnc_selected;

    always @(posedge CLOCK_50) begin
        if (SW[`SW_RESET]) begin
            system_mode <= `SYSTEM_MODE_RESET;
            fnc_selected <= 0;

        end else begin
            case (system_mode)
                `SYSTEM_MODE_RESET: begin
                    fnc_selected <= 0;
                    // default transition
                    system_mode <= `SYSTEM_MODE_INIT;
                end
                
                `SYSTEM_MODE_INIT: begin
                    // start detected
                    if (key_pressed[`KEY_START_PAUSE]) begin
                        system_mode <= `SYSTEM_MODE_STARTED;
                        fnc_selected <= SW[`SW_SELECTOR];
                    end
                end

                `SYSTEM_MODE_STARTED: begin
                    // selected function changed
                    if (fnc_selected != SW[`SW_SELECTOR]) begin
                        system_mode <= `SYSTEM_MODE_RESET;
                    
                    // pause detected
                    end else if (key_pressed[`KEY_START_PAUSE]) begin
                        system_mode <= `SYSTEM_MODE_PAUSED;
                    end
                end
                
                `SYSTEM_MODE_PAUSED: begin
                    // selected function changed
                    if (fnc_selected != SW[`SW_SELECTOR]) begin
                        system_mode <= `SYSTEM_MODE_RESET;
                    // start detected
                    end else if (key_pressed[`KEY_START_PAUSE]) begin
                        system_mode <= `SYSTEM_MODE_STARTED;
                    end
                end

                default: begin
                    // unkown mode
                    system_mode <= `SYSTEM_MODE_RESET;
                end

            endcase
        end
    end

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
        case (system_mode)
            `SYSTEM_MODE_RESET: begin
                editing        <= 1'b0;
                selected_digit <= 3'd0;
                digit[0]       <= 4'd0;
                digit[1]       <= 4'd0;
                digit[2]       <= 4'd0;
                digit[3]       <= 4'd0;
                digit[4]       <= 4'd0;
                digit[5]       <= 4'd0;
            end

            `SYSTEM_MODE_INIT: begin
                if (key_pressed[`KEY_EDIT]) begin
                    editing <= ~editing;
                end

                // left/right digit navigation
                if (!editing) begin
                    if (key_pressed[`KEY_LEFT_UP]) begin
                        selected_digit <= (selected_digit == 5) ? 
                                        3'd0 : selected_digit + 3'd1;
                    end else if (key_pressed[`KEY_RIGHT_DOWN]) begin
                        selected_digit <= (selected_digit == 0) ? 
                                        3'd5 : selected_digit - 3'd1;
                    end

                // up/down digit navigation
                end else begin
                    if (key_pressed[`KEY_LEFT_UP]) begin
                        digit[selected_digit] <= 
                            (digit[selected_digit] == selected_max) ? 
                            4'd0 : digit[selected_digit] + 4'd1;
                    end else if (key_pressed[`KEY_RIGHT_DOWN]) begin
                        digit[selected_digit] <= 
                            (digit[selected_digit] == 0) ? 
                            selected_max : digit[selected_digit] - 4'd1;
                    end
                end
            end
        endcase
    end


    // /////////////////////////////////////////////////////////////////////////
    // load
    // /////////////////////////////////////////////////////////////////////////
    wire load = (~SW[`SW_RESET]) && (system_mode == `SYSTEM_MODE_INIT) && 
                key_pressed[`KEY_START_PAUSE];

    

    // /////////////////////////////////////////////////////////////////////////
    // stopwatch and timer instances
    // /////////////////////////////////////////////////////////////////////////
    wire [3:0] stopwatch_hundredths_of_sec, stopwatch_tenths_of_sec,
               stopwatch_units_of_sec, stopwatch_tens_of_sec, 
               stopwatch_units_of_min, stopwatch_tens_of_min;

    stopwatch stopwatch_inst (
        // inputs
        .clk(CLOCK_50), .reset(system_mode == `SYSTEM_MODE_RESET), 
        .enable(~fnc_selected & (system_mode == `SYSTEM_MODE_STARTED)), 
        .tick_10ms(tick_10ms), .load(load), 
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
        .tens_of_min(stopwatch_tens_of_min)
    );
    
    wire [3:0] timer_hundredths_of_sec, timer_tenths_of_sec,
               timer_units_of_sec, timer_tens_of_sec,
               timer_units_of_min, timer_tens_of_min;

    timer timer_inst (
        // inputs
        .clk(CLOCK_50), .reset(system_mode == `SYSTEM_MODE_RESET), 
        .enable(fnc_selected & (system_mode == `SYSTEM_MODE_STARTED)), 
        .tick_10ms(tick_10ms), .load(load),
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
        .tens_of_min(timer_tens_of_min)
    );

    // /////////////////////////////////////////////////////////////////////////
    // display
    // /////////////////////////////////////////////////////////////////////////
    reg [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec, 
        units_of_min, tens_of_min;

    always @(*) begin
        case (system_mode)        
            // Use functions outputs for display
            `SYSTEM_MODE_STARTED,`SYSTEM_MODE_PAUSED: begin
                hundredths_of_sec = fnc_selected ? 
                        timer_hundredths_of_sec : stopwatch_hundredths_of_sec;
                tenths_of_sec     = fnc_selected ? 
                        timer_tenths_of_sec : stopwatch_tenths_of_sec;
                units_of_sec      = fnc_selected ? 
                        timer_units_of_sec : stopwatch_units_of_sec;
                tens_of_sec       = fnc_selected ? 
                        timer_tens_of_sec : stopwatch_tens_of_sec;
                units_of_min      = fnc_selected ? 
                        timer_units_of_min : stopwatch_units_of_min;
                tens_of_min       = fnc_selected ? 
                        timer_tens_of_min : stopwatch_tens_of_min;
            end

            // Use digit for display
            default: begin
                hundredths_of_sec = digit[0];
                tenths_of_sec     = digit[1];
                units_of_sec      = digit[2];
                tens_of_sec       = digit[3];
                units_of_min      = digit[4];
                tens_of_min       = digit[5];
            end
        endcase
    end

    display_7_seg display_inst0 (
        // inputs
        .SW(hundredths_of_sec), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX0));

    display_7_seg display_inst1 (
        // inputs
        .SW(tenths_of_sec), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX1));

    display_7_seg display_inst2 (
        // inputs
        .SW(units_of_sec), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX2));

    display_7_seg display_inst3 (
        // inputs
        .SW(tens_of_sec), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX3));

    display_7_seg display_inst4 (
        // inputs
        .SW(units_of_min), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX4));

    display_7_seg display_inst5 (
        // inputs
        .SW(tens_of_min), 
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        
        // outputs
        .HEX0(HEX5));


    // ////////////////////////////////////////////////////////////////////////
    // 10ms counter
    // ////////////////////////////////////////////////////////////////////////
    wire tick_10ms;
    counter #(.SIZE(5'd19), .MAX_CUT(19'd499999), 
              .COUNT_DOWN(1'b0)) counter_inst0 (
        // inputs
        .clk(CLOCK_50),
        .reset((system_mode == `SYSTEM_MODE_RESET)),
        .enable((system_mode == `SYSTEM_MODE_STARTED)),

        // outputs
        .load(load),
        .cnt_in(19'd0),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );
endmodule
