module counter #(
    parameter SIZE = 19,
    parameter MAX_CUT = 499999
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
        if (!reset_n) begin
            cnt_comb = {SIZE{1'b0}};
            max_hit_comb = 1'b0;
        end else if (enable) begin
            max_hit_comb = (cnt == MAX_CUT);
            cnt_comb = max_hit_comb ? {SIZE{1'b0}} : cnt + 1'b1;
        end else begin
            max_hit_comb = 0;
            cnt_comb = cnt;
        end
    end

    // register outputs
    always @(posedge clk) begin
        cnt <= cnt_comb;
        max_hit <= max_hit_comb;
    end
endmodule