/* Copyright (c) Gyorgy Wyatt Muntean 2017
 *
 * This module computes the dot-product between input vecotrs A and B.
 * Vector A and B have length equal to DIM. 
 * The bit-width of an element of A is A_DATA_WIDTH. Similarily, the bit-width of an element
 * of B is B_DATA_WIDTH.
 * The output, 'Product', is a scalar of bit-width: A_DATA_WIDTH + B_DATA_WIDTH + ceiling(log_2(DIM))
 */
 
`timescale 1ns / 10ps
`include "clogb2.v"
module dot_product #( parameter DIM=8,
                      parameter A_DATA_WIDTH=32,
                      parameter B_DATA_WIDTH=32 )
                   ( Clock, A, B, DotProduct );                 

    localparam A_WIDTH = DIM*A_DATA_WIDTH;
    localparam B_WIDTH = DIM*B_DATA_WIDTH;
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = A_DATA_WIDTH + B_DATA_WIDTH + EXTRA_ADD_WIDTH; 
    localparam MULT_WIDTH = DIM*RES_WIDTH;  // width of the vector to hold intermediate multiplication of elements
    
    // The clock (used later when the log(DIM) layers of adders is implemented)
    input Clock;
    
    // A and B are input vectors
    input [A_WIDTH-1:0] A;
    input [B_WIDTH-1:0] B;
    
    // C is the scalar output
    output [RES_WIDTH-1:0] DotProduct;

    // Naive computation of dot product...
    reg [RES_WIDTH-1:0] s;
    integer i;
    always @(*) begin 
        s = {(RES_WIDTH){1'b0}};
        for( i = 0; i < DIM; i = i + 1 ) begin
            // indexed part-select...
            // identifier[base : width]
            s = s + (A[(A_DATA_WIDTH * i) +: A_DATA_WIDTH] * B[(B_DATA_WIDTH * i) +: B_DATA_WIDTH]);
        end  
    end
    
    assign DotProduct = s;
    
    // Intermediate wire to hold the products of a_i * b_i, where i is index from 1 to DIM.
    
    reg [MULT_WIDTH-1:0] mult;
    
    integer j;
    always @(*) begin 
        for( j = 0; j < DIM; j = j + 1 ) begin
            mult[ (RES_WIDTH * j) +: RES_WIDTH] = A[(A_DATA_WIDTH * i) +: A_DATA_WIDTH] * B[(B_DATA_WIDTH * i) +: B_DATA_WIDTH];
        end
    end
        
endmodule

/*
 * This module serves as a testbench for the dot_product module
 */
module dot_product_testbench();
    localparam DIM = 10;
    localparam A_DATA_WIDTH = 16;
    localparam B_DATA_WIDTH = 16;
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
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
    dot_product #(DIM, A_DATA_WIDTH, B_DATA_WIDTH) uut(.Clock(Clock), .A(A), .B(B), .DotProduct(DotProduct));    
    
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
        //A = 16'b0000000000001000;
        //B = 16'b0000000000001000;
        
        // (8^2) * 10 = 640
        
        #100;
    end 
endmodule