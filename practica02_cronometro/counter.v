module counter #(
    parameter SIZE = 19,
    parameter MAX_CUT = 500000
)(
    input wire clk,
    input wire reset_n,
    input wire enable,
    
    output reg[SIZE-1:0] cnt,
    output reg max_hit
);
    // counter logic
    reg [SIZE-1:0]cnt_comb;
    reg max_hit_comb;

    always @(*) begin
        // reset values
        cnt_comb = 0;
        max_hit_comb = 1'b0;

        if (reset_n) begin
            // hold values
            cnt_comb = cnt;
            max_hit_comb = max_hit;

            if (enable) begin
                // No max hit, add 1
                cnt_comb = cnt + 1;
                max_hit_comb = 1'b0;

                // Max hit, reset counter
                if (cnt == MAX_CUT) begin
                    cnt_comb = 0;
                    max_hit_comb = 1'b1;
                end
            end
        end
    end

    // register outputs
    always @(posedge clk) begin
        cnt <= cnt_comb;
        max_hit <= max_hit_comb;
    end
endmodule