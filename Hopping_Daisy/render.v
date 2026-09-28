module render (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [9:0] daisy_y,
    input  wire [9:0] obstacle_x,
    input  wire [4:0] ground_offset,

    output reg  [7:0] red,
    output reg  [7:0] green,
    output reg  [7:0] blue
);

    // Keep only the low 5 bits to repeat a pattern every 32 pixels.
    wire [4:0] ground_pattern = pixel_x[4:0] + ground_offset;

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
    end

endmodule