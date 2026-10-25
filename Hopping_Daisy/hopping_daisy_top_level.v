module hopping_daisy_top_level (
    input  wire       CLOCK_50,
    input  wire [3:0] KEY,
    input  wire [9:0] SW,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_CLK,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_SYNC_N,
    output wire       VGA_BLANK_N
);

    hopping_daisy hopping_daisy (
           .clk(CLOCK_50),
           .reset(~KEY[0]),
           .enable(1'b1), // always enabled
           .start_key(KEY[1]),
           .jump_key(KEY[3]),
           .ce_out(), // not connected
           .VGA_R(VGA_R),
           .VGA_G(VGA_G),
           .VGA_B(VGA_B),
           .VGA_CLK(VGA_CLK),
           .VGA_HS(VGA_HS),
           .VGA_VS(VGA_VS),
           .VGA_SYNC_N(VGA_SYNC_N),
           .VGA_BLANK_N(VGA_BLANK_N)
    );
    
endmodule