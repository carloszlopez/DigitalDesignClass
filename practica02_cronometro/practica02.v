`define SYSTEM_MODE_RESET     (2'd0)
`define SYSTEM_MODE_INIT      (2'd1)
`define SYSTEM_MODE_STOPWATCH (2'd2)
`define SYSTEM_MODE_TIMER     (2'd3)

module practica02 (
    input wire [3:0] KEY,
    input wire [9:0] SW,
    input wire CLOCK_50,

    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // /////////////////////////////////////////////////////////////////////////
    // system mode determination
    // /////////////////////////////////////////////////////////////////////////
    reg [1:0] system_mode = `SYSTEM_MODE_RESET;

    // start pause key
    reg  start_pause_prev = 1'b0;
    wire start_pause = ~KEY[0];
    wire start_pause_pressed = start_pause && !start_pause_prev;

    // switches
    wire reset = ~SW[9];
    wire function_selector = SW[0];
    wire [6:0] hex0, hex1, hex2, hex3, hex4, hex5;

    // left up navigation key
    reg  left_up_prev = 1'b0;
    wire left_up = ~KEY[3];
    wire left_up_pressed = left_up && !left_up_prev;

    // right down navigation key
    reg  right_down_prev = 1'b0;
    wire right_down = ~KEY[2];
    wire right_down_pressed = right_down && !right_down_prev;

    // selected digit after left/right navigation 
    reg [2:0] selected_digit = 1'd0;

    // max value of digit selected (tens of minute and second max is 5)
    wire [3:0] selected_max = 
        (selected_digit == 3 || selected_digit == 5) ? 4'd5 : 4'd9;

    // edit digit key
    reg  edit_prev = 1'b0;
    wire edit = ~KEY[1];
    wire edit_pressed = edit && !edit_prev;
    reg editing = 1'd0;
    wire load = !reset && (system_mode == `SYSTEM_MODE_INIT) && 
                start_pause_pressed;

    // MM:SS.cc digits
    reg [3:0] digit [0:5];

    //
    reg [3:0] hundredths_of_sec, tenths_of_sec, units_of_sec, tens_of_sec, 
            units_of_min, tens_of_min;

    reg running;

    always @(posedge CLOCK_50) begin
        if (reset) begin
        system_mode <= `SYSTEM_MODE_RESET;
        
        end else begin
            // use digit as display_7_seg inputs
            hundredths_of_sec = digit[0];
            tenths_of_sec     = digit[1]; 
            units_of_sec      = digit[2]; 
            tens_of_sec       = digit[3];
            units_of_min      = digit[4]; 
            tens_of_min       = digit[5];

            // hold key values
            start_pause_prev <= start_pause;
            edit_prev        <= edit;
            left_up_prev     <= left_up;
            right_down_prev  <= right_down;

            running <= start_pause_pressed ? ~running : running;

            case (system_mode)
                `SYSTEM_MODE_RESET: begin
                    // navigation reset
                    selected_digit = 3'd0;
                    editing        = 1'b0;
                    digit[0]       = 4'd0;
                    digit[1]       = 4'd0;
                    digit[2]       = 4'd0;
                    digit[3]       = 4'd0;
                    digit[4]       = 4'd0;
                    digit[5]       = 4'd0;

                    running <= 1'b0;

                    // next mode
                    system_mode <= `SYSTEM_MODE_INIT;
                end

                `SYSTEM_MODE_INIT: begin
                    if (start_pause_pressed) begin
                        // stop digit edition and 
                        editing <= 1'b0;
                        // next mode
                        system_mode <= function_selector ? 
                         `SYSTEM_MODE_STOPWATCH : `SYSTEM_MODE_TIMER;
                    
                    end else if (edit_pressed) begin
                        // toggle up/down digit edition
                        editing <= ~editing;

                    end else if (!editing) begin
                        // left/right digit navigation
                        if (left_up_pressed) begin
                            selected_digit <= (selected_digit == 5) ? 
                                            3'd0 : selected_digit + 3'd1;
                        end else if (right_down_pressed) begin
                            selected_digit <= (selected_digit == 0) ? 
                                            3'd5 : selected_digit - 3'd1;
                        end

                    end else begin
                        // up/down digit navigation
                        if (left_up_pressed) begin
                            digit[selected_digit] <= 
                                (digit[selected_digit] == selected_max) ? 
                                4'd0 : digit[selected_digit] + 4'd1;
                        end else if (right_down_pressed) begin
                            digit[selected_digit] <= 
                                (digit[selected_digit] == 0) ? 
                                selected_max : digit[selected_digit] - 4'd1;
                        end
                    end
                end

                `SYSTEM_MODE_STOPWATCH: begin
                    // use stopwatch outputs as display_7_seg inputs 
                    hundredths_of_sec = stopwatch_hundredths_of_sec;
                    tenths_of_sec     = stopwatch_tenths_of_sec; 
                    units_of_sec      = stopwatch_units_of_sec; 
                    tens_of_sec       = stopwatch_tens_of_sec;
                    units_of_min      = stopwatch_units_of_min; 
                    tens_of_min       = stopwatch_tens_of_min;    

                    // Stay in this mode until reset
                end
                
                `SYSTEM_MODE_TIMER: begin
                    // use timer outputs as display_7_seg inputs 
                    hundredths_of_sec = timer_hundredths_of_sec;
                    tenths_of_sec     = timer_tenths_of_sec; 
                    units_of_sec      = timer_units_of_sec; 
                    tens_of_sec       = timer_tens_of_sec;
                    units_of_min      = timer_units_of_min; 
                    tens_of_min       = timer_tens_of_min;    

                    // Stay in this mode until reset
                end

                default: begin
                    // Unkown mode, go to reset
                    system_mode <= `SYSTEM_MODE_RESET;
                end
            endcase
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // stopwatch and timer instances
    // /////////////////////////////////////////////////////////////////////////
    wire [3:0] stopwatch_hundredths_of_sec, stopwatch_tenths_of_sec,
               stopwatch_units_of_sec, stopwatch_tens_of_sec, 
               stopwatch_units_of_min, stopwatch_tens_of_min;
    
    stopwatch stopwatch_inst (
        // inputs
        .clk(CLOCK_50), .reset(system_mode == `SYSTEM_MODE_RESET), 
        .enable(running && (system_mode == `SYSTEM_MODE_STOPWATCH)), 
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
        .enable(running && (system_mode == `SYSTEM_MODE_TIMER)), 
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
    // display instances
    // /////////////////////////////////////////////////////////////////////////
    display_7_seg display_inst0 (
        // inputs
        .SW(hundredths_of_sec), 
        .reset(reset),
        
        // outputs
        .HEX0(HEX0));

    display_7_seg display_inst1 (
        // inputs
        .SW(tenths_of_sec), 
        .reset(reset),
        
        // outputs
        .HEX0(HEX1));

    display_7_seg display_inst2 (
        // inputs
        .SW(units_of_sec), 
        .reset(reset),
        
        // outputs
        .HEX0(HEX2));

    display_7_seg display_inst3 (
        // inputs
        .SW(tens_of_sec), 
        .reset(reset),
        
        // outputs
        .HEX0(HEX3));

    display_7_seg display_inst4 (
        // inputs
        .SW(units_of_min), 
        .reset(reset),
        
        // outputs
        .HEX0(HEX4));

    display_7_seg display_inst5 (
        // inputs
        .SW(tens_of_min), 
        .reset(reset),
        
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
        .reset(reset),
        .enable(running && ((system_mode == `SYSTEM_MODE_TIMER) ||
                (system_mode == `SYSTEM_MODE_STOPWATCH))),

        // outputs
        .load(load),
        .cnt_in(19'd0),
        .cnt(), //unconnected
        .max_hit(tick_10ms)
    );
endmodule
