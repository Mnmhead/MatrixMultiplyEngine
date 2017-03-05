`timescale 1ns / 1ps
`include "clogb2.v"
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/27/2017 11:41:27 PM
// Module Name: vectorSum
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module sums the elements of single vector, u, to produce a scalar result.
// The bit-width an element of u is parameterizable, using the W_u parameter. 
// Similarily, the number of elements is parameterizable by DIM.
// The bit-width of the result is chosen as to avoid any possibility of overflow.
//
//////////////////////////////////////////////////////////////////////////////////

module vectorSum #( 
    parameter DIM=2,
    parameter W_u=32 
) ( 
    Clock, 
    u, 
    sum,
    readEn  // single bit to signal when the sum value is valid and ready to be read (read window is only one clock cycle).
);

    localparam EXTRA_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = W_u + EXTRA_WIDTH;

    // Clock
    input Clock;
    
    // input vectors u and v. Each has DIM amount of elements with bit-width specified by parameters,
    input [(DIM*W_u)-1:0] u;
    
    // The scalar output. To prevent overflow the bit-width must be the width of an element plus
    // the ceiling of the log of the number of elements (i.e. W_u + CLOG2( DIM )).
    output [RES_WIDTH-1:0] sum;
    output readEn;  // single bit, signals a valid sum 
    
    reg [RES_WIDTH-1:0] temp_sum;
    reg temp_readEn;
    
    // holds the output of the Adder, should be piped directly into the next Adder in the chain
    wire [(RES_WIDTH*DIM)-1:0] intermediate_sums;
    wire [(W_u*DIM)-1:0] next_elements;
    
    reg [RES_WIDTH-1:0] zero;
    initial begin 
        zero = 0;
    end
    
    // initial values get piped to Adder
    nRegisterChain #(0, W_u) initialReg( .Clock(Clock), 
                                       .in(u[W_u-1:0]), 
                                       .out(next_elements[W_u-1:0]) 
                                     );
    noOverflowAdd #(W_u, RES_WIDTH, RES_WIDTH) init_add( .Clock(Clock),
                                                         .a(next_elements[W_u-1:0]),
                                                         .b(zero),
                                                         .sum(intermediate_sums[RES_WIDTH-1:0]) 
                                                       ); 
    
    genvar c;
    generate
        for( c = 1; c < DIM; c = c + 1) begin : vSum
            
            // pipe the result from the previous adder and u[c] into the next adder.
            // We must delay the element u[c] by c clock cycles, where the vector u is indexed starting at 0.
            nRegisterChain #(c, W_u) shiftReg( .Clock(Clock), 
                                               .in(u[W_u*c +: W_u]), 
                                               .out(next_elements[W_u*c +: W_u]) 
                                             );
            noOverflowAdd #(W_u, RES_WIDTH, RES_WIDTH) add( .Clock(Clock), 
                                                            .a(next_elements[W_u*c +: W_u]), 
                                                            .b(intermediate_sums[RES_WIDTH*(c-1) +: RES_WIDTH]), 
                                                            .sum(intermediate_sums[RES_WIDTH*c +: RES_WIDTH]) 
                                                          );
        end
    endgenerate
        
    // output assignment logic
    // assign sum, to be the last wire in the adder chain
    assign sum = intermediate_sums[RES_WIDTH*(DIM-1) +: RES_WIDTH]; //temp_sum;
    assign readEn = temp_readEn;
endmodule
