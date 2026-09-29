module render (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [9:0] daisy_y,
    input  wire [9:0] obstacle_x,
    input  wire [4:0] ground_offset,
    input  wire [15:0] score_bcd,

    output reg  [7:0] red,
    output reg  [7:0] green,
    output reg  [7:0] blue
);
    // Five columns by seven rows per glyph, stored from top left.
    function [34:0] glyph;
        input [4:0] symbol;
        begin
            case (symbol)
                5'd0: glyph = {5'b01110,5'b10001,5'b10011,5'b10101,5'b11001,5'b10001,5'b01110};
                5'd1: glyph = {5'b00100,5'b01100,5'b00100,5'b00100,5'b00100,5'b00100,5'b01110};
                5'd2: glyph = {5'b01110,5'b10001,5'b00001,5'b00010,5'b00100,5'b01000,5'b11111};
                5'd3: glyph = {5'b11110,5'b00001,5'b00001,5'b01110,5'b00001,5'b00001,5'b11110};
                5'd4: glyph = {5'b00010,5'b00110,5'b01010,5'b10010,5'b11111,5'b00010,5'b00010};
                5'd5: glyph = {5'b11111,5'b10000,5'b10000,5'b11110,5'b00001,5'b00001,5'b11110};
                5'd6: glyph = {5'b01110,5'b10000,5'b10000,5'b11110,5'b10001,5'b10001,5'b01110};
                5'd7: glyph = {5'b11111,5'b00001,5'b00010,5'b00100,5'b01000,5'b01000,5'b01000};
                5'd8: glyph = {5'b01110,5'b10001,5'b10001,5'b01110,5'b10001,5'b10001,5'b01110};
                5'd9: glyph = {5'b01110,5'b10001,5'b10001,5'b01111,5'b00001,5'b00001,5'b01110};

                5'd10: glyph = {5'b01111,5'b10000,5'b10000,5'b01110,5'b00001,5'b00001,5'b11110}; // S
                5'd11: glyph = {5'b01111,5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b01111}; // C
                5'd12: glyph = {5'b01110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110}; // O
                5'd13: glyph = {5'b11110,5'b10001,5'b10001,5'b11110,5'b10100,5'b10010,5'b10001}; // R
                5'd14: glyph = {5'b11111,5'b10000,5'b10000,5'b11110,5'b10000,5'b10000,5'b11111}; // E

                default: glyph = 35'd0; // Space
            endcase
        end
    endfunction

    wire [4:0] ground_pattern = pixel_x[4:0] + ground_offset;

    wire text_area = (pixel_x >= 10'd16) && (pixel_x < 10'd96) &&
                     (pixel_y >= 10'd16) && (pixel_y < 10'd23);

    wire [9:0] text_x = pixel_x - 10'd16;
    wire [3:0] char_index = text_x[6:3];
    wire [2:0] glyph_x = text_x[2:0];
    wire [2:0] glyph_y = pixel_y - 10'd16;

    reg [4:0] symbol;

    always @(*) begin
        case (char_index)
            4'd0: symbol = 5'd10; // S
            4'd1: symbol = 5'd11; // C
            4'd2: symbol = 5'd12; // O
            4'd3: symbol = 5'd13; // R
            4'd4: symbol = 5'd14; // E
            4'd5: symbol = 5'd15; // Space

            4'd6: symbol = {1'b0, score_bcd[15:12]};
            4'd7: symbol = {1'b0, score_bcd[11:8]};
            4'd8: symbol = {1'b0, score_bcd[7:4]};
            4'd9: symbol = {1'b0, score_bcd[3:0]};

            default: symbol = 5'd15;
        endcase
    end

    wire [34:0] current_glyph = glyph(symbol);

    wire text_pixel = text_area && (glyph_x < 3'd5) &&
                      current_glyph[34 - (glyph_y * 5 + glyph_x)];

    always @(*) begin
        // Sky.
        red   = 8'h00;
        green = 8'h80;
        blue  = 8'hFF;

        // Ground.
        if (pixel_y >= 10'd400) begin
            red   = 8'h30;
            green = 8'hB0;
            blue  = 8'h40;
        end

        // Moving marks on the ground.
        if ((pixel_y >= 10'd408) && (pixel_y < 10'd414) &&
            (ground_pattern < 5'd12)) begin
            red   = 8'h18;
            green = 8'h60;
            blue  = 8'h20;
        end

        // Daisy placeholder: 40 x 40 pixels.
        if ((pixel_x >= 10'd80) && (pixel_x < 10'd120) &&
            (pixel_y >= daisy_y) && (pixel_y < daisy_y + 10'd40)) begin
            red   = 8'hFF;
            green = 8'hFF;
            blue  = 8'hFF;
        end

        // Obstacle: 20 x 30 pixels, resting on the ground.
        if ((pixel_x >= obstacle_x) &&
            (pixel_x < obstacle_x + 10'd20) &&
            (pixel_y >= 10'd370) && (pixel_y < 10'd400)) begin
            red   = 8'hFF;
            green = 8'h20;
            blue  = 8'h20;
        end

        // Score text, drawn over the scene.
        if (text_pixel) begin
            red = 8'hFF;
            green = 8'hFF;
            blue = 8'hFF;
        end
    end
    
endmodule