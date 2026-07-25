`timescale 1ns/1ps

module parallel_rx #(parameter int WIDTH = 8)
(
    input  logic             rx_clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] parallel_pins,
    output logic [WIDTH-1:0] data_out,
    output logic             data_valid
);

    always_ff @(negedge rx_clk) begin
        if (rst) begin
            data_out   <= '0;
            data_valid <= 1'b0;
        end else begin
            data_out   <= parallel_pins;
            data_valid <= 1'b1;
        end
    end

endmodule
