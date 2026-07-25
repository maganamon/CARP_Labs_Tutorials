`timescale 1ns/1ps

module tb_top_level_parallel;

    localparam int WIDTH = 8;

    logic             CLK;
    logic             RST;
    logic [WIDTH-1:0] in_data;
    logic [WIDTH-1:0] out_data;
    logic             VALID;

    int tests_passed;
    int tests_failed;

     initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_level_parallel);
    end

    top_level_parallel #(
        .WIDTH(WIDTH)
    ) dut (
        .CLK     (CLK),
        .RST     (RST),
        .in_data (in_data),
        .out_data(out_data),
        .VALID   (VALID)
    );

    // 100 MHz clock:
    // Period = 10 ns
    always #5ns CLK <= ~CLK;

    task automatic send_and_check(
        input logic [WIDTH-1:0] test_value
    );
        begin
            /*
             * Falling edge:
             * Apply the next input word.
             *
             * Rising edge:
             * parallel_tx captures in_data.
             *
             * Following falling edge:
             * parallel_rx captures transit_data and asserts VALID.
             */

            @(negedge CLK);
            in_data = test_value;

            @(posedge CLK);
            @(negedge CLK);

            // Allow nonblocking assignments in parallel_rx to complete.
            #1ns;

            if (VALID !== 1'b1) begin
                $error(
                    "FAIL: VALID was not asserted for input 0x%02h",
                    test_value
                );

                tests_failed++;
            end
            else if (out_data !== test_value) begin
                $error(
                    "FAIL: sent 0x%02h, received 0x%02h",
                    test_value,
                    out_data
                );

                tests_failed++;
            end
            else begin
                $display(
                    "PASS: VALID=%b, sent 0x%02h, received 0x%02h",
                    VALID,
                    test_value,
                    out_data
                );

                tests_passed++;
            end
        end
    endtask

    initial begin
        CLK          = 1'b0;
        RST          = 1'b1;
        in_data      = '0;
        tests_passed = 0;
        tests_failed = 0;

        /*
         * The receiver resets on a falling edge, so wait for one before
         * checking its reset outputs.
         */
        @(negedge CLK);
        #1ns;

        if (VALID !== 1'b0) begin
            $error(
                "FAIL: VALID should be 0 during reset, but was %b",
                VALID
            );

            tests_failed++;
        end
        else begin
            $display("PASS: VALID is 0 during reset.");
            tests_passed++;
        end

        if (out_data !== '0) begin
            $error(
                "FAIL: out_data should be 0 during reset, but was 0x%02h",
                out_data
            );

            tests_failed++;
        end
        else begin
            $display("PASS: out_data is 0 during reset.");
            tests_passed++;
        end

        // Keep reset active for a few additional clock cycles.
        repeat (2) @(posedge CLK);

        // Deassert reset away from the TX rising edge.
        @(negedge CLK);
        RST = 1'b0;

        send_and_check(8'h00);
        send_and_check(8'h01);
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'hA5);
        send_and_check(8'h5A);
        send_and_check(8'hFF);

        // Test additional random values.
        repeat (20) begin
            send_and_check(
                WIDTH'($urandom())
            );
        end

        $display("--------------------------------");
        $display("Tests passed: %0d", tests_passed);
        $display("Tests failed: %0d", tests_failed);
        $display("--------------------------------");

        if (tests_failed == 0) begin
            $display("LAB 1 PARALLEL LINK TEST PASSED");
        end
        else begin
            $fatal(
                1,
                "LAB 1 PARALLEL LINK TEST FAILED WITH %0d ERROR(S)",
                tests_failed
            );
        end

        $finish;
    end

    // Prevent an endless simulation.
    initial begin
        #10us;
        $fatal(1, "Simulation timeout");
    end

endmodule
