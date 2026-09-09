module display_7_seg
(
    input  wire [3:0] SW,
    //output wire [6:0] HEX0
    output reg [6:0] HEX0
);

	always @ * begin
		// default case all off
		HEX0 = 7'b1111111;
		// case for all SW inputs
		case (SW)
			4'h0: HEX0 = 7'h40; // 0 
			4'h1: HEX0 = 7'h79; // 1 
			4'h2: HEX0 = 7'h24; // 2 
			4'h3: HEX0 = 7'h30; // 3 
			4'h4: HEX0 = 7'h19; // 4 
			4'h5: HEX0 = 7'h12; // 5 
			4'h6: HEX0 = 7'h02; // 6 
			4'h7: HEX0 = 7'h38; // 7 
			4'h8: HEX0 = 7'h00; // 8 
			4'h9: HEX0 = 7'h10; // 9 
			4'hA: HEX0 = 7'h08; // A 
			4'hB: HEX0 = 7'h03; // B 
			4'hC: HEX0 = 7'h46; // C 
			4'hD: HEX0 = 7'h21; // D 
			4'hE: HEX0 = 7'h06; // E 
			4'hF: HEX0 = 7'h0E; // F
		endcase
	end

	// assign HEX0[0] =	(~SW[3] & ~SW[2] & ~SW[1] & SW[0]) |
	// 				(~SW[3] & SW[2] & ~SW[1] & ~SW[0]) |
	// 				(SW[3] & ~SW[2] & SW[1] & SW[0]) |
	// 				(SW[3] & SW[2] & ~SW[1] & SW[0]);
	// assign HEX0[1] =	(~SW[3] & SW[2] & ~SW[1] & SW[0]) |
	// 				(SW[3] & SW[2] & ~SW[0]) | (SW[3] & SW[1] & SW[0]) |
	// 				(SW[2] & SW[1] & ~SW[0]);
	// assign HEX0[2] =	(~SW[3] & ~SW[2] & SW[1] & ~SW[0]) |
	// 				(SW[3] & SW[2] & SW[1]) |
	// 				(SW[3] & SW[2] & ~SW[0]);
	// assign HEX0[3] = (~SW[3] & ~SW[2] & ~SW[1] & SW[0]) |
	// 				(~SW[3] & SW[2] & ~SW[1] & ~SW[0]) |
	// 				(SW[3] & ~SW[2] & SW[1] & ~SW[0]) |
	// 				(SW[2] & SW[1] & SW[0]);
	// assign HEX0[4] = (~SW[3] & SW[2] & ~SW[1]) |
	// 				(~SW[3] & SW[0]) |
	// 				(~SW[2] & ~SW[1] & SW[0]);
	// assign HEX0[5] = (~SW[3] & ~SW[2] & SW[1]) |
	// 				(~SW[3] & ~SW[2] & SW[0]) |
	// 				(~SW[3] & SW[1] & SW[0]) |
	// 				(SW[3] & SW[2] & ~SW[1] & SW[0]);
	// assign HEX0[6] = (~SW[3] & ~SW[2] & ~SW[1]) |
	// 				(SW[3] & SW[2] & ~SW[1] & ~SW[0]);

endmodule