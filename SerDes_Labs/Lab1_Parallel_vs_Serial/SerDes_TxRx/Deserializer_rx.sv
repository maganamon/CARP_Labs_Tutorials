`timescale 1ns/1ps

module Deserializer_rx #(
    parameter int WIDTH = 8
) (
    input  logic             rx_clk,
    input  logic             rst,

    input  logic             in_bit,
    input  logic             serial_valid,

    output logic [WIDTH-1:0] parallel_data,
    output logic             VALID
);

    localparam int COUNTER_WIDTH =
        (WIDTH <= 1) ? 1 : $clog2(WIDTH);

    logic [WIDTH-1:0]         saved_data;
    logic [COUNTER_WIDTH-1:0] counter;
    logic word_complete;

    always_ff @(negedge rx_clk) begin
        if (rst) begin
            saved_data    <= '0;
            parallel_data <= '0;
            counter       <= '0;
            word_complete <= 1'b0;
            VALID         <= 1'b0;
        end
        else begin
            // VALID is normally low and pulses for one clock cycle.
            VALID <= 1'b0;

            /*
             * saved_data was completed on the previous falling edge.
             *
             * We copy it now because nonblocking assignments do not
             * update saved_data until after an always_ff block finishes.
             */
            if (word_complete) begin
                parallel_data <= saved_data;
                VALID         <= 1'b1;
                word_complete <= 1'b0;
            end

            /*
             * Sample one incoming serial bit.
             */
            else if (serial_valid) begin
                /*
                 * Right-shift the current contents and insert the new
                 * serial bit into the MSB.
                 *
                 * For WIDTH = 8:
                 *
                 * saved_data = in_bit a b c d e f g
                 */
                saved_data <= {
                    in_bit,
                    saved_data[WIDTH-1:1]
                };

                /*
                 * counter = 0 means the first bit.
                 * counter = WIDTH-1 means the final bit.
                 */
                if (counter == COUNTER_WIDTH'(WIDTH - 1)) begin
                    counter       <= '0;
                    word_complete <= 1'b1;
                end
                else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

endmodule
