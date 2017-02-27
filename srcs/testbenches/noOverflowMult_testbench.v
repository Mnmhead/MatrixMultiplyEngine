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
        
    // Begin testing different inputs
    integer i;
    integer j;
    localparam max_a = 255;  // why cant I use (1<<W_a)-1? For some reason the localparam always evaluates to 0
    localparam max_b = 255;
    initial begin  
        // Initialize inputs
        a = 0;
        b = 0;
        
        // pause for 100 ns
        #100;
        
        // Run the module on every combination of inputs.
        // Display an error and exit if an incorrect result is produced.
        for( i = 0; i < max_a; i = i + 1 ) begin
            a = i;   
            for( j = 0; j < max_b; j = j + 1 ) begin
                b= j; #(2*CLOCK_PERIOD);  // wait 2 clock periods (for readablility in simulation)
    
                // Abort the simulation and display an error if an 
                // unexpected value is produced.
                if( product != (i*j)) begin
                    $display( "Error: incorrect product" );
                    $finish;
                end
            end
        end  
    end 
endmodule
