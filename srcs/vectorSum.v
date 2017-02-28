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

module vectorSum
    #( parameter DIM=10,
       parameter W_u=32 )
    ( Clock, u, sum );

    // Clock
    input Clock;
    
    // input vectors u and v. Each has DIM amount of elements with bit-width specified by parameters,
    input [(DIM*W_u)-1:0] u;
    
    // The scalar output. To prevent overflow the bit-width must be the width of an element plus
    // the cieling of the log of the number of elements (i.e. W_u + CLOG2( DIM )).
    output [(W_u + `CLOG2(DIM))-1:0] sum;
    
    
    // states
    reg [`CLOG2(DIM):0] ts;  // This state, represents the number of elements to add at this level
    reg [`CLOG2(DIM):0] ns;  // Next state
    
    // register to hold entire vector, then we feed elements of the vector 1 cycle at a time into the pipeline.
    // Element i will be fed into add-module i at cycle i. 
    // After an element has been fed into the pipeline, another element from the NEXT vector we want to sum can be fed in
    // on the next cycle. 
    // I'm sort of confused...I maximizing the throughput of the vector sum module by allowing antier vector sum operation
    // to complete every cycle. Then this means that 
    reg [(W_u + `CLOG2(DIM))-1:0] i_sums;

    // Here is my idea....
    // I will create a parameterized module called nRegisters. It will take in a integer n and stamp out n registers.
    // It will take a sinlge input and pass the input from one register to the next untill finally the output is assigned
    // to the input n posedges later.



    
    // Next state logic
    always @(posedge Clock) begin
        ts <= ns;
    end          

endmodule
