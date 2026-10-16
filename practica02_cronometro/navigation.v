module navigation (
    input clk, 
    input reset, 
    input enable, 
    input edit, 
    input right_down, 
    input left_up,

    output reg [23:0] init_digits,
    output reg [2:0] selected_digit
);
    // /////////////////////////////////////////////////////////////////////////
    // navigation
    // /////////////////////////////////////////////////////////////////////////
    // toggle editing
    reg editing;

    always @(posedge clk) begin
        if (reset) begin
            editing <= 1'b0;

        end else if (enable & edit) begin
            editing <= ~editing;
        end
    end
    
    // max value of selected digit
    wire [3:0] selected_max =
        (selected_digit == 3 || selected_digit == 5) ? 4'd5 : 4'd9;

    // navigation
    reg [23:0] next_init_digits;
    reg [2:0] next_selected_digit;

    always @(*) begin
        next_init_digits = init_digits;
        next_selected_digit = selected_digit;

        if (!editing) begin
            // left navigation
            if (left_up) begin
                next_selected_digit = (selected_digit == 5) ?
                                3'd0 : selected_digit + 3'd1;
            
            // right navigation
            end else if (right_down) begin
                next_selected_digit = (selected_digit == 0) ?
                                3'd5 : selected_digit - 3'd1;
            end 
            
        end else begin
            // up navigation
            if (left_up) begin
                next_init_digits[selected_digit*4 +: 4] =
                    (init_digits[selected_digit*4 +: 4] == selected_max) ?
                    4'd0 : init_digits[selected_digit*4 +: 4] + 4'd1;
            
            // down navigation
            end else if (right_down) begin
                next_init_digits[selected_digit*4 +: 4] =
                    (init_digits[selected_digit*4 +: 4] == 0) ?
                    selected_max : init_digits[selected_digit*4 +: 4] - 4'd1;
            end
        end 
    end

    // /////////////////////////////////////////////////////////////////////////
    // register outputs
    // /////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            selected_digit <= 1'b0;
            init_digits <= 24'd0;  
        end else if (enable) begin
            selected_digit <= next_selected_digit;    
            init_digits <= next_init_digits;  
        end
    end
endmodule
    