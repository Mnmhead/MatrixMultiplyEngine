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

module dotProduct #( 
    parameter DIM=8,
    parameter A_DATA_WIDTH=32,
    parameter B_DATA_WIDTH=32 
) ( 
    Clock, 
    A, 
    B, 
    DotProduct 
);                 

    localparam A_WIDTH = DIM*A_DATA_WIDTH;
    localparam B_WIDTH = DIM*B_DATA_WIDTH;
    localparam MULT_EL_WIDTH = A_DATA_WIDTH + B_DATA_WIDTH;
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = A_DATA_WIDTH + B_DATA_WIDTH + EXTRA_ADD_WIDTH; 
    localparam MULT_WIDTH = A_WIDTH + B_WIDTH;  // width of the vector to hold intermediate multiplication of elements
    
    input Clock;
    
    // A and B are input vectors
    input [A_WIDTH-1:0] A;
    input [B_WIDTH-1:0] B;
    
    // C is the scalar output
    output [RES_WIDTH-1:0] DotProduct;

    // Intermediate reg to hold the products of a_i * b_i, where i is an index from 1 to DIM.
    wire [MULT_WIDTH-1:0] vector_mult_out;
    reg [MULT_WIDTH-1:0] vector_mult;
    vectorMult #(DIM, A_DATA_WIDTH, B_DATA_WIDTH) vm( .Clock(Clock), .u(A), .v(B), .result(vector_mult_out) );

    always @(posedge Clock) begin
        vector_mult <= vector_mult_out;
    end    

    // Instantiate a vectorSum module to sum all elements of the vector of element-wise products (mult).
    wire [RES_WIDTH-1:0] vector_sum_out;
    reg [RES_WIDTH-1:0] vector_sum;
    wire readEn;
    vectorSum #(DIM, MULT_EL_WIDTH) vs( .Clock(Clock), .u(mult), .sum(vector_sum_out), .readEn(readEn) );
    
    always @(posedge Clock) begin
        vector_sum <= vector_sum_out;
    end
    
    // assign output
    assign DotProduct = vector_sum;
endmodule
