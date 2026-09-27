module vga_drvr (
    input  wire       clk_in,      // 50 MHz input clock
    input  wire       reset_n,     // Active-low reset
    input  wire [7:0] red_in,
    input  wire [7:0] green_in,
    input  wire [7:0] blue_in,

    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
    output reg        clk,         // 25 MHz VGA pixel clock
    output wire       hsync,       // Horizontal sync
    output wire       vsync,       // Vertical sync
    output wire       sync_n,      // VGA DAC sync
    output wire       blank_n,     // VGA DAC blanking
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y,
    output wire       frame_tick
);

    // Timing for 640x480 video with a 25 MHz pixel clock.
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    localparam H_SYNC_START = H_VISIBLE + H_FRONT;
    localparam H_SYNC_END   = H_SYNC_START + H_SYNC;

    localparam V_SYNC_START = V_VISIBLE + V_FRONT;
    localparam V_SYNC_END   = V_SYNC_START + V_SYNC;

    reg [9:0] h_count;
    reg [9:0] v_count;

    // Toggle on every 50 MHz cycle to generate a 25 MHz pixel clock.
    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            clk     <= 1'b0;
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            clk <= ~clk;

            // Advance one pixel when the pixel clock falls.
            if (clk) begin
                if (h_count == H_TOTAL - 1) begin
                    h_count <= 10'd0;

                    if (v_count == V_TOTAL - 1)
                        v_count <= 10'd0;
                    else
                        v_count <= v_count + 10'd1;
                end else begin
                    h_count <= h_count + 10'd1;
                end
            end
        end
    end

    wire visible = (h_count < H_VISIBLE) &&
                   (v_count < V_VISIBLE);

    assign pixel_x = h_count;
    assign pixel_y = v_count;

    // Sync pulses are active low.
    assign hsync = ~((h_count >= H_SYNC_START) &&
                     (h_count <  H_SYNC_END));

    assign vsync = ~((v_count >= V_SYNC_START) &&
                     (v_count <  V_SYNC_END));

    assign blank_n = visible;
    assign sync_n  = 1'b0;

    // Output black outside the visible area.
    assign red   = visible ? red_in   : 8'd0;
    assign green = visible ? green_in : 8'd0;
    assign blue  = visible ? blue_in  : 8'd0;

    // One 50 MHz clock cycle at the end of each video frame.
    assign frame_tick = clk && (h_count == H_TOTAL - 1) 
                        && (v_count == V_TOTAL - 1);

endmodule