`timescale 1ns / 1ps
`include "clogb2.v"
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: dotProduct
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module computes the dot-product between input vecotrs A and B.
// Vector A and B have length equal to DIM. 
// The bit-width of an element of A is A_DATA_WIDTH. Similarily, the bit-width of an element
// of B is B_DATA_WIDTH.
// The output, 'Product', is a scalar of bit-width: A_DATA_WIDTH + B_DATA_WIDTH + ceiling(log_2(DIM))
//
//////////////////////////////////////////////////////////////////////////////////

module dotProduct 
    #( parameter DIM=8,
       parameter A_DATA_WIDTH=32,
       parameter B_DATA_WIDTH=32 )
    ( Clock, A, B, DotProduct );                 

    localparam A_WIDTH = DIM*A_DATA_WIDTH;
    localparam B_WIDTH = DIM*B_DATA_WIDTH;
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = A_DATA_WIDTH + B_DATA_WIDTH + EXTRA_ADD_WIDTH; 
    localparam MULT_WIDTH = A_WIDTH + B_WIDTH;  // width of the vector to hold intermediate multiplication of elements
    
    // The clock (used later when the log(DIM) layers of adders is implemented)
    input Clock;
    
    // A and B are input vectors
    input [A_WIDTH-1:0] A;
    input [B_WIDTH-1:0] B;
    
    // C is the scalar output
    output [RES_WIDTH-1:0] DotProduct;

    // Intermediate wire to hold the products of a_i * b_i, where i is an index from 1 to DIM.
    wire [MULT_WIDTH-1:0] mult;
    
    vectorMult #(DIM, A_DATA_WIDTH, B_DATA_WIDTH) uut( .Clock(Clock), .u(A), .v(B), .result(mult) );

    // Naive computation of dot product...we simply sum up the multiplied elements of a and b sequantially
    reg [RES_WIDTH-1:0] s;
    integer i;
    always @(*) begin 
        s = {(RES_WIDTH){1'b0}};
        for( i = 0; i < DIM; i = i + 1 ) begin
            // indexed part-select...
            // identifier[base : width]
            s = s + mult[(MULT_WIDTH * i) +: MULT_WIDTH];
        end  
    end
    
    assign DotProduct = s;      
endmodule
