module counter #(
    parameter SIZE = 5'd19,
    parameter [SIZE-1:0] MAX_CUT = 19'd499999,
    parameter COUNT_DOWN = 1'b0
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire load,
    input wire [SIZE-1:0] cnt_in,
    
    output reg[SIZE-1:0] cnt,
    output wire max_hit
);


    // /////////////////////////////////////////////////////////////////////////
    // cnt_in if load else use cnt
    // /////////////////////////////////////////////////////////////////////////
    wire [SIZE-1:0] counter = load ? cnt_in : cnt;

    // /////////////////////////////////////////////////////////////////////////
    // counter
    // /////////////////////////////////////////////////////////////////////////
    // decrement if COUNT_DOWN else increment
    wire [SIZE-1:0] nxt_cnt = COUNT_DOWN ? counter - 1'b1 : counter + 1'b1;
    // reset to MAX_CUT if COUNT_DOWN else to 0
    wire [SIZE-1:0] wrap_value = COUNT_DOWN ? MAX_CUT : {SIZE{1'b0}};

    // /////////////////////////////////////////////////////////////////////////
    // zero hit if COUNT_DOWN else max hit
    // /////////////////////////////////////////////////////////////////////////
    assign max_hit = !reset && enable && 
                     (COUNT_DOWN ? (counter == 0) : (counter == MAX_CUT));

    // /////////////////////////////////////////////////////////////////////////
    // register counter value
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            cnt <= wrap_value;
        end else if (enable) begin
            cnt <= max_hit ? wrap_value : nxt_cnt;
        end else if (load) begin
            cnt <= cnt_in;
        end
    end
endmodule