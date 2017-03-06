`timescale 1ns / 1ps 
// `include "clogb2.v" // vivado can't find this for some reason
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: dotProduct_testbench
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module serves as a testbench for the dotProduct module.
//
//////////////////////////////////////////////////////////////////////////////////

module dotProduct_testbench();
    localparam DIM = 10;
    localparam A_DATA_WIDTH = 16;
    localparam B_DATA_WIDTH = 16;
    localparam EXTRA_ADD_WIDTH =  4;    //`CLOG2(DIM); // this isnt working for now...
    localparam RES_WIDTH = A_DATA_WIDTH + B_DATA_WIDTH + EXTRA_ADD_WIDTH;
    
    reg Clock;
    reg [(A_DATA_WIDTH*DIM)-1:0] A;
    reg [(B_DATA_WIDTH*DIM)-1:0] B;
    wire [RES_WIDTH-1:0] DotProduct;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // unit under test
    dotProduct #(DIM, A_DATA_WIDTH, B_DATA_WIDTH) uut(.Clock(Clock), .A(A), .B(B), .DotProduct(DotProduct));    
    
    // Try silly input case
    initial begin  
        // Initialize inputs
        A = 0;
        B = 0;
        
        // pause for 100 ns
        #100;  
        // Run the module on every combination of two 8-bit inputs.
        // Displays an error if an incorrect result is produced.
        
        A = 160'b0000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000;
        B = 160'b0000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000;
        @(posedge Clock);
        @(posedge Clock);
        @(posedge Clock);
        @(posedge Clock);
        
        // (8^2) * 10 = 640
        
        #100;
    end 
endmodule
