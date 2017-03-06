`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: matrixMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description:        Matrix multiplication: [MxN] * [N*O]
//      This module computes matrix multiply of matrices A and B (AxB=C). 
//	The dimensions of matrix A are [M*N].
// The dimensions of matrix B are [N*O].
//	The result of the multiplication is a matrix C with dimensions [M*O].
//
// This module expects to read rows of matrix A and rows of the transpose of B.
// The read addresses are assigned to outputs inputAddr and weightAddr for A and
// B, respectively. 
//
// Lastly, this module specifies a write address, outputAddr, and supplies the buffer
// for writing, outputData. This buffer contains a row of computed elements of C.
//
//////////////////////////////////////////////////////////////////////////////////

module matrix_mult #(
    parameter BATCH_SIZE = 8, // This is M
    parameter LOG_BATCH_SIZE = 3,
    parameter INPUT_FEATURES = 4, // This is N
    parameter LOG_INPUT_FEATURES = 2,
    parameter OUTPUT_FEATURES = 8, // This is O
    parameter LOG_OUTPUT_FEATURES = 3,
    parameter INPUT_WIDTH = 4,
    parameter WEIGHT_WIDTH = 8,
    parameter OUTPUT_WIDTH = 16
) (
    clk,
    rst,
    inputData,
    weightData,
    inputAddr,
    weightAddr,
    outputData,
    outputAddr,
    outputWrEn
);

    // Clock and reset
    input clk;
    input rst;

    // Inputs
    input [INPUT_FEATURES*INPUT_WIDTH-1:0] inputData;
    input [INPUT_FEATURES*WEIGHT_WIDTH-1:0] weightData;

    // Outputs
    output [LOG_BATCH_SIZE-1:0] inputAddr;
    output [LOG_OUTPUT_FEATURES-1:0] weightAddr;
    output [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] outputData;
    output [LOG_BATCH_SIZE-1:0] outputAddr;
    output outputWrEn;


    // Memory to FSM state
    reg [BATCH_SIZE-1:0] batch_state;   // needs only to be CLOGB2(BATCH_SIZE)
    reg [BATCH_SIZE-1:0] next_batch_state;
    reg [OUTPUT_FEATURES-1:0] o_state;  // needs only to be CLOGB2(OUTPUT_FEATURES)
    reg [OUTPUT_FEATURES-1:0] next_o_state;
    
    // State Encodings
    parameter end_batch = OUTPUT_FEATURES;  // When we have dot_product-ed 'O' rows
                                            // with a single row of A, then we know we have
                                            // finished the single row of A and we can signal
                                            // the DMA to write out outputData.
    parameter end_mm = BATCH_SIZE;


    // State Logic
    always @(*) begin
       case(batch_state)

          end_mm:
              // If batch_state is end_mm, then we have finished computing the last
              // batch (last line of A), thus 


          default:
              // default case:
              // 1. Read next line of matrix B, line o_state
              // 2. compute dot product of current batch line and line o_state of B
              // 3. Pipe the output of dot product into a shift register which 
              //    delays output by (O-o_state) cycles.
              // 4. Increment o_state by 1
              // 5. If o_state is equal to end_batch (or maybe end_batch-1), then
              //    we need to directly pipe our dotProduct result into the outputData 
              //    buffer. Simultaneously, we need to set outputWrEn for the single
              //    cycle (or maybe 2 cycles) in which the outputData buffer is valid.
              case(o_state)

              endcase
        
        endcase 
    end


    // DFFs, next state is reached at each clock cycle
    always @(posedge Clock) begin
       // no Reset, ignoring reset signal
       batch_state <= next_batch_state;
       o_state <= next_o_state;
    end
endmodule // matrix_mult

// 1. read first row of A from memory
// 2. read each column of B from memory and pipe A's row and all B's rows to 
//    a dotProduct module
// 3. write results of each dot product to a point in memory that coorseponds to the correct
//    memory location for the result matrix, C.
// 4. repeat this process for all rows of A
