// ESPECIFICACIONES 5
// El modelo de mayor jerarquía debe llamarse ALU_Display, debe ser un 
// modelo Verilog estructurado, donde instancies los bloques que lo componen, 
// por ejemplo, ALU, registros, multiplexores y módulos del display. 
// Cada módulo instanciado debe estar identificado por una etiqueta.
module ALU_Display #(
    // ESPECIFICACIONES 8 
    // Para la implementación en la tarjeta DE10-Standard, los operandos 
    // de entrada se deben definir en 5 bits y el resultado de la 
    // operación de multiplicación se debe truncar a 8 bits. 
    parameter len_in = 5,
    parameter len_out = 8
)(
    // inputs
    input [9:0] SW,
    input [3:0] KEY,
    input CLOCK_50,
    
    // outputs
    output [6:0] HEX0, HEX1, HEX2
);
    wire [len_out-1:0] res_reg_out;
    wire sel,enable, reset;
    wire [3:0] digit0, digit1, digit2;
    
    // ESPECIFICACIONES 3
    // Las entradas y salida de la ALU deben estar registradas, 
    // los puertos no se conectan directamente a la ALU, sino que primero 
    // se hacen pasar por un registro.
    reg [len_in-1:0] a_reg, b_reg;
    reg [3:0] ctrl_reg;
    wire [2*len_in-1:0] res_reg;
    wire carry_reg, overflow_reg, neg_reg, zero_reg;

    // modules inst
    ALU #(.len(len_in)) alu_inst (
        // inputs
        .a(a_reg), .b(b_reg), .ctrl(ctrl_reg),
        // outputs
        .res(res_reg), .carry(carry_reg), .overflow(overflow_reg), 
        .neg(neg_reg), .zero(zero_reg)
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

    // get control signals
    assign sel = SW[5];
    assign enable = ~KEY[0];
    assign reset = ~KEY[2];

    // get BCD value from res
    assign res_reg_out = res_reg[len_out-1:0];
    assign digit2 = res_reg_out / 100;
    assign digit1 = (res_reg_out % 100) / 10;
    assign digit0 = res_reg_out % 10;

    always @(posedge CLOCK_50) begin
        // ESPECIFICACIONES 9
        // El diseño de mayor jerarquía debe contar con señales de clk, rst, 
        // y enable. Esta última señal es la que habilita el almacenamiento 
        // de los datos de entrada y resultado. Debido a que el numero de 
        // switches y push-buttons es limitado en la tarjeta DE10-Standard, 
        // propón una idea creativa, efectiva y funcional para el usuario, para 
        // manejar las señales de control, rst y enable. 
        if (reset) begin
            // set a and b default value
            a_reg = 0;
            b_reg = 0;
            // Set unkown operation for ALU module
            ctrl_reg = 10;

        end else begin
                // Set a or b value
                if (enable & sel) begin
                    a_reg <= SW[len_in-1:0];
                end
                if (enable & ~sel) begin
                    b_reg <= SW[len_in-1:0];
                end
                // Set ctrl value
                ctrl_reg <= SW[9:6];
        end
    end
endmodule