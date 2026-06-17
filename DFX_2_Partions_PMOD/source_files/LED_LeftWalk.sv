`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 04:04:27 PM
// Design Name: 
// Module Name: reconfig_LEDS
//////////////////////////////////////////////////////////////////////////////////


module LED_LeftWalk(
    input  logic CLK,
    input  logic btnC, // Reset
    input logic TICK,
    output logic [15:0] LEDS
    );

    logic RST;
    assign RST = btnC;

    logic [15:0] leds;
    assign LEDS = leds;
    
    initial begin
        leds = 16'd1;
    end
    
    always_ff @(posedge CLK)
        if (RST || TICK) begin
            if (leds >= 16'h8000 || RST)
                leds <= 16'd1;
            else
                leds <= leds << 1;
        end

endmodule