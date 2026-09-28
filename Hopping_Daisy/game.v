module game (
    input  wire       clk_in,
    input  wire       reset_n,
    input  wire       start_n,     // KEY[1], active low
    input  wire       jump_n,      // KEY[3], active low
    input  wire       frame_tick,

    output reg        playing,
    output reg  [9:0] daisy_y,
    output reg  [9:0] obstacle_x,
    output reg  [4:0] ground_offset
);

    localparam [9:0] DAISY_GROUND_Y = 10'd360;
    localparam [9:0] OBSTACLE_START = 10'd600;
    localparam [9:0] OBSTACLE_SPEED = 10'd4;
    localparam [9:0] JUMP_STEP      = 10'd4;

    reg start_meta, start_sync, start_previous;
    reg jump_meta, jump_sync, jump_previous;
    reg jump_pending;

    reg       jumping;
    reg [4:0] jump_frame;

    wire start_pressed = start_previous && !start_sync;
    wire jump_pressed  = jump_previous  && !jump_sync;

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
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n)
            jump_pending <= 1'b0;
        else if (jump_pressed && playing)
            jump_pending <= 1'b1;
        else if (frame_tick)
            jump_pending <= 1'b0;
    end

    // Start the game when KEY[1] is pressed.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n)
            playing <= 1'b0;
        else if (start_pressed)
            playing <= 1'b1;
    end

    // Move the obstacle, ground, and Daisy once per frame.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            daisy_y       <= DAISY_GROUND_Y;
            obstacle_x    <= OBSTACLE_START;
            ground_offset <= 5'd0;
            jumping       <= 1'b0;
            jump_frame    <= 5'd0;
        end else if (frame_tick && playing) begin
            // Move the obstacle left; restart it at the right edge.
            if (obstacle_x <= OBSTACLE_SPEED)
                obstacle_x <= 10'd640;
            else
                obstacle_x <= obstacle_x - OBSTACLE_SPEED;

            // The 5-bit value wraps automatically after 31.
            ground_offset <= ground_offset + 5'd4;

            // Move Daisy up for 10 frames, then down for 10 frames.
            if (!jumping) begin
                if (jump_pending) begin
                    jumping    <= 1'b1;
                    jump_frame <= 5'd0;
                end
            end else if (jump_frame < 5'd10) begin
                daisy_y    <= daisy_y - JUMP_STEP;
                jump_frame <= jump_frame + 5'd1;
            end else if (jump_frame < 5'd19) begin
                daisy_y    <= daisy_y + JUMP_STEP;
                jump_frame <= jump_frame + 5'd1;
            end else begin
                daisy_y    <= DAISY_GROUND_Y;
                jump_frame <= 5'd0;
                jumping    <= 1'b0;
            end
        end
    end

endmodule