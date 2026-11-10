module key_monitor (
    input clk,
    input reset,
    input enable,
    input key_n, // active in low

    output reg key_pressed
);

    // /////////////////////////////////////////////////////////////////////////
    // Detect neg edge in key_n
    // /////////////////////////////////////////////////////////////////////////
    reg key_n_prev;
    wire next_key_pressed = ~key_n & key_n_prev;
    
    always @(posedge clk) begin
        if (reset) begin
            key_n_prev <= 1'b1;
        end else if (enable) begin
            key_n_prev <= key_n;
        end
    end

    // /////////////////////////////////////////////////////////////////////////
    // register outputs
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            key_pressed <= 1'b0;
        end else if (enable) begin
            key_pressed <= next_key_pressed;
        end
    end

endmodule