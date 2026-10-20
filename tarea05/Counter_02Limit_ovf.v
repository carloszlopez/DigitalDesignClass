`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
//////////////////////////////////////////////////////////////////////////
module Counter_02Limit_ovf # (parameter N=bits_needed(Limit), parameter Limit = 9)(
    input rst,
    input enable,
    input clk,
    output reg [N-1:0] Q,
    output overflow );
assign overflow = (Q==Limit)? 1'b1 : 1'b0;

function integer bits_needed;
    input integer value;
    integer temp;
    begin
        temp = value;
        bits_needed = 0;

        while (temp > 0) begin
            bits_needed = bits_needed + 1;
            temp = temp / 2;
        end

        if (bits_needed == 0)
            bits_needed = 1;
    end
endfunction

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
