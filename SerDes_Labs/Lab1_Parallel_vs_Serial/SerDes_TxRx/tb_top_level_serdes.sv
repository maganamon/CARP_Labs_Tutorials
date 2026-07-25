`timescale 1ns/1ps

module tb_top_level_serdes;

    localparam int  WIDTH        = 8;
    localparam time CLOCK_PERIOD = 10ns;

    logic             CLK;
    logic             RST;
    logic             data_ready;
    logic [WIDTH-1:0] in_data;

    logic             busy;
    logic             serial_data;
    logic [WIDTH-1:0] out_data;
    logic             VALID;

    int tests_passed;
    int tests_failed;

    top_level_serdes #(
        .WIDTH(WIDTH)
    ) dut (
        .CLK        (CLK),
        .RST        (RST),
        .data_ready (data_ready),
        .in_data    (in_data),
        .busy       (busy),
        .serial_data(serial_data),
        .out_data   (out_data),
        .VALID      (VALID)
    );

    /*
     * 100 MHz clock:
     *
     * Period = 10 ns
     */
    always #(CLOCK_PERIOD / 2) begin
        CLK <= ~CLK;
    end

    /*
     * Send one parallel word and verify the complete transfer.
     */
    task automatic send_and_check(
        input logic [WIDTH-1:0] test_value
    );

        logic transaction_failed;

        begin
            transaction_failed = 1'b0;

            /*
             * Wait until the serializer is idle.
             */
            wait (busy === 1'b0);

            /*
             * Apply the next word on a falling edge.
             *
             * This gives the input half a clock period of setup
             * time before the serializer captures it.
             */
            @(negedge CLK);

            in_data    = test_value;
            data_ready = 1'b1;

            /*
             * Serializer captures in_data on this rising edge.
             */
            @(posedge CLK);
            #1ns;

            data_ready = 1'b0;

            if (busy !== 1'b1) begin
                $error(
                    "FAIL: busy did not assert after loading 0x%0h",
                    test_value
                );

                transaction_failed = 1'b1;
            end

            /*
             * Check all WIDTH serial bits.
             *
             * The serializer sends:
             *
             * test_value[0], test_value[1], ..., test_value[WIDTH-1]
             *
             * The receiver samples each one on a falling edge.
             */
            for (
                int bit_index = 0;
                bit_index < WIDTH;
                bit_index++
            ) begin

                @(negedge CLK);
                #1ns;

                if (serial_data !== test_value[bit_index]) begin
                    $error(
                        "FAIL: word 0x%0h, bit %0d: expected %b, got %b",
                        test_value,
                        bit_index,
                        test_value[bit_index],
                        serial_data
                    );

                    transaction_failed = 1'b1;
                end

                /*
                 * With your word_complete implementation, VALID
                 * must remain low during all eight bit samples.
                 */
                if (VALID !== 1'b0) begin
                    $error(
                        "FAIL: VALID asserted too early while receiving ",
                        "bit %0d of word 0x%0h",
                        bit_index,
                        test_value
                    );

                    transaction_failed = 1'b1;
                end
            end

            /*
             * After the eighth falling edge, word_complete is set.
             *
             * On the following rising edge, the serializer clears busy.
             */
            @(posedge CLK);
            #1ns;

            if (busy !== 1'b0) begin
                $error(
                    "FAIL: busy did not clear after transmitting 0x%0h",
                    test_value
                );

                transaction_failed = 1'b1;
            end

            /*
             * On the following falling edge, the deserializer copies
             * saved_data into out_data and asserts VALID.
             */
            @(negedge CLK);
            #1ns;

            if (VALID !== 1'b1) begin
                $error(
                    "FAIL: VALID did not assert for word 0x%0h",
                    test_value
                );

                transaction_failed = 1'b1;
            end

            if (out_data !== test_value) begin
                $error(
                    "FAIL: sent 0x%0h, received 0x%0h",
                    test_value,
                    out_data
                );

                transaction_failed = 1'b1;
            end

            if (transaction_failed) begin
                tests_failed++;

                $display(
                    "TRANSACTION FAILED: sent 0x%0h, received 0x%0h",
                    test_value,
                    out_data
                );
            end
            else begin
                tests_passed++;

                $display(
                    "TRANSACTION PASSED: sent 0x%0h, received 0x%0h",
                    test_value,
                    out_data
                );
            end

            /*
             * VALID should return low on the next falling edge.
             */
            @(negedge CLK);
            #1ns;

            if (VALID !== 1'b0) begin
                $error(
                    "FAIL: VALID did not return low after word 0x%0h",
                    test_value
                );

                tests_failed++;
            end
        end

    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_level_serdes);

        CLK          = 1'b0;
        RST          = 1'b1;
        data_ready   = 1'b0;
        in_data      = '0;
        tests_passed = 0;
        tests_failed = 0;

        /*
         * The serializer resets on a rising edge.
         * The deserializer resets on a falling edge.
         *
         * Keep reset active long enough for both.
         */
        repeat (3) @(posedge CLK);
        @(negedge CLK);
        #1ns;

        if (busy !== 1'b0) begin
            $error(
                "FAIL: busy should be 0 during reset, got %b",
                busy
            );

            tests_failed++;
        end

        if (VALID !== 1'b0) begin
            $error(
                "FAIL: VALID should be 0 during reset, got %b",
                VALID
            );

            tests_failed++;
        end

        if (serial_data !== 1'b0) begin
            $error(
                "FAIL: serial_data should be 0 during reset, got %b",
                serial_data
            );

            tests_failed++;
        end

        if (out_data !== '0) begin
            $error(
                "FAIL: out_data should be zero during reset, got 0x%0h",
                out_data
            );

            tests_failed++;
        end

        /*
         * Release reset on a falling edge, away from the
         * serializer's active rising edge.
         */
        RST = 1'b0;

        /*
         * Directed tests.
         */
        send_and_check(8'h00);
        send_and_check(8'h01);
        send_and_check(8'h80);
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'hA5);
        send_and_check(8'h5A);
        send_and_check(8'hFF);

        /*
         * Pseudorandom tests.
         */
        repeat (20) begin
            send_and_check(
                WIDTH'($urandom())
            );
        end

        $display("");
        $display("----------------------------------------");
        $display("LAB 1 SERIAL LINK TEST SUMMARY");
        $display("Transactions passed: %0d", tests_passed);
        $display("Errors detected:     %0d", tests_failed);
        $display("----------------------------------------");

        if (tests_failed == 0) begin
            $display("LAB 1 SERIAL LINK TEST PASSED");
        end
        else begin
            $fatal(
                1,
                "LAB 1 SERIAL LINK TEST FAILED WITH %0d ERROR(S)",
                tests_failed
            );
        end

        $finish;
    end

    /*
     * Simulation timeout in case the serializer or receiver
     * becomes stuck.
     */
    initial begin
        #100us;
        $fatal(1, "Simulation timeout");
    end

endmodule
