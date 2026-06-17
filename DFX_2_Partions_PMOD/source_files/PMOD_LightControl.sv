`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module PMOD_LightControl(
    input logic CLK,
    input logic TICK,
    input logic btnL,
    input logic btnR,
    output logic [3:0] PMOD_LEDS,
    output logic Motor_Pin
    );
    
    logic [3:0] counter;
    assign PMOD_LEDS = counter;
    
    logic no_motor;
    assign Motor_Pin = no_motor;
    
    initial begin
        counter = 4'b0001;
        no_motor = 0;
    end
    //
    always_ff @(posedge CLK) begin
         if (TICK) begin
            if (btnL && counter != 4'b1000)
                counter <= counter << 1;
            else if (btnR && counter != 4'b0001)
                counter <= counter >> 1;
        end
    end
endmodule
