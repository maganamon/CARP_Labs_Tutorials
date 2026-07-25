`timescale 1ns/1ps

module top_level_serdes #(
    parameter int WIDTH = 8
) (
    input  logic             CLK,
    input  logic             RST,

    // Parallel transmitter-side interface
    input  logic             data_ready,
    input  logic [WIDTH-1:0] in_data,

    // Status and reconstructed receiver data
    output logic             busy,
    output logic             serial_data,
    output logic [WIDTH-1:0] out_data,
    output logic             VALID
);

    /*
     * One-bit serial connection between the transmitter
     * and receiver.
     *
     * serial_data is also exposed as an output so that it
     * can be viewed easily in GTKWave.
     */

    Serializer_tx #(
        .WIDTH(WIDTH)
    ) serializer_inst (
        .tx_clk       (CLK),
        .rst          (RST),
        .data_ready   (data_ready),
        .parallel_data(in_data),
        .busy         (busy),
        .out_bit      (serial_data)
    );

    /*
     * The serializer updates serial_data on rising edges.
     * The deserializer samples it on falling edges.
     *
     * busy remains high for the complete serialized word,
     * so it is used as serial_valid.
     */
    Deserializer_rx #(
        .WIDTH(WIDTH)
    ) deserializer_inst (
        .rx_clk       (CLK),
        .rst          (RST),
        .in_bit       (serial_data),
        .serial_valid (busy),
        .parallel_data(out_data),
        .VALID        (VALID)
    );

endmodule
