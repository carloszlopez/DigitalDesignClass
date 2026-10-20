module debouncer (
    input Button_in,
    input Clock,
    input Reset_n,
    output Button_out
);
	// Flip flop 1
	wire q1;
	ff_d_e ff1 (
		.clk(Clock), 
		.rst(~Reset_n), // ff_d_e reset is active high
		.d(Button_in),
		.enable(1'b1), // always enabled
		.nq(), //unconected
		.q(q1));

	// Flip flop 2
	wire q2;
	ff_d_e ff2 (
		.clk(Clock), 
		.rst(~Reset_n), // ff_d_e reset is active high
		.d(q1),
		.enable(1'b1), // always enabled
		.nq(), //unconected
		.q(q2));

	// Counter N
	wire [3:0] q_counter;
	wire overflow;
	Counter_02Limit_ovf #(.N(4), .Limit(8)) ovf (
    .rst(q1 ^ q2), // Reset when FF1 ^ FF2
    .enable(~q_counter[3]), // Enable when BN = 0
    .clk(Clock),
    .Q(q_counter),
    .overflow(overflow));

	// Flip flop 3
	ff_d_e ff3 (
		.clk(Clock),
		.rst(~Reset_n), // ff_d_e reset is active high
		.d(q2),
		.enable(overflow), // always enabled
		.nq(), //unconected
		.q(Button_out));
endmodule