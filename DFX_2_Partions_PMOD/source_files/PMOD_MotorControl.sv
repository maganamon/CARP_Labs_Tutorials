`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2026 04:46:57 PM
// Design Name: 
// Module Name: PMOD_MotorControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PMOD_MotorControl(
    input logic CLK,
    input logic TICK,
    input logic btnL,
    input logic btnR,
    output logic [3:0] PMOD_LEDS,
    output logic Motor_Pin
    );
    
    initial begin
        PMOD_LEDS = 4'b0000;
        Motor_Pin = 0;
    end
    
    always_ff @(posedge CLK) begin
       if (TICK) begin
            if (btnL) begin
                Motor_Pin = 0;
                PMOD_LEDS = 4'b0000;
            end
            else if (btnR) begin
                Motor_Pin = 1;
                PMOD_LEDS = 4'b1111;
            end
       end
    end
       
endmodule
