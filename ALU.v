////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Carlos Zepeda
// Description: Parameterized combinational ALU. It performs signed arithmetic,
//              bitwise logic, and shift operations on inputs A and B according
//              to ctrl. It outputs the result and the carry, overflow,
//              negative, and zero flags.
////////////////////////////////////////////////////////////////////////////////

module ALU #(
	parameter len = 5
)(
    // inputs
    input [len-1:0] a,b,
    input [3:0] ctrl,

    // outputs
    output reg[2*len-1:0] res,
    output reg carry, overflow, neg, zero
);
    // for integer
    integer i;
    // temporal used as carry or borrow for the addition
    reg [len:0] c;
    // temporal used to keep the unsigned a_magnitude and b_magnitud
    reg [len-1:0] a_magnitude;
    reg [len-1:0] b_magnitude;
    // temporal used to keep the accumulator value for the multiplication
    reg [2*len-1:0] product;

    // operation selection
    always @ * begin
        // default values
        res = 0;
        carry = 0; 
        overflow = 0;
        neg = 0; 
        zero = 0;
        c = 0;
        a_magnitude = 0;
        b_magnitude = 0;
        product = 0;

        case (ctrl)

            0: begin // suma aritmética de números signados
                for (i=0; i<len; i =i+1) begin
                    // current position result
                    res[i] = a[i] ^ b[i] ^ c[i];
                    // next position carry
                    c[i+1] = (a[i] & b[i]) | (a[i] & c[i]) | 
                                    (b[i] & c[i]);
                end

                // Sign extension
                res[2*len-1:len] = {len{res[len-1]}};

                // set carry flag with last c carry
                carry = c[len];
                // set overflow if a and b signs are equal but different to res
                overflow = (~(a[len-1] ^ b[len-1])) & (res[len-1] ^ a[len-1]);
                // set negative if len bit of result is 1
                neg = res[len-1];
                // Set zero flag if res is zero
                zero = (res == 0);

            end

            1: begin // resta aritmética de números signados
                for (i=0; i<len; i =i+1) begin
                    // current position result
                    res[i] = a[i] ^ b[i] ^ c[i];
                    // next borrow carry
                    c[i+1] = (~a[i] & b[i]) | (~(a[i] ^ b[i]) & c[i]);
                end
                
                // Sign extension
                res[2*len-1:len] = {len{res[len-1]}};
                
                // set overflow if a, b and res signs are not equal
                overflow = (a[len-1] ^ b[len-1]) & (res[len-1] ^ a[len-1]);
                // set negative if len bit of result is 1
                neg = res[len-1];
                // Set zero flag if res is zero
                zero = (res == 0);

            end

            2: begin // negativo de b, donde b es un numero signado
                // a2 complement
                res[len-1:0] = (~b) + 1'b1;

                // Sign extension
                res[2*len-1:len] = {len{res[len-1]}};

                overflow = (b == {1'b1, {(len-1){1'b0}}});
                // set negative if len bit of result is 1
                neg = res[len-1];
                // Set zero flag if res is zero
                zero = (res == 0);

            end

            3: begin // multiplicación de números signados 
                // unsinged magnitud of a
                if (a[len-1])
                    a_magnitude = (~a) + 1'b1;
                else
                    a_magnitude = a;

                // unsinged magnitud of b
                if (b[len-1])
                    b_magnitude = (~b) + 1'b1;
                else
                    b_magnitude = b;

                // unsinged multiplication
                for (i=0; i<len; i =i+1) begin
                    if (a_magnitude[i]) begin
                        product = product + ({{len{1'b0}}, b_magnitude} << i);
                    end
                end

                // operands with different signs produce a negative result
                if (a[len-1] ^ b[len-1])
                    res = (~product) + 1'b1;
                else
                    res = product;

                // set negative if len bit of result is 1
                neg = res[2*len-1];
                // Set zero flag if res is zero
                zero = (res == 0);

            end

            4: // operación lógica AND
                res = a & b;

            5: // operación lógica OR
                res = a | b;
           
            6: // negación lógica de a 
                res = ~a;

            7: // operación lógica XOR 
                res = a ^ b;
            
            8: // corrimiento de bits: res = a << b[3:0]
                res = a << b[3:0];
            
            9: // corrimiento de bits: res = a >> b[3:0]
                res = a >> b[3:0];

            // default: // Unkwon operation 
        endcase
    end
endmodule