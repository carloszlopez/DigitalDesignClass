`timescale 1ns/1ps

module ALU_tb;

    parameter len = 5;

    // Inputs applied to the ALU
    reg [len-1:0] a;
    reg [len-1:0] b;
    reg [3:0] ctrl;

    // Outputs produced by the ALU
    wire [2*len-1:0] res;
    wire carry;
    wire overflow;
    wire neg;
    wire zero;

    integer tests;
    integer errors;

    // Device under test
    ALU #(.len(len)) dut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .res(res),
        .carry(carry),
        .overflow(overflow),
        .neg(neg),
        .zero(zero)
    );

    task apply_test;
        input [3:0] operation;
        input [len-1:0] input_a;
        input [len-1:0] input_b;

        reg signed [2*len-1:0] signed_a;
        reg signed [2*len-1:0] signed_b;
        reg signed [2*len-1:0] exact_result;
        reg signed [len-1:0] wrapped_result;
        reg [len:0] unsigned_sum;

        reg [2*len-1:0] expected_res;
        reg expected_carry;
        reg expected_overflow;
        reg expected_neg;
        reg expected_zero;

        begin
            signed_a = $signed(input_a);
            signed_b = $signed(input_b);

            exact_result      = 0;
            wrapped_result    = 0;
            unsigned_sum      = 0;
            expected_res      = 0;
            expected_carry    = 0;
            expected_overflow = 0;
            expected_neg      = 0;
            expected_zero     = 0;

            case (operation)
                // Signed addition
                4'd0: begin
                    exact_result = signed_a + signed_b;
                    unsigned_sum =
                        {1'b0, input_a} + {1'b0, input_b};
                    expected_carry = unsigned_sum[len];
                end

                // Signed subtraction
                4'd1: exact_result = signed_a - signed_b;

                // Two's-complement negation of B
                4'd2: exact_result = -signed_b;

                // Full-width signed multiplication
                4'd3: begin
                    expected_res  = signed_a * signed_b;
                    expected_neg  = expected_res[2*len-1];
                    expected_zero = (expected_res == 0);
                end

                // Bitwise operations
                4'd4: expected_res = input_a & input_b;
                4'd5: expected_res = input_a | input_b;

                // Match the ALU assignment: res = ~a.
                4'd6: expected_res = ~{{len{1'b0}}, input_a};

                4'd7: expected_res = input_a ^ input_b;

                // Shifts
                4'd8: expected_res =
                    {{len{1'b0}}, input_a} << input_b[3:0];

                4'd9: expected_res =
                    {{len{1'b0}}, input_a} >> input_b[3:0];

                default: expected_res = 0;
            endcase

            // Addition, subtraction, and negation use a len-bit result
            // extended to the full output width.
            if (operation <= 4'd2) begin
                wrapped_result = exact_result;

                expected_res =
                    {{len{wrapped_result[len-1]}}, wrapped_result};

                expected_overflow =
                    (exact_result != $signed(expected_res));

                expected_neg  = wrapped_result[len-1];
                expected_zero = (expected_res == 0);
            end

            // Apply inputs and wait for the combinational ALU.
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

                if (operation <= 4'd3) begin
                    $display(
                        "ERROR ctrl=%0d a=%0d b=%0d",
                        operation, signed_a, signed_b
                    );
                    $display(
                        "  expected: res=%0d C=%b V=%b N=%b Z=%b",
                        $signed(expected_res), expected_carry,
                        expected_overflow, expected_neg, expected_zero
                    );
                    $display(
                        "  actual:   res=%0d C=%b V=%b N=%b Z=%b",
                        $signed(res), carry, overflow, neg, zero
                    );
                end else begin
                    $display(
                        "ERROR ctrl=%0d a=%b b=%b",
                        operation, input_a, input_b
                    );
                    $display(
                        "  expected: res=%b C=%b V=%b N=%b Z=%b",
                        expected_res, expected_carry,
                        expected_overflow, expected_neg, expected_zero
                    );
                    $display(
                        "  actual:   res=%b C=%b V=%b N=%b Z=%b",
                        res, carry, overflow, neg, zero
                    );
                end

            end else if (operation <= 4'd3) begin
                $display(
                    "OK ctrl=%0d a=%0d b=%0d res=%0d | C=%b V=%b N=%b Z=%b",
                    operation, signed_a, signed_b, $signed(res),
                    carry, overflow, neg, zero
                );
            end else begin
                $display(
                    "OK ctrl=%0d a=%b b=%b res=%b | C=%b V=%b N=%b Z=%b",
                    operation, input_a, input_b, res,
                    carry, overflow, neg, zero
                );
            end
        end
    endtask

    initial begin
        tests = 0;
        errors = 0;
        a = 0;
        b = 0;
        ctrl = 0;
        #10;

        // Part A: logic and shifts, displayed in binary
        $display("\n=== PART A: LOGIC AND SHIFT OPERATIONS ===");

        $display("\n--- AND ---");
        apply_test(4'd4, 5'b10101, 5'b00111);
        apply_test(4'd4, 5'b00000, 5'b11111);

        $display("\n--- OR ---");
        apply_test(4'd5, 5'b10101, 5'b00111);

        $display("\n--- NOT A ---");
        apply_test(4'd6, 5'b10101, 5'b00000);

        $display("\n--- XOR ---");
        apply_test(4'd7, 5'b10101, 5'b00111);
        apply_test(4'd7, 5'b11111, 5'b11111);

        $display("\n--- LEFT SHIFT ---");
        apply_test(4'd8, 5'b00001, 1);
        apply_test(4'd8, 5'b00011, 2);
        apply_test(4'd8, 5'b10001, 4);

        $display("\n--- RIGHT SHIFT ---");
        apply_test(4'd9, 5'b10000, 1);
        apply_test(4'd9, 5'b10100, 2);
        apply_test(4'd9, 5'b11111, 4);

        // Part B: arithmetic, displayed as signed decimal
        $display("\n=== PART B: SIGNED ARITHMETIC OPERATIONS ===");

        $display("\n--- ADDITION ---");
        apply_test(4'd0,   5,   3);
        apply_test(4'd0,  -5,   2);
        apply_test(4'd0,  15,   1);  // Positive overflow
        apply_test(4'd0, -16,  -1);  // Negative overflow
        apply_test(4'd0,   0,   0);  // Zero result

        $display("\n--- SUBTRACTION ---");
        apply_test(4'd1,   7,   3);
        apply_test(4'd1,  -8,   3);
        apply_test(4'd1,  15,  -1);  // Positive overflow
        apply_test(4'd1, -16,   1);  // Negative overflow
        apply_test(4'd1,   5,   5);  // Zero result

        $display("\n--- NEGATION OF B ---");
        apply_test(4'd2,   0,   5);
        apply_test(4'd2,   0,  -7);
        apply_test(4'd2,   0,   0);
        apply_test(4'd2,   0, -16);  // Negation overflow

        $display("\n--- MULTIPLICATION ---");
        apply_test(4'd3,   3,   4);
        apply_test(4'd3,  -3,   4);
        apply_test(4'd3,  -3,  -4);
        apply_test(4'd3, -16,  15);
        apply_test(4'd3,   0,   7);

        $display(
            "\nSummary: %0d tests, %0d passed, %0d failed",
            tests, tests - errors, errors
        );

        $stop;
    end

endmodule