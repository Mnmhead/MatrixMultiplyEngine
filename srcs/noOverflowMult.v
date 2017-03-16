`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/24/2017 12:04:27 PM
// Module Name: noOverflowMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module multiplies two terms, a and b, and stores the result in a wire large enough
// to handle any overflow from the multiplication operation. Thus the width of the wire holding the 
// product is of width a_width + b_width. The width of inputs a and b do not have to be equivalent, and 
// each input width is parameterizable.
//
//////////////////////////////////////////////////////////////////////////////////

module noOverflowMult #( 
    parameter W_a=32,
    parameter W_b=32 
) ( 
    input Clock,
    input [W_a-1:0] a,
    input [W_b-1:0] b,
    output [W_a+W_b-1:0] product 
);
    
    wire [W_a+W_b-1:0] p;
    reg [W_a+W_b-1:0] product_reg;
    
    assign product = product_reg;
    
    assign p = a[W_a-1:0] * b[W_b-1:0];
    
    // Next state logic
    always @(posedge Clock) begin
        product_reg <= p;
    end        
endmodule
