module render (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    output reg  [7:0] red,
    output reg  [7:0] green,
    output reg  [7:0] blue
);

    always @(*) begin
        // Blue background.
        red   = 8'h00;
        green = 8'h80;
        blue  = 8'hFF;

        // Green ground from y = 400 to the bottom.
        if (pixel_y >= 10'd400) begin
            red   = 8'h30;
            green = 8'hB0;
            blue  = 8'h40;
        end

        // White placeholder for Daisy: x = 80..119, y = 360..399.
        if ((pixel_x >= 10'd80)  && (pixel_x < 10'd120) &&
            (pixel_y >= 10'd360) && (pixel_y < 10'd400)) begin
            red   = 8'hFF;
            green = 8'hFF;
            blue  = 8'hFF;
        end
    end

endmodule