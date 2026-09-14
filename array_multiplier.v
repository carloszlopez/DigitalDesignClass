// module array_multiplier(a, b, y);
//     parameter width = 8;
//     input [width-1:0] a, b;
//     output [width-1:0] y;
//     wire [width*width-1:0] partials;

//     genvar i;
//     assign partials[width-1 : 0] = a[0] ? b : 0;
    
//     generate for (i = 1; i < width; i = i+1) begin : gen
//         assign partials[width*(i+1)-1 : width*i] = (a[i] ? b << i : 0) +
//         partials[width*i-1 : width*(i-1)];
//         end 
//     endgenerate
//     assign y = partials[width*width-1 : width*(width-1)];
// endmodule

// Example N = 4
// 
// partials[3 : 0]  = a0 ? (b) : 0
// 
// Loop
// partials[7 : 4]  = a1 ? (b) << 1 : 0
// partials[11: 8]  = a2 ? (b) << 2 : 0
// partials[15: 12] = a2 ? (b) << 3 : 0
module array_multiplier(a, b, y);
    parameter width = 8;
    input [width-1:0] a, b;
    // output and partials now are 2*width
    output [2*width-1:0] y;
    wire [2*width*width-1:0] partials;   

    genvar i;
    assign partials[2*width-1 : 0] = a[0] ? b : 0;
    
    generate for (i = 1; i < width; i = i+1) begin : gen
        assign partials[2*width*(i+1)-1 : 2*width*i] = 
            (a[i] ? b << i : 0) + partials[2*width*i-1 : 2*width*(i-1)];
        end 
    endgenerate
    assign y = partials[2*width*width-1 : 2*width*(width-1)];
endmodule