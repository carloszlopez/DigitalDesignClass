module counter #(
    parameter SIZE = 19,
    parameter MAX_CUT = 499999,
    parameter COUNT_DOWN = 1'b0
)(
    input wire clk,
    input wire reset,
    input wire enable,
    
    output reg[SIZE-1:0] cnt,
    output wire max_hit
);
    // /////////////////////////////////////////////////////////////////////////
    // counter
    // /////////////////////////////////////////////////////////////////////////
    // decrement if COUNT_DOWN else increment
    wire [SIZE-1:0] nxt_cmb = COUNT_DOWN ? cnt - 1'b1 : cnt + 1'b1;
    // reset to MAX_CUT if COUNT_DOWN else to 0
    wire [SIZE-1:0] wrap_value = COUNT_DOWN ? MAX_CUT : {SIZE{1'b0}};

    // /////////////////////////////////////////////////////////////////////////
    // max hit or zero hit if COUNT_DOWN
    // /////////////////////////////////////////////////////////////////////////
    assign max_hit = enable && (COUNT_DOWN ? (cnt == 0) : (cnt == MAX_CUT));

    // /////////////////////////////////////////////////////////////////////////
    // register counter value
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset || max_hit) begin
            cnt <= wrap_value;
        end else if (enable) begin
            cnt <= nxt_cmb;
        end
    end
endmodule