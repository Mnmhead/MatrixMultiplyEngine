`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: vectorMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module multiplies the elements of two vectors, u and v, to produce a resulting vector 
// of the same dimensions as u and v. 
//
//////////////////////////////////////////////////////////////////////////////////

module vectorMult_testbench();
    localparam DIM = 10;
    localparam W_v = 8;  // represents the bit-width of input a
    localparam W_u = 8;  // represents the bit-width of input b
    reg Clock;
    reg [(W_u*DIM)-1:0] u;
    reg [(W_v*DIM)-1:0] v;
    wire [((W_u+W_v)*DIM)-1:0] result;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // Unit Under Test
    vectorMult #(DIM, W_u, W_v) uut( .Clock(Clock), .u(u), .v(v), .result(result) );
    
    initial begin  
        // Initialize inputs
        u = 0;
        v = 0;
        // pause for 100 ns
        #20;
		  //u = [8,8,8,8,8,8,8,8,8,8]
        u = 80'b00001000000010000000100000001000000010000000100000001000000010000000100000001000;
        //u = [1,2,3,4,5,6,7,8,9,10]
        v = 80'b00000001000000100000001100000100000001010000011000000111000010000000100100001010;
        
        #10;
        
        //u = [16,16,....,16]
        u = 80'b00010000000100000001000000010000000100000001000000010000000100000001000000010000;
        //u = [1,2,3,4,5,6,7,8,9,10]
        v = 80'b00000001000000100000001100000100000001010000011000000111000010000000100100001010;
               
        #30;
    end 
endmodule
