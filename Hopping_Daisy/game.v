module game (
    input  wire       clk_in,
    input  wire       reset_n,
    input  wire       jump_n,
    input  wire       frame_tick,
    output reg  [9:0] daisy_y
);

    localparam [9:0] DAISY_GROUND_Y = 10'd360;
    localparam [9:0] JUMP_STEP      = 10'd4;

    reg key_meta;
    reg key_sync;
    reg key_previous;
    reg jump_pending;

    reg       jumping;
    reg [4:0] jump_frame;

    wire key_pressed = key_previous && !key_sync;

    // Synchronize the button signal to the 50 MHz clock.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            key_meta     <= 1'b1;
            key_sync     <= 1'b1;
            key_previous <= 1'b1;
        end else begin
            key_meta     <= jump_n;
            key_sync     <= key_meta;
            key_previous <= key_sync;
        end
    end

    // Remember a press until the next video frame.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n)
            jump_pending <= 1'b0;
        else if (key_pressed)
            jump_pending <= 1'b1;
        else if (frame_tick)
            jump_pending <= 1'b0;
    end

    // Update Daisy's position once per frame.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            daisy_y    <= DAISY_GROUND_Y;
            jumping    <= 1'b0;
            jump_frame <= 5'd0;
        end else if (frame_tick) begin
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