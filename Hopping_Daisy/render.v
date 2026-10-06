`include "common_defines.vh"
`include "render.vh"
`include "daisy_bitmap.vh"

module render (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [9:0] daisy_y,
    input  wire [9:0] obstacle_x,
    input  wire [4:0] ground_offset,
    input  wire [15:0] score_bcd,
    input  wire clk_in,
    input  wire reset_n,

    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue
);

    reg [7:0] red_comb, green_comb, blue_comb;

    // Packed 40x40 RGB image.
    localparam integer DAISY_IMAGE_WIDTH  = 40;
    localparam integer DAISY_IMAGE_HEIGHT = 40;
    localparam integer DAISY_IMAGE_BITS =
        DAISY_IMAGE_WIDTH * DAISY_IMAGE_HEIGHT * 24;

    localparam [DAISY_IMAGE_BITS-1:0] DAISY_IMAGE = `DAISY_BITMAP;
    localparam [23:0] RGB_GROUND_MARK = 24'h186020;

    integer daisy_bit_index;
    reg [23:0] daisy_color;

    // Repeat the ground pattern every 32 pixels.
    wire [4:0] ground_pattern = pixel_x[4:0] + ground_offset;

    integer text_x;
    integer text_y;
    integer character_index;
    integer character_column;

    reg [3:0] character_code;
    reg [34:0] character_bitmap;
    reg text_pixel;

    always @(*) begin
        // Default values for intermediate signals.
        daisy_bit_index = 0;
        daisy_color = `RGB_DAISY_TRANSPARENT;

        text_x = 0;
        text_y = 0;
        character_index = 0;
        character_column = 0;
        character_code = 4'd15;
        character_bitmap = 35'd0;
        text_pixel = 1'b0;

        if (!reset_n) begin
            {red_comb, green_comb, blue_comb} = `RGB_RESET;

        end else begin
            // Sky
            {red_comb, green_comb, blue_comb} = `RGB_SKY;

            // Ground
            if (pixel_y >= `GROUND_V_START) begin
                {red_comb, green_comb, blue_comb} = `RGB_GROUND;
            end

            // Moving marks on the ground.
            if ((pixel_y >= (`GROUND_V_START + 8)) &&
                (pixel_y <  (`GROUND_V_START + 14)) &&
                (ground_pattern < 5'd12)) begin
                {red_comb, green_comb, blue_comb} = RGB_GROUND_MARK;
            end

            // Obstacle
            if ((pixel_x >= obstacle_x) &&
                (pixel_x < obstacle_x + `OBSTACLE_H_SIZE) &&
                (pixel_y >= `OBSTACLE_V_START) &&
                (pixel_y <  `OBSTACLE_V_END)) begin
                {red_comb, green_comb, blue_comb} = `RGB_OBSTACLE;
            end

            // Daisy
            if ((pixel_x >= `DAISY_H_START) &&
                (pixel_x <  `DAISY_H_END) &&
                (pixel_y >= daisy_y) &&
                (pixel_y < daisy_y + `DAISY_V_SIZE)) begin

                // Convert local coordinates to a packed RGB bit position.
                daisy_bit_index = DAISY_IMAGE_BITS - 24 - 24 * (
                    (pixel_y - daisy_y) * DAISY_IMAGE_WIDTH +
                    (pixel_x - `DAISY_H_START)
                );

                daisy_color = DAISY_IMAGE[daisy_bit_index +: 24];

                // Preserve the scene behind transparent pixels.
                if (daisy_color != `RGB_DAISY_TRANSPARENT) begin
                    {red_comb, green_comb, blue_comb} = daisy_color;
                end
            end

            // Score text area.
            if ((pixel_x >= `SCORE_H_START) &&
                (pixel_x <  `SCORE_H_END) &&
                (pixel_y >= `SCORE_V_START) &&
                (pixel_y <  `SCORE_V_END)) begin

                text_x = pixel_x - `SCORE_H_START;
                text_y = pixel_y - `SCORE_V_START;

                // Each character occupies an 8x7 cell.
                character_index  = text_x / 8;
                character_column = text_x % 8;

                // Select the character in "SCORE 0000".
                case (character_index)
                    0: character_code = 4'd10; // S
                    1: character_code = 4'd11; // C
                    2: character_code = 4'd12; // O
                    3: character_code = 4'd13; // R
                    4: character_code = 4'd14; // E
                    5: character_code = 4'd15; // Space
                    6: character_code = score_bcd[15:12];
                    7: character_code = score_bcd[11:8];
                    8: character_code = score_bcd[7:4];
                    9: character_code = score_bcd[3:0];
                    default: character_code = 4'd15;
                endcase

                // Seven rows of five pixels, from top to bottom.
                case (character_code)
                    4'd0: character_bitmap = {
                        5'b01110, 5'b10001, 5'b10011, 5'b10101,
                        5'b11001, 5'b10001, 5'b01110
                    };
                    4'd1: character_bitmap = {
                        5'b00100, 5'b01100, 5'b00100, 5'b00100,
                        5'b00100, 5'b00100, 5'b01110
                    };
                    4'd2: character_bitmap = {
                        5'b01110, 5'b10001, 5'b00001, 5'b00010,
                        5'b00100, 5'b01000, 5'b11111
                    };
                    4'd3: character_bitmap = {
                        5'b11110, 5'b00001, 5'b00001, 5'b01110,
                        5'b00001, 5'b00001, 5'b11110
                    };
                    4'd4: character_bitmap = {
                        5'b00010, 5'b00110, 5'b01010, 5'b10010,
                        5'b11111, 5'b00010, 5'b00010
                    };
                    4'd5: character_bitmap = {
                        5'b11111, 5'b10000, 5'b10000, 5'b11110,
                        5'b00001, 5'b00001, 5'b11110
                    };
                    4'd6: character_bitmap = {
                        5'b01110, 5'b10000, 5'b10000, 5'b11110,
                        5'b10001, 5'b10001, 5'b01110
                    };
                    4'd7: character_bitmap = {
                        5'b11111, 5'b00001, 5'b00010, 5'b00100,
                        5'b01000, 5'b01000, 5'b01000
                    };
                    4'd8: character_bitmap = {
                        5'b01110, 5'b10001, 5'b10001, 5'b01110,
                        5'b10001, 5'b10001, 5'b01110
                    };
                    4'd9: character_bitmap = {
                        5'b01110, 5'b10001, 5'b10001, 5'b01111,
                        5'b00001, 5'b00001, 5'b01110
                    };
                    4'd10: character_bitmap = { // S
                        5'b01111, 5'b10000, 5'b10000, 5'b01110,
                        5'b00001, 5'b00001, 5'b11110
                    };
                    4'd11: character_bitmap = { // C
                        5'b01110, 5'b10001, 5'b10000, 5'b10000,
                        5'b10000, 5'b10001, 5'b01110
                    };
                    4'd12: character_bitmap = { // O
                        5'b01110, 5'b10001, 5'b10001, 5'b10001,
                        5'b10001, 5'b10001, 5'b01110
                    };
                    4'd13: character_bitmap = { // R
                        5'b11110, 5'b10001, 5'b10001, 5'b11110,
                        5'b10100, 5'b10010, 5'b10001
                    };
                    4'd14: character_bitmap = { // E
                        5'b11111, 5'b10000, 5'b10000, 5'b11110,
                        5'b10000, 5'b10000, 5'b11111
                    };
                    default: character_bitmap = 35'd0;
                endcase

                // Leave three blank columns between characters.
                if ((character_column < 5) && (text_y < 7)) begin
                    text_pixel = character_bitmap[
                        34 - (text_y * 5 + character_column)
                    ];
                end

                // Draw only the active pixels of the character.
                if (text_pixel) begin
                    {red_comb, green_comb, blue_comb} = `RGB_SCORE_TEXT;
                end
            end
        end
    end

    // Register outputs.
    always @(posedge clk_in) begin
        {red, green, blue} <= {red_comb, green_comb, blue_comb};
    end

endmodule