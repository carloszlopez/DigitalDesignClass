module switches_votes
(
    input  wire [2:0] SW,
    output wire [1:0] LEDR
);

	assign LEDR[0] = 	(~SW[0] & ~SW[1] & SW[2]) | 
						(~SW[0] & SW[1] & ~SW[2]) | 
						(SW[0] & ~SW[1] &~ SW[2]) | 
						(SW[0] & SW[1] & SW[2]);

	assign LEDR[1] = 	(~SW[0] & SW[1] & SW[2]) | 
						(SW[0] & ~SW[1] & SW[2]) | 
						(SW[0] & SW[1] & ~SW[2]) | 
						(SW[0] & SW[1] & SW[2]);

endmodule