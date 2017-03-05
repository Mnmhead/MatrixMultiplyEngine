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
    // the cieling of the log of the number of elements (i.e. W_u + CLOG2( DIM )).
    output [RES_WIDTH-1:0] sum;
    output readEn;  // single bit, signals a valid sum 
    
    reg [RES_WIDTH-1:0] temp_sum;
    reg temp_readEn;

    // Note to self: Try taking out the add module and just having a bunch of shift registers...

    genvar c;
    generate
        for( c = 0; c < DIM; c = c + 1) begin : vSum

            wire [RES_WIDTH-1:0] intermediate_sum;
            reg [RES_WIDTH-1:0] sum_reg;  // register to hold the intermediate sum
            
            wire [RES_WIDTH-1:0] nextInput;
            wire [W_u-1:0] next_element;
            
            // pipe the result from the previous adder and u[c] into the next adder.
            // We must delay the element u[c] by c clock cycles, where the vector u is indexed starting at 0.
            nRegisterChain #(c, W_u) shiftReg( .Clock(Clock), .in(u[W_u*c +: W_u]), .out(next_element) );
            noOverflowAdd #(W_u, RES_WIDTH, RES_WIDTH) add( .Clock(Clock), .a(next_element), .b(nextInput), .sum(intermediate_sum) );
            
            // Assignment and register logic to pipe the output of one adder into a register then pipe the output of the register 
            // into the next adder.
            assign nextInput = sum_reg;
            always @(posedge Clock) begin
                sum_reg <= intermediate_sum;
            end
            
            // if c == DIM - 1 then we are on the last iteration, so take the value out of sum_reg and assign it to
            // final output
            always @(*) begin
                if( c == DIM-1 ) begin
                    $display( "DIM %d, and c %d", DIM, c );
                    temp_sum = nextInput;  // sum = sum_reg;
                    temp_readEn = 1'b1;
                end
            end
        end
    endgenerate
    
    // output assignment logic
    assign sum = temp_sum;
    assign readEn = temp_readEn;
endmodule
