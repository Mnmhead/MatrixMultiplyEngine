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
    parameter B_DATA_WIDTH=32,
    parameter RES_WIDTH=67 
) ( 
    Clock,
    start, 
    A, 
    B, 
    DotProduct,
    readEn
);                 

    // Helpful 'local constants'
    //localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam MULT_VECTOR_WIDTH = DIM*(A_DATA_WIDTH + B_DATA_WIDTH);  // width of the vector to hold intermediate multiplication of elements
    
    
    // Inputs
    input Clock;
    input [DIM*A_DATA_WIDTH-1:0] A;  // vector A
    input [DIM*B_DATA_WIDTH-1:0] B;  // vector B
    input start;  // single bit, signals to start the dot_product operation

    
    // Outputs
    output [RES_WIDTH-1:0] DotProduct;  // The scalar output
    output readEn;  // single bit, signals a valid dot-product

    
    // Start and readEn logic
    reg [DIM*A_DATA_WIDTH-1:0] A_vec;
    reg [DIM*B_DATA_WIDTH-1:0] B_vec;
    always @(posedge Clock) begin
        if( start ) begin
            A_vec <= A;
            B_vec <= B;
        end
    end
    localparam FINISH_DELAY = DIM + 5; // DIM shifts in vectorSum + 5 extra shifts for the pipelining within this module
    nRegisterChain #(FINISH_DELAY, 1) readEnShift( .Clock(Clock),
                                                   .in(start),
                                                   .out(readEn) 
                                                 );


    // Intermediate reg to hold the products of a_i * b_i, where i is an index from 1 to DIM.
    wire [MULT_VECTOR_WIDTH-1:0] vector_mult_out;
    reg [MULT_VECTOR_WIDTH-1:0] vector_mult;
    vectorMult #(DIM, A_DATA_WIDTH, B_DATA_WIDTH) vm( .Clock(Clock), .u(A_vec), .v(B_vec), .result(vector_mult_out) );
    // Assign output of vector mult
    always @(posedge Clock) begin
        vector_mult <= vector_mult_out;
    end    


    // Instantiate a vectorSum module to sum all elements of the result of vectorMult.
    wire [RES_WIDTH-1:0] vector_sum_out;
    reg [RES_WIDTH-1:0] vector_sum;
    wire readEn;
    vectorSum #(DIM, A_DATA_WIDTH + B_DATA_WIDTH, RES_WIDTH) vs( .Clock(Clock), .u(vector_mult), .sum(vector_sum_out) );
 
 
    // Assign Output
    always @(posedge Clock) begin
        vector_sum <= vector_sum_out;
    end
    assign DotProduct = vector_sum;
endmodule
