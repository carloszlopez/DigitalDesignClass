`include "common_defines.vh"

module system_control (
    input clk,
    input reset,
    input enable,
    input start_pause,
    input fnc_selector,
    input fnc_finished,

    output reg [1:0] mode,
    output reg fnc_selected,
    output reg fnc_finished_latched
);
    // /////////////////////////////////////////////////////////////////////////
    // mode FSM
    // /////////////////////////////////////////////////////////////////////////
    reg [1:0] next_mode;

    always @(*) begin
        // No transition
        next_mode = mode;

        case (mode)
            // transition to init
            `MODE_RESET: next_mode = `MODE_INIT;

            `MODE_INIT: begin
                // transition to started
                if (start_pause) next_mode = `MODE_STARTED;
            end

            `MODE_STARTED: begin
                // transition to reset
                if (fnc_selected != fnc_selector) next_mode = `MODE_RESET;
                
                // transition to pause
                else if (start_pause | fnc_finished) next_mode = `MODE_PAUSED;
            end

            `MODE_PAUSED: begin
                // transition to reset
                if (fnc_selected != fnc_selector) next_mode = `MODE_RESET;
                
                // transition to started
                else if (start_pause) next_mode = `MODE_STARTED;
            end

            // Unkown mode
            default: next_mode = `MODE_RESET;
        endcase
    end

    // /////////////////////////////////////////////////////////////////////////
    // register outputs
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            mode <= `MODE_RESET;
            fnc_selected <= 1'b0;
            fnc_finished_latched <= 1'b0;

        end else if (enable) begin
            mode <= next_mode;

            case (mode)
                `MODE_INIT: begin
                    // store function selected 
                    if (start_pause) fnc_selected <= fnc_selector;
                end

                // store function finsihed flag 
                `MODE_STARTED: fnc_finished_latched <= fnc_finished;

                `MODE_PAUSED: begin
                    // hold function selected and function finished flag 
                end

                // clear function selected and function finished flag
                default: begin
                    fnc_selected <= 1'b0;
                    fnc_finished_latched <= 1'b0;
                end
            endcase
        end
    end

endmodule
