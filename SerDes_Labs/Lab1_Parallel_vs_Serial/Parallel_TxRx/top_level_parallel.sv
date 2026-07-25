`timescale 1ns/1ps

module top_level_parallel #(
    parameter int WIDTH = 8
) (
    input  logic             CLK,
    input  logic             RST,
    input  logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data,
    output logic VALID
);

    logic [WIDTH-1:0] transit_data;

    parallel_tx #(.WIDTH(WIDTH)) test_parallel_tx (
        .tx_clk       (CLK),
        .rst          (RST),
        .data_in      (in_data),
        .parallel_pins(transit_data)
    );

    parallel_rx #(.WIDTH(WIDTH)) test_parallel_rx (
        .rx_clk       (CLK),
        .rst          (RST),
        .parallel_pins(transit_data),
        .data_out     (out_data),
        .data_valid   (VALID)
    );

endmodule
