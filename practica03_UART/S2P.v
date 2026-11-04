module serial_to_parallel #(parameter width = 9)
(
    input clk,
    input rst,
    input enable,
    input d,

    output reg [width-1:0] Q
);

always @(posedge clk) begin
		if (rst) begin
			Q <= {width{1'b0}};
        end else if (enable) begin
            Q <= {d,Q[width-1:1]};
        end
	end
endmodule