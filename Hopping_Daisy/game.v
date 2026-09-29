module game (
    input  wire       clk_in,
    input  wire       reset_n,
    input  wire       start_n,     // KEY[1], active low
    input  wire       jump_n,      // KEY[3], active low
    input  wire       frame_tick,

    output reg        playing,
    output reg        game_over,
    output reg  [9:0] daisy_y,
    output reg  [9:0] obstacle_x,
    output reg  [4:0] ground_offset,
    output reg  [15:0] score_bcd
);

    localparam [9:0] DAISY_GROUND_Y = 10'd360;
    localparam [9:0] OBSTACLE_START = 10'd600;
    localparam [9:0] OBSTACLE_SPEED = 10'd4;
    localparam [9:0] JUMP_STEP      = 10'd6;

    reg start_meta, start_sync, start_previous;
    reg jump_meta, jump_sync, jump_previous;
    reg jump_pending;

    reg       jumping;
    reg [4:0] jump_frame;
    reg obstacle_scored;

    wire start_pressed = start_previous && !start_sync;
    wire jump_pressed  = jump_previous  && !jump_sync;

    // Daisy occupies x = 80..119 and y = daisy_y..daisy_y+39.
    // The obstacle occupies x = obstacle_x..obstacle_x+19
    // and y = 370..399. Touching edges alone is not a collision.
    wire collision =
        (10'd80 < obstacle_x + 10'd20) &&
        (10'd120 > obstacle_x) &&
        (daisy_y < 10'd400) &&
        (daisy_y + 10'd40 > 10'd370);

    wire obstacle_passed = !obstacle_scored &&
                           (obstacle_x + 10'd20 <= 10'd80);

    // Synchronize the buttons to the 50 MHz clock.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            start_meta     <= 1'b1;
            start_sync     <= 1'b1;
            start_previous <= 1'b1;
            jump_meta      <= 1'b1;
            jump_sync      <= 1'b1;
            jump_previous  <= 1'b1;
        end else begin
            start_meta     <= start_n;
            start_sync     <= start_meta;
            start_previous <= start_sync;

            jump_meta      <= jump_n;
            jump_sync      <= jump_meta;
            jump_previous  <= jump_sync;
        end
    end

    // Remember a jump press until the next frame.
    // Presses while Daisy is already jumping are ignored.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n)
            jump_pending <= 1'b0;
        else if (frame_tick || !playing)
            jump_pending <= 1'b0;
        else if (jump_pressed && !jumping)
            jump_pending <= 1'b1;
    end

    // Update the game state once per frame.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            playing       <= 1'b0;
            game_over     <= 1'b0;
            daisy_y       <= DAISY_GROUND_Y;
            obstacle_x    <= OBSTACLE_START;
            ground_offset <= 5'd0;
            jumping       <= 1'b0;
            jump_frame    <= 5'd0;
            score_bcd       <= 16'h0000;
            obstacle_scored <= 1'b0;
        end else if (start_pressed && !playing) begin
            // Start a new game, including after a collision.
            playing       <= 1'b1;
            game_over     <= 1'b0;
            daisy_y       <= DAISY_GROUND_Y;
            obstacle_x    <= OBSTACLE_START;
            ground_offset <= 5'd0;
            jumping       <= 1'b0;
            jump_frame    <= 5'd0;
            score_bcd       <= 16'h0000;
            obstacle_scored <= 1'b0;
        end else if (frame_tick && playing) begin
            if (collision) begin
                playing   <= 1'b0;
                game_over <= 1'b1;
            end else begin
                // Count each obstacle once, after it clears Daisy.
                if (obstacle_passed) begin
                    obstacle_scored <= 1'b1;

                    if (score_bcd != 16'h9999) begin
                        if (score_bcd[3:0] != 4'd9) begin
                            score_bcd[3:0] <= score_bcd[3:0] + 4'd1;
                        end else begin
                            score_bcd[3:0] <= 4'd0;

                            if (score_bcd[7:4] != 4'd9) begin
                                score_bcd[7:4] <= score_bcd[7:4] + 4'd1;
                            end else begin
                                score_bcd[7:4] <= 4'd0;

                                if (score_bcd[11:8] != 4'd9) begin
                                    score_bcd[11:8] <= score_bcd[11:8] + 4'd1;
                                end else begin
                                    score_bcd[11:8] <= 4'd0;
                                    score_bcd[15:12] <= score_bcd[15:12] + 4'd1;
                                end
                            end
                        end
                    end
                end

                // Move the obstacle from right to left.
                if (obstacle_x <= OBSTACLE_SPEED) begin
                    obstacle_x <= 10'd640;
                    obstacle_scored <= 1'b0;
                end else begin
                    obstacle_x <= obstacle_x - OBSTACLE_SPEED;
                end

                ground_offset <= ground_offset + 5'd4;

                // Rise 84 pixels over 14 frames, then descend.
                if (!jumping) begin
                    if (jump_pending) begin
                        jumping    <= 1'b1;
                        jump_frame <= 5'd0;
                    end
                end else if (jump_frame < 5'd14) begin
                    daisy_y    <= daisy_y - JUMP_STEP;
                    jump_frame <= jump_frame + 5'd1;
                end else if (jump_frame < 5'd27) begin
                    daisy_y    <= daisy_y + JUMP_STEP;
                    jump_frame <= jump_frame + 5'd1;
                end else begin
                    daisy_y    <= DAISY_GROUND_Y;
                    jumping    <= 1'b0;
                    jump_frame <= 5'd0;
                end
            end
        end
    end

endmodule