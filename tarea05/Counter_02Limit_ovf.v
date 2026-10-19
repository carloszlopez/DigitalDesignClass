`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
//////////////////////////////////////////////////////////////////////////
module Counter_02Limit_ovf # (N=4, Limit = 9)(
    input rst,
    input enable,
    input clk,
    output reg [N-1:0] Q,
    output overflow );
assign overflow = (Q==Limit)? 1'b1 : 1'b0;
 always @(posedge rst, posedge clk)
  begin
    if(rst)
        Q <= {N{1'b0}};
    else
        if (enable)
            if (Q==Limit)
                Q <= {N{1'b0}};
            else
                Q <= Q + 1'b1;
        else
            Q <= Q;
  end 
endmodule
