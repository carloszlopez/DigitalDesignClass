module main (
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

    wire [7:0] red_game;
    wire [7:0] green_game;
    wire [7:0] blue_game;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire       frame_tick;
    wire [9:0] daisy_y;
    wire       playing;
    wire [9:0] obstacle_x;
    wire [4:0] ground_offset;
    wire [15:0]score_bcd;

    // SW[1:0]: 00 = black, 01 = red, 10 = green, 11 = blue.
    // assign red_game   = (SW[1:0] == 2'b01) ? 8'hFF : 8'h00;
    // assign green_game = (SW[1:0] == 2'b10) ? 8'hFF : 8'h00;
    // assign blue_game  = (SW[1:0] == 2'b11) ? 8'hFF : 8'h00;

    // VGA driver instance.
    vga_drvr vga_drvr_inst (
        .clk_in   (CLOCK_50),
        .reset_n  (KEY[0]),
        .red_in   (red_game),
        .green_in (green_game),
        .blue_in  (blue_game),

        .red     (VGA_R),
        .green   (VGA_G),
        .blue    (VGA_B),
        .clk     (VGA_CLK),
        .hsync   (VGA_HS),
        .vsync   (VGA_VS),
        .sync_n  (VGA_SYNC_N),
        .blank_n (VGA_BLANK_N),
        .pixel_x (pixel_x),
        .pixel_y (pixel_y),
        .frame_tick(frame_tick)
    );

    // Render instance
    render render_inst (
        .pixel_x       (pixel_x),
        .pixel_y       (pixel_y),
        .daisy_y       (daisy_y),
        .obstacle_x    (obstacle_x),
        .ground_offset (ground_offset),
        .score_bcd     (score_bcd),
        .red           (red_game),
        .green         (green_game),
        .blue          (blue_game)
    );

    // Game instance
    game game_inst (
        .clk_in        (CLOCK_50),
        .reset_n       (KEY[0]),
        .start_n       (KEY[1]),
        .jump_n        (KEY[3]),
        .frame_tick    (frame_tick),
        .game_over    (game_over),
        .playing       (playing),
        .daisy_y       (daisy_y),
        .obstacle_x    (obstacle_x),
        .ground_offset (ground_offset),
        .score_bcd     (score_bcd)
    );
endmodule