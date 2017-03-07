`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/24/2017 12:04:27 PM
// Module Name: noOverflowMult_testbench
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module exists as a testbench for the noOverflowMult module.
//      Optimal simulation time is 100 + 30*(max_a*max_b) to cover all inputs.
//
//////////////////////////////////////////////////////////////////////////////////

module noOverflowMult_testbench();
    localparam W_a = 8;  // represents the bit-width of input a
    localparam W_b = 8;  // represents the bit-width of input b
    reg Clock;
    reg [W_a-1:0] a;
    reg [W_b-1:0] b;
    wire [(W_a+W_b)-1:0] product;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // Unit Under Test
    noOverflowMult #(W_a, W_b) uut( .Clock(Clock), .a(a), .b(b), .product(product) );
        
    initial begin  
         // Initialize inputs
         // pause for 100 ns
         #100;
         a = 0;
         b = 0;
                                               @(posedge Clock);
         a = 255; b = 255;                     @(posedge Clock);
         a = 17;  b = 99;                      @(posedge Clock);
         a = 178; b = 78;                      @(posedge Clock);
         a = 222; b = 0;                       @(posedge Clock);
         a = 1;   b = 3;                       @(posedge Clock);
         a = 10;  b = 10;                      @(posedge Clock);
         a = 69;  b = 69;                      @(posedge Clock);
                                               @(posedge Clock);
                                               @(posedge Clock);
                                               @(posedge Clock);  
    end 
endmodule
