module keys_monitor (
    input clk,
    input reset,
    input enable,
    input [3:0] keys,

    output reg start_pause,
    output reg edit,
    output reg right_down,
    output reg left_up
);

    // /////////////////////////////////////////////////////////////////////////
    // monitor keys: 1 means pressed
    // /////////////////////////////////////////////////////////////////////////
    reg [3:0] keys_prev;
    wire [3:0] next_key = keys & ~keys_prev;
    
    always @(posedge clk) begin
        if (reset) begin
            keys_prev <= 4'b0000;
        end else if (enable) begin
            keys_prev <= keys;
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // register outputs
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            start_pause <= 1'b0;
            edit <= 1'b0;
            right_down <= 1'b0;
            left_up <= 1'b0;
        end else if (enable) begin
            start_pause <= next_key[0];
            edit <= next_key[1];
            right_down <= next_key[2];
            left_up <= next_key[3];
        end
    end

endmodule