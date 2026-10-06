// vga_defs.vh
`ifndef VGA_DEFS_VH
`define VGA_DEFS_VH

// Timing for 640x480 video with a 25 MHz pixel clock.
`define H_VISIBLE 640
`define H_FRONT 16
`define H_SYNC 96
`define H_BACK 48
`define H_TOTAL (`H_VISIBLE + `H_FRONT + `H_SYNC + `H_BACK)
`define V_VISIBLE 480
`define V_FRONT 10
`define V_SYNC 2
`define V_BACK 33
`define V_TOTAL (`V_VISIBLE + `V_FRONT + `V_SYNC + `V_BACK)
`define H_SYNC_START (`H_VISIBLE + `H_FRONT)
`define H_SYNC_END (`H_SYNC_START + `H_SYNC)
`define V_SYNC_START (`V_VISIBLE + `V_FRONT)
`define V_SYNC_END (`V_SYNC_START + `V_SYNC)

// Ground
`define GROUND_V_START  (10'd400)

// Obstacle
`define OBSTACLE_H_SIZE     (10'd20)
`define OBSTACLE_V_START    (10'd370)
`define OBSTACLE_V_SIZE     (10'd30)
`define OBSTACLE_V_END      (`OBSTACLE_V_START + `OBSTACLE_V_SIZE)

// Daisy
`define DAISY_H_START    (10'd80)
`define DAISY_H_SIZE     (10'd40)
`define DAISY_H_END      (`DAISY_H_START + `DAISY_H_SIZE)
`define DAISY_V_SIZE     (10'd40)

`endif