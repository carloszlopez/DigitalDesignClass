////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Carlos Zepeda
// Description: Top-level module for the ALU and seven-segment displays.
//              It captures operands and the selected operation from the
//              switches, stores the ALU result, and displays arithmetic
//              results in decimal or logic results in hexadecimal.
//              HEX3 indicates a negative arithmetic result.
////////////////////////////////////////////////////////////////////////////////
module ALU_Display #(
    // a and b lenght
    parameter lenghtIn = 5,
    // number displayed lenght
    parameter lenghtOut = 8
)(
    // inputs
    input [9:0] SW,
    input [3:0] KEY,
    input CLOCK_50,
    
    // outputs
    output [6:0] HEX0, HEX1, HEX2, HEX3
);
    // Values used to represent sign in display
    localparam [6:0] SIGN_ON = 7'b0111111;
    localparam [6:0] SIGN_OFF = 7'b1111111;

    // control inputs
    wire sel, enable, reset;
    assign sel = SW[5];
    assign enable = ~KEY[0];
    assign reset = ~KEY[1];
    
    // alu inputs
    reg [lenghtIn-1:0] aluA, aluB;
    reg [3:0] aluCtrl;
    wire [2*lenghtIn-1:0] aluRes;
    wire aluCarry, aluOverflow, aluNeg, aluZero;

    // working registers
    reg [lenghtOut-1:0] wRes;
    reg [3:0] wCtrl;

    // digits
    reg [3:0] digit0, digit1, digit2;
    wire [3:0] bcd_hundreds, bcd_tens, bcd_ones;

    // display sign if negative and aritmetic operation
    wire isArith, isNeg; 
    wire [lenghtOut-1:0] magnitude;
    assign isArith = wCtrl <= 4'd3;
    assign isNeg = wRes[lenghtOut-1] & isArith;
    assign magnitude = isNeg ? (~wRes + 1'b1) : wRes;
    assign HEX3 = (isNeg) ? SIGN_ON : SIGN_OFF;

    // module instances
    ALU #(.len(lenghtIn)) alu_inst (
    // inputs
    .a(aluA), .b(aluB), .ctrl(aluCtrl),
    // outputs
    .res(aluRes), .carry(aluCarry), .overflow(aluOverflow), 
    .neg(aluNeg), .zero(aluZero)
    );

    display_7_seg display_digit0 (
        // inputs
        .SW(digit0),
        // outputs
        .HEX0(HEX0)
    );

    display_7_seg display_digit1 (
        // inputs
        .SW(digit1),
        // outputs
        .HEX0(HEX1)
    );

    display_7_seg display_digit2 (
        // inputs
        .SW(digit2),
        // outputs
        .HEX0(HEX2)
    );

    binary_to_bcd #(
    .LENGTH(lenghtOut)
    ) bcd_inst (
        .binary_value(magnitude),
        .hundreds(bcd_hundreds),
        .tens(bcd_tens),
        .ones(bcd_ones)
    );


    // save logic
    always @(posedge CLOCK_50) begin
        if (reset) begin
            // reset alu inputs
            aluA    <= 0;
            aluB    <= 0;
            aluCtrl  <= 4'd10; // Unkown operation
            
            // reset working registers
            wRes    <= 0;
            wCtrl   <= 4'd10; // Unkown operation

        end else if (enable) begin
                // Set alu inputs
                if (sel) begin
                    aluA <= SW[lenghtIn-1:0];
                end else begin
                    aluB <= SW[lenghtIn-1:0];
                end
                aluCtrl <= SW[9:6];
                
                // Update working registers
                wRes    <= aluRes[lenghtOut-1:0];
                wCtrl   <= aluCtrl;
        end
    end
    
    // display logic
    always @ * begin
        //  default values displayed
        digit0 = 4'd0;
        digit1 = 4'd0;
        digit2 = 4'd0;

        if (isArith) begin
            // display digits in decimal
            digit2 = bcd_hundreds;
            digit1 = bcd_tens;
            digit0 = bcd_ones;
        end else begin
            // display digits in hex
            digit2 = 4'd0;
            digit1 = wRes[7:4];
            digit0 = wRes[3:0];
        end
    end
endmodule