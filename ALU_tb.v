`timescale 1ns/1ps

module ALU_tb;

    parameter len = 5;

    // Inputs applied to the DUT
    reg [len-1:0] a;
    reg [len-1:0] b;
    reg [3:0] ctrl;

    // Outputs produced by the DUT
    wire [2*len-1:0] res;
    wire carry;
    wire overflow;
    wire neg;
    wire zero;

    // Device Under Test
    ALU #(
        .len(len)
    ) dut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .res(res),
        .carry(carry),
        .overflow(overflow),
        .neg(neg),
        .zero(zero)
    );

    integer tests = 0;
    integer errors = 0;

    // Reference model: arithmetic wraps to len bits except multiplication.
    // Carry is checked for addition; other operations leave it cleared.
    // Logic, shifts and unknown operations leave all flags cleared.
    task apply_test;
        input [3:0] operation;
        input [len-1:0] input_a;
        input [len-1:0] input_b;
        reg signed [2*len-1:0] signed_a, signed_b, exact_result;
        reg signed [len-1:0] wrapped_result;
        reg [len:0] unsigned_sum;
        reg [2*len-1:0] expected_res;
        reg expected_carry, expected_overflow, expected_neg, expected_zero;

        begin
            signed_a = $signed(input_a);
            signed_b = $signed(input_b);
            exact_result = 0;
            expected_res = 0;
            expected_carry = 0;
            expected_overflow = 0;
            expected_neg = 0;
            expected_zero = 0;

            case (operation)
                0: begin
                    exact_result = signed_a + signed_b;
                    unsigned_sum = {1'b0, input_a} + {1'b0, input_b};
                    expected_carry = unsigned_sum[len];
                end
                1: exact_result = signed_a - signed_b;
                2: exact_result = -signed_b;
                3: begin
                    expected_res = signed_a * signed_b;
                    expected_neg = expected_res[2*len-1];
                    expected_zero = (expected_res == 0);
                end
                4: expected_res = input_a & input_b;
                5: expected_res = input_a | input_b;
                // Verilog extends A to the result width before bitwise NOT.
                6: expected_res = ~{{len{1'b0}}, input_a};
                7: expected_res = input_a ^ input_b;
                8: expected_res = {{len{1'b0}}, input_a} << input_b[3:0];
                9: expected_res = {{len{1'b0}}, input_a} >> input_b[3:0];
                default: expected_res = 0;
            endcase

            if (operation <= 2) begin
                wrapped_result = exact_result;
                expected_res = {{len{wrapped_result[len-1]}}, wrapped_result};
                expected_overflow = (exact_result != $signed(expected_res));
                expected_neg = wrapped_result[len-1];
                expected_zero = (expected_res == 0);
            end

            ctrl = operation;
            a = input_a;
            b = input_b;
            #10;

            tests = tests + 1;
            // Case inequality also detects unexpected X or Z values.
            if ({res, carry, overflow, neg, zero} !==
                {expected_res, expected_carry, expected_overflow,
                 expected_neg, expected_zero}) begin
                errors = errors + 1;
                $display("ERROR ctrl=%0d a=%0d b=%0d", operation, signed_a, signed_b);
                $display("  esperado: res=%0d (%b) C=%b V=%b N=%b Z=%b",
                    $signed(expected_res), expected_res, expected_carry,
                    expected_overflow, expected_neg, expected_zero);
                $display("  obtenido: res=%0d (%b) C=%b V=%b N=%b Z=%b",
                    $signed(res), res, carry, overflow, neg, zero);
            end else begin
                $display("OK ctrl=%0d a=%0d b=%0d res=%0d | C=%b V=%b N=%b Z=%b",
                    operation, signed_a, signed_b, $signed(res),
                    carry, overflow, neg, zero);
            end
        end
    endtask
    initial begin
        // Initial values
        a = 0;
        b = 0;
        ctrl = 0;

        // Optional waveform file for simulators such as Icarus Verilog
        // $dumpfile("ALU_TB.vcd");
        // $dumpvars(0, ALU_TB);

        #10;

        $display("============================================");
        $display("SIGNED ARITHMETIC OPERATIONS");
        $display("============================================");

        // Addition
        $display("\n--- ADDITION ---");
        apply_test(4'd0,  5,   3);   //  5 +  3 =  8
        apply_test(4'd0, -5,   2);   // -5 +  2 = -3
        apply_test(4'd0, 15,   1);   // 15 +  1: positive overflow
        apply_test(4'd0, -16, -1);   // -16 + -1: negative overflow
        apply_test(4'd0,  0,   0);   // Zero flag

        // Subtraction
        $display("\n--- SUBTRACTION ---");
        apply_test(4'd1,  7,   3);   //  7 -  3 =  4
        apply_test(4'd1, -8,   3);   // -8 -  3 = -11
        apply_test(4'd1, 15,  -1);   // 15 - (-1): positive overflow
        apply_test(4'd1, -16,  1);   // -16 - 1: negative overflow
        apply_test(4'd1,  5,   5);   // Zero flag

        // Negation of B
        $display("\n--- NEGATION OF B ---");
        apply_test(4'd2,  0,   5);   // -5
        apply_test(4'd2,  0,  -7);   //  7
        apply_test(4'd2,  0,   0);   //  0
        apply_test(4'd2,  0, -16);   // Overflow: +16 does not fit

        // Multiplication
        $display("\n--- MULTIPLICATION ---");
        apply_test(4'd3,  3,   4);   //   12
        apply_test(4'd3, -3,   4);   //  -12
        apply_test(4'd3, -3,  -4);   //   12
        apply_test(4'd3, -16, 15);   // -240
        apply_test(4'd3,  0,   7);   // Zero flag

        $display("\n============================================");
        $display("LOGICAL OPERATIONS");
        $display("============================================");

        // AND
        apply_test(4'd4, 5'b10101, 5'b00111);

        // OR
        apply_test(4'd5, 5'b10101, 5'b00111);

        // NOT A; B is unused
        apply_test(4'd6, 5'b10101, 5'b00000);

        // XOR
        apply_test(4'd7, 5'b10101, 5'b00111);

        $display("\n============================================");
        $display("SHIFT OPERATIONS");
        $display("============================================");

        // Left shifts
        apply_test(4'd8, 5'b00001, 1);
        apply_test(4'd8, 5'b00011, 2);
        apply_test(4'd8, 5'b10001, 4);

        // Logical right shifts
        apply_test(4'd9, 5'b10000, 1);
        apply_test(4'd9, 5'b10100, 2);
        apply_test(4'd9, 5'b11111, 4);

        $display("\n============================================");
        $display("UNKNOWN OPERATIONS");
        $display("============================================");

        apply_test(4'd10, 5, 3);
        apply_test(4'd15, 5, 3);

        $display("\nResumen: %0d pruebas, %0d OK, %0d ERROR", tests, tests-errors, errors);
        $finish;
    end

endmodule