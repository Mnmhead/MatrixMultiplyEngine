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

module matrixMult
   #( parameter AROW=2,
      parameter ACOL=2,
      parameter BROW=ACOL,
      parameter BCOL=2 )
   ( Clock );  // perhaps we can have write_addr and read_addr as inputs

   // Clock is only input for now
   input Clock;

   // 1. read first row of A from memory
   // 2. read each column of B from memory and pipe A's row and all B's rows to 
   //    a dotProduct module
   // 3. write results of each dot product to a point in memory that coorseponds to the correct
   //    memory location for the result matrix, C.
   // 4. repeat this process for all rows of A

endmodule
