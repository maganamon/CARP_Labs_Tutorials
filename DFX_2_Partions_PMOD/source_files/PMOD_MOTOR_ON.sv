`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Rudy 
//////////////////////////////////////////////////////////////////////////////////


module PMOD_MOTOR_ON(
    input logic CLK,
    input logic TICK,
    input logic btnL,
    input logic btnR,
    output logic [3:0] PMOD_LEDS,
    output logic Motor_Pin
    );
    
    logic [3:0] leds;
    assign PMOD_LEDS = leds;
    assign leds = 4'b1000;
    assign Motor_Pin = 1;
    
endmodule
