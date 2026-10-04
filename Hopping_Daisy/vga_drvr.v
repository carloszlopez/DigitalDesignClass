`include "common_defines.vh"

module vga_drvr (
    input  wire clk_in, // 50 MHz input clock
    input  wire reset_n, // Active-low reset
    input  wire [7:0] red_in,
    input  wire [7:0] green_in,
    input  wire [7:0] blue_in,

    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output reg clk, // 25 MHz VGA pixel clock
    output reg hsync, // Horizontal sync
    output reg vsync, // Vertical sync
    output wire sync_n, // VGA DAC sync
    output reg blank_n, // VGA DAC blanking
    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y,
    output reg frame_tick
);
    // Combinational variables
    reg clk_comb;

    reg [9:0] pixel_x_comb;
    reg [9:0] pixel_y_comb;

    reg blank_n_comb;
    reg hsync_comb;
    reg vsync_comb;
    reg [7:0] red_comb;
    reg [7:0] green_comb;
    reg [7:0] blue_comb;

    reg frame_tick_comb;

    // Disable sync_n
    assign sync_n  = 1'b0;
    
    always @(*) begin
        // Reset
        if (!reset_n) begin
            clk_comb = 1'b0;

            pixel_x_comb = 10'd0;
            pixel_y_comb = 10'd0;

            blank_n_comb = 1'b0;
            hsync_comb = 1'b1;
            vsync_comb = 1'b1;
            red_comb = 8'd0;
            green_comb = 8'd0;
            blue_comb = 8'd0;

            frame_tick_comb = 1'b0;

        end else begin

            // Pixel clock divider: 50 MHz to 25 MHz
            clk_comb = ~clk;

            // Hold the current values by default
            pixel_x_comb = pixel_x;
            pixel_y_comb = pixel_y;

            blank_n_comb = blank_n;
            hsync_comb = hsync;
            vsync_comb = vsync;
            red_comb = red;
            green_comb = green;
            blue_comb = blue;

            // Clear frame tick
            frame_tick_comb = 1'b0;

            // Pixel clock enable
            if (clk) begin

                // Pixel counters: pixel_x (0 to 799) and pixel_y (0 to 524)
                // Advanced one pixel
                if (pixel_x == `H_TOTAL - 1) begin
                    // Reset horizontal counter
                    pixel_x_comb = 10'd0;
                    if (pixel_y == `V_TOTAL - 1) begin
                        // Reset vertical counter
                        pixel_y_comb = 10'd0; 
                    end else begin
                         // Advance vertically
                        pixel_y_comb = pixel_y + 10'd1;
                    end
                end else begin
                    // Advance horizontally
                    pixel_x_comb = pixel_x + 10'd1;
                end

                // VGA outputs
                // !blank if pixel visible
                blank_n_comb = (pixel_x < `H_VISIBLE) && 
										 (pixel_y < `V_VISIBLE);
                // sync if pixel is between sync start and end
                hsync_comb = ~((pixel_x >= `H_SYNC_START) && 
                             (pixel_x <  `H_SYNC_END));
                vsync_comb = ~((pixel_y >= `V_SYNC_START) && 
                             (pixel_y <  `V_SYNC_END));
                // RGB if pixel visible
                red_comb = blank_n_comb ? red_in : 8'd0;
                green_comb = blank_n_comb ? green_in : 8'd0;
                blue_comb = blank_n_comb ? blue_in : 8'd0;

                // One tick of 50 MHz clock cycle at the end of each video frame
                frame_tick_comb = (pixel_x == `H_TOTAL - 1) && 
                                  (pixel_y == `V_TOTAL - 1);
            end
        end
    end
    
    // Register outputs
    always @ (posedge clk_in) begin
        clk <= clk_comb;

        pixel_x <= pixel_x_comb;
        pixel_y <= pixel_y_comb;

        blank_n <= blank_n_comb;
        vsync   <= vsync_comb;
        hsync   <= hsync_comb;
        red     <= red_comb;
        green   <= green_comb;
        blue    <= blue_comb;

        frame_tick <= frame_tick_comb;        
    end
endmodule