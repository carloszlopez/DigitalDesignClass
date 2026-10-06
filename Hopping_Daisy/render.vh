// render.vh
`ifndef RENDER_VH
`define RENDER_VH

// RGB colors (24'hRRGGBB)
`define RGB_RESET       (24'h000000)
`define RGB_SKY         (24'h0080FF)
`define RGB_GROUND      (24'h30B040)
`define RGB_GROUND_MARK (24'h186020)
`define RGB_OBSTACLE    (24'hFF2020)
`define RGB_SCORE_TEXT  (24'hFFFFFF)

//SCORE positions
`define SCORE_H_START   (10'd16)
`define SCORE_H_SIZE    (10'd80)
`define SCORE_H_END     (`SCORE_H_START + `SCORE_H_SIZE)
`define SCORE_V_START   (10'd16)
`define SCORE_V_SIZE    (10'd7)
`define SCORE_V_END     (`SCORE_V_START + `SCORE_V_SIZE)


`endif