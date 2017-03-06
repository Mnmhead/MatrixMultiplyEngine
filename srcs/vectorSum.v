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
    
    // Helpful 'local constants'
    localparam EXTRA_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = W_u + EXTRA_WIDTH;

    // Inputs
    input Clock;
    // Input vectors u and v. Each has DIM amount of elements with bit-width specified by parameters,
    input [(DIM*W_u)-1:0] u;
    
    
    // Outputs
    // The scalar output. To prevent overflow the bit-width must be the width of an element plus
    // the ceiling of the log of the number of elements (i.e. W_u + CLOG2( DIM )).
    output [RES_WIDTH-1:0] sum;
    output readEn;  // single bit, signals a valid sum 
    
    // Constant Driven 0 Value
    // For simplicity, we add the first element with a 'constantly-driven' 0 value.
    reg [RES_WIDTH-1:0] zero;
    initial begin 
        zero = 0;
    end
    
    
    // Shift Registers
    wire [(W_u*DIM)-1:0] next_elements;  // wires to hold elements of vectors after they arrive on the output of their shift register
    genvar shift;
    generate
        // Generate a shift-register for each element in the input vector. These shift registers
        // ensure that element i arrives in adder i at the correct time (i clock cycles of delay).
        for( shift = 0; shift < DIM; shift = shift + 1 ) begin : shiftReg
            nRegisterChain #(shift, W_u) shiftReg( .Clock(Clock), 
                                               .in(u[W_u*shift +: W_u]), 
                                               .out(next_elements[W_u*shift +: W_u]) 
                                             );
        end
    endgenerate
    
    
    // Adders
    wire [(RES_WIDTH*DIM)-1:0] intermediate_sums;  // Output wire for each Adder.
    // This first adder takes the first element and the value 0 as input.
    noOverflowAdd #(W_u, RES_WIDTH, RES_WIDTH) init_add( .Clock(Clock),
                                                         .a(next_elements[W_u-1:0]),
                                                         .b(zero),
                                                         .sum(intermediate_sums[RES_WIDTH-1:0]) 
                                                       );
    genvar c;
    generate
        // Generate a chain of adders. The output of Adder i is the input of adder i+1.
        for( c = 1; c < DIM; c = c + 1) begin : vSum
            noOverflowAdd #(W_u, RES_WIDTH, RES_WIDTH) add( .Clock(Clock), 
                                                            .a(next_elements[W_u*c +: W_u]), 
                                                            .b(intermediate_sums[RES_WIDTH*(c-1) +: RES_WIDTH]), 
                                                            .sum(intermediate_sums[RES_WIDTH*c +: RES_WIDTH]) 
                                                          );
        end
    endgenerate
        
        
    // Output Assignment Logic
    // Assign sum to be the last wire in the adder chain.
    assign sum = intermediate_sums[RES_WIDTH*(DIM-1) +: RES_WIDTH];
    assign readEn = 0;
endmodule
