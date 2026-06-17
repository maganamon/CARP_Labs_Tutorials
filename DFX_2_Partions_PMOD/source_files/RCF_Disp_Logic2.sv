`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Rudy
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module RCF_Disp_Logic3(
    input  logic CLK,
    input  logic RST,
    input logic TICK,
    output logic [15:0] DATA_OUT,
    output logic MODE_OUT
    );
    
    logic [15:0]counter;
    assign MODE_OUT = 1;
    
    assign DATA_OUT = counter;
    
    initial begin
        counter = 16'd0;
    end
    
    always_ff @(posedge CLK) begin
        if (TICK || RST) begin
            if (RST || counter >= 16'd9999)
                counter <= 16'd0;
            else
                counter <= counter + 1;
        end
    end
endmodule
