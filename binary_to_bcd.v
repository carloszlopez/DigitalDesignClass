////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Carlos Zepeda
// Description: Converts an unsigned binary value into three 4-bit
//              BCD digits: hundreds, tens, and ones.
////////////////////////////////////////////////////////////////////////////////

module binary_to_bcd #(
    parameter LENGTH = 8
)(
    input  wire [LENGTH-1:0] binary_value,
    output wire [3:0] hundreds,
    output wire [3:0] tens,
    output wire [3:0] ones
);

    assign hundreds = binary_value / 100;
    assign tens     = (binary_value % 100) / 10;
    assign ones     = binary_value % 10;

endmodule