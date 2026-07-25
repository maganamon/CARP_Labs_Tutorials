`timescale 1ns/1ps

module Serializer_tx #(
    parameter int WIDTH = 8
) (
    input  logic             tx_clk,
    input  logic             rst,
    input  logic             data_ready,
    input  logic [WIDTH-1:0] parallel_data,

    output logic             busy,
    output logic             out_bit
);

    localparam int COUNTER_WIDTH =
        (WIDTH <= 1) ? 1 : $clog2(WIDTH);

    logic [COUNTER_WIDTH-1:0] counter;
    logic [WIDTH-1:0]         loaded_data;

    // Send the least-significant bit first.
    assign out_bit = busy ? loaded_data[0] : 1'b0;

    always_ff @(posedge tx_clk) begin
        if (rst) begin
            loaded_data <= '0;
            counter     <= '0;
            busy        <= 1'b0;
        end
        else begin
            /*
             * Load a new parallel word only when the serializer
             * is currently idle.
             */
            if (data_ready && !busy) begin
                loaded_data <= parallel_data;
                counter     <= '0;
                busy        <= 1'b1;
            end

            /*
             * Shift one bit during each clock cycle.
             */
            else if (busy) begin
                if (counter == COUNTER_WIDTH'(WIDTH - 1)) begin
                    /*
                     * The final bit was presented during the
                     * clock cycle that just finished.
                     */
                    loaded_data <= '0;
                    counter     <= '0;
                    busy        <= 1'b0;
                end
                else begin
                    loaded_data <= loaded_data >> 1;
                    counter     <= counter + 1'b1;
                end
            end
        end
    end

endmodule
