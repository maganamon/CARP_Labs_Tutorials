`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Rudy
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module RCF_Disp_Logic1(
    input  logic CLK,
    input  logic RST,
    input logic TICK,
    output logic [15:0] DATA_OUT,
    output logic MODE_OUT
    );
    
    localparam logic [15:0] COOL = 16'hc001;
    localparam logic [15:0] DOOD = 16'hD00D;
    localparam logic [15:0] BEEF = 16'hBEEF;
    localparam logic [15:0] CAFE = 16'hCAFE;
    logic [1:0]counter;
    assign MODE_OUT = 0;
    
    initial begin
        counter = 2'd0;
    end
    
    always_ff @(posedge CLK) begin
        if (TICK || RST) begin
            if (RST || counter == 2'b11) begin
                counter <= 2'b00;
            end
            else
                counter <=  counter + 1;
            case(counter)
                2'b00: DATA_OUT <= COOL;
                2'b01: DATA_OUT <= DOOD;
                2'b10: DATA_OUT <= BEEF;
                2'b11: DATA_OUT <= CAFE;
                default: DATA_OUT <= 16'h0;
            endcase
       end
    end
endmodule
