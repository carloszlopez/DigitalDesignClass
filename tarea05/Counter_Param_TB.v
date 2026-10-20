// ITESO
// Carlos Zepeda
// Testbench for a Parametric Counter
// with high-active synchronous reset.

`timescale 1ns / 1ps
module Counter_Param_TB ( );

localparam width = 4;
reg clk, rst, enable;
wire [width-1:0] Q;

Counter_Param # (.n (width) )
   UUT (.clk(clk), .rst(rst), .enable(enable), .Q(Q) );
    
initial
	begin
		clk 	= 1'b0;
		rst 	= 1'b1;
		enable	= 1'b0;
		
		// 30ns start count
		#30 enable = 1'b1;
		rst = 1'b0;
		
		// 75ns fail reset
		#45	rst = 1'b1;
		#10	rst = 1'b0;

		// 90ns reset
		#5	rst = 1'b1;
		#10	rst = 1'b0;
	end

always
	begin
	  #10 clk = ~clk;
	end
endmodule
