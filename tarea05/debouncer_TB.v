// ITESO
// Carlos Zepeda
// Testbench for a debouncer

`timescale 1ns / 1ps
module debouncer_TB ();

reg Button_in;
reg Clock;
reg Reset_n;
wire Button_out;

debouncer UUT (
	.Button_in(Button_in),
    .Clock(Clock),
    .Reset_n(Reset_n),
    .Button_out(Button_out));
    
initial
	begin
		Button_in = 1'b0;
		Clock = 1'b0;
		Reset_n = 1'b0;

		#20 Reset_n = 1'b1;
	end

always
	begin
	  #10 Clock = ~Clock;
	end

always
	begin
	  #300 Button_in = ~Button_in;
	end
endmodule
