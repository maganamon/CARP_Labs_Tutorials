`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rudy
// Create Date: 05/30/2026 04:29:45 PM
// Design Name: 
// Module Name: STATIC_TOP
//////////////////////////////////////////////////////////////////////////////////


module STATIC_TOP(
    input logic CLK,
    input logic BTNC,
    input logic BTNL,
    input logic BTNR,
    output logic [15:0] LEDS,
    output logic [3:0] P_LEDS,
    output logic MOTOR_PIN,
    output logic [7:0] CATHODES,
    output logic [3:0] ANODES
    );
    
    
    
logic OneSec_TICK;
logic HalfSec_TICK;
logic RST;
assign RST = BTNC;

// tick gen to simulate a tick every 1 second (enable)
tick_generator STATIC_1SEC_TICK(
    .clk(CLK),
    .rst(RST),
    .tick(OneSec_TICK)
);

tick_generator #(.MAX_COUNT(25_000_000)) STATIC_HALFSEC_TICK(
    .clk(CLK),
    .rst(RST),
    .tick(HalfSec_TICK)
);

    // ******** RECONGIG START ******** //
    //It's just a 'walking' led. left shift by 1
LED_LeftWalk RECONFIG_LEDS(
    .CLK(CLK), //1 sec clk
    .btnC(BTNC), // Reset
    .TICK(HalfSec_TICK),
    .LEDS(LEDS)
    );
    
PMOD_LeftRight RECONFIG_PMOD(
    .CLK(CLK), //1 sec clk
    .TICK(HalfSec_TICK),
    .btnL(BTNL),
    .btnR(BTNR),
    .PMOD_LEDS(P_LEDS),
    .Motor_Pin(MOTOR_PIN)
    );
        // ******** RECONGIG END ******** //
        
// // Proof that Basys3 is still alive.
    logic [15:0] rcf_data;
    logic rcf_mode;
    
RCF_Disp_Logic3 u_rcf_disp_logic (
    .CLK(CLK), // 1 sec clk
    .RST(BTNC),
    .TICK(OneSec_TICK),
    .DATA_OUT(rcf_data),
    .MODE_OUT(rcf_mode)
);

SevSegDisp SSEG_DISP(
    .CLK(CLK),
    .MODE(rcf_mode),// 0 - Hex, 1 - Decimal
    .DATA_IN(rcf_data),
    .CATHODES(CATHODES),
    .ANODES(ANODES)
    );
    
endmodule