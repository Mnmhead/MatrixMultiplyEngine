`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/27/2017 12:31:27 PM
// Module Name: noOverflowAdd
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module adds two terms, a and b, and stores the result in a wire large enough
// to handle any overflow from the operation. The width of the input and the width of 
// the result are parametrizable; therefore, it is up to the user to correctly instantiate
// this module as to prevent any oveflow. The width of inputs a and b must be equivalent.
//
//////////////////////////////////////////////////////////////////////////////////

module noOverflowAdd_testbench();
   localparam WIDTH = 8;
   localparam RES_WIDTH = 11; // we will want the CLOG2 macro here
    // RES_WIDTH = WIDTH + CLOG2(WIDTH);

   reg Clock;
   reg [WIDTH-1:0] a;
   reg [WIDTH-1:0] b;
   wire [RES_WIDTH-1:0] sum;  

   // Set up the clock
   parameter CLOCK_PERIOD=10;
   initial Clock=1;
   always begin
      #(CLOCK_PERIOD/2);
      Clock = ~Clock;
   end 

   // Unit Under Test
   noOverflowAdd #(WIDTH, RES_WIDTH) uut( .Clock(Clock), .a(a), .b(b), .sum(sum) );
   
   integer i;
   integer j;
   initial begin
      // Initialize inputs
      a = 0;
      b = 0;

      // pause for 100ns
      #100;

      // Run the module on a large combination of inputs
      for( i = 255; i >= 0; i = i - 11 ) begin
         a = i;
         for( j = 255; j >= 0; j = j - 1) begin    
            b = j; #(2*CLOCK_PERIOD);  // wait 2 clock cycles (for readability in simulation)

            // Abort the simulation and display an error if an 
            // unexpected value is produced.
            if( sum != (i+j)) begin
               $display( "Error: Incorrect sum" );
               $finish;
            end 
         end 
      end 
   end 
endmodule
