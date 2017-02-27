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

module noOverflowAdd
    #( parameter WIDTH=32,
       parameter RES_WIDTH=37 )
    ( input Clock,
      input [WIDTH-1:0] a,
      input [WIDTH-1:0] b,
      output [RES_WIDTH-1:0] sum );
   
    // a register to hold the output of (a + b)
    reg [RES_WIDTH-1:0] s;
    // output assignment
    assign sum = s;
    
    // Next state logic
    always @(posedge Clock) begin
        s[RES_WIDTH-1:0] <= a[WIDTH-1:0] + b[WIDTH-1:0];
    end    
endmodule
