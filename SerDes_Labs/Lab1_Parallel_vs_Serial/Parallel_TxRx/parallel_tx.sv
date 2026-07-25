`timescale 1ns/1ps

module parallel_tx #(parameter int WIDTH = 8)
(
    input  logic             tx_clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] parallel_pins
);

    always_ff @(posedge tx_clk) begin
        if (rst)
            parallel_pins <= '0;
        else
            parallel_pins <= data_in;
    end

endmodule
