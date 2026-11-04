module parallel_to_serial #(parameter width = 9)
(
    input clk,
    input rst,
    input enable,
    input [width-1:0] d,

    output serialQ
);

always @(posedge clk) begin
		if (rst) begin
			serialQ <= 1'b0;
        end else if (enable) begin
            serialQ <= d[0];
        end
	end
endmodule