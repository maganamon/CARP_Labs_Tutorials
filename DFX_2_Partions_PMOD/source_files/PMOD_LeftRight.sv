`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module PMOD_LeftRight(
    input logic CLK,
    input logic TICK,
    input logic btnL,
    input logic btnR,
    output logic [3:0] PMOD_LEDS,
    output logic Motor_Pin
    );
    assign Motor_Pin = 1'b0;   // unused motor output tied off
    
    logic [3:0] counter;
    assign PMOD_LEDS = counter;
    
    initial begin
        counter = 4'b0001;
    end
    
    always_ff @(posedge CLK) begin
        if (TICK) begin
           if (counter >= 4'b1000)
                counter <= 4'b0001;
           else
                counter <= counter << 1;
        end
    end
endmodule
