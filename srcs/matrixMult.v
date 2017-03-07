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

module matrixMult #(
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
    start,
    inputData,
    weightData,
    inputAddr,
    weightAddr,
    outputData,
    outputAddr,
    outputWrEn
);

    // Inputs
    input clk;
    input start;  // start signal
    input [INPUT_FEATURES*INPUT_WIDTH-1:0] inputData;
    input [INPUT_FEATURES*WEIGHT_WIDTH-1:0] weightData;


    // Outputs
    output [LOG_BATCH_SIZE-1:0] inputAddr;
    output [LOG_OUTPUT_FEATURES-1:0] weightAddr;
    output [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] outputData;
    output [LOG_BATCH_SIZE-1:0] outputAddr;
    output outputWrEn;


    // Memories for FSM state
    reg [BATCH_SIZE-1:0] batch_state;   // needs only to be CLOGB2(BATCH_SIZE)
    reg [BATCH_SIZE-1:0] next_batch_state;
    reg [OUTPUT_FEATURES-1:0] o_state;  // needs only to be CLOGB2(OUTPUT_FEATURES)
    reg [OUTPUT_FEATURES-1:0] next_o_state;
    reg validOutput;
    // initial FSM state
    initial batch_state = 0;
    initial o_state = 0;
    initial next_batch_state = 0;
    initial next_o_state = 0;
    initial validOutput = 0;
      
      
    // State Encodings
    parameter begin_batch = 1'b0;
    parameter end_batch = OUTPUT_FEATURES;  // When we have dot_product-ed 'O' rows
                                            // with a single row of A, then we know we have
                                            // finished the single row of A and we can signal
                                            // the DMA to write out outputData.
    parameter end_mm = BATCH_SIZE;

    // Intermediate buffer to hold fully computed row of C
    reg [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] intermediateData;
     
    // Intermediate Registers (for the dot product module)
    wire [OUTPUT_WIDTH-1:0] dotprodData;  // Holds a row of dot product outputs
    wire readEn;  // signal to indicate when a dotProduct has finished and is readable
    reg validLine;
    reg [LOG_OUTPUT_FEATURES-1:0] col_counter;  // a counter to track which row we should put our dot product data into next
    initial validLine = 0;
    initial col_counter = 0;
    
    
    // Logic to determine when a full line of the C matrix has been written to 'intermediateData'
    always @(posedge clk) begin
        if( readEn ) begin      
            case(col_counter)
                OUTPUT_FEATURES - 1:
                    begin
                        intermediateData[OUTPUT_WIDTH*col_counter +: OUTPUT_WIDTH] = dotprodData;
                        validLine = 1;
                        col_counter = 0;
                    end
                    
                default:
                    begin
                        validLine = 0;
                        intermediateData[OUTPUT_WIDTH*col_counter +: OUTPUT_WIDTH] = dotprodData;
                        col_counter = col_counter + 1;
                    end
                    
            endcase
        end
    end
    
    
    // Addign Ouput-Write-Enable flag to validLine register value
    assign outputWrEn = validLine;
    always @(posedge clk) begin
        // logic to ensure validLine is only high for one clock cycle
        //if( validLine ) begin
        //    validLine <= 0;
        //end
    end
   
    
    dotProduct #( INPUT_FEATURES, 
                  INPUT_WIDTH, 
                  WEIGHT_WIDTH, 
                  OUTPUT_WIDTH ) 
                dotProduct( .Clock(clk), .start(start), .A(inputData), .B(weightData), .DotProduct(dotprodData), .readEn(readEn) );    
    
    
    // Assign the intermeditae buffer to the actual output buffer.
    assign outputData = intermediateData;
    

    // State Logic
    always @(*) begin
       case(batch_state)
          end_mm: 
            begin
                next_batch_state = next_batch_state;
                // If batch_state is end_mm, then we have finished computing the last
                // batch (last line of A).
            end

          default: 
            begin
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
                // 6. Lastly...
                //    If o_state is equal to 0, then this means we need to read in the 
                //    next line of A (wait until o_state = 1 to read in line of B).
                case(o_state)
                    begin_batch: 
                        begin
                            next_o_state = next_o_state + 1;
                            // Read in line of A
                            //$display( "batch: %d, o_feature: %d", batch_state, o_state);
                            //$display( "Read line %d of A", batch_state );
                        end
                  
                    end_batch:
                        begin
                            // this is the last row of B to read
                                            
                            // increment the batch state, 
                            // set the output_feature state to 0 again,
                            // now onto the next batch
                            next_batch_state = next_batch_state + 1;
                            next_o_state = 0;
                            //$display( "batch: %d, o_feature: %d", batch_state, o_state);
                            //$display( "Reading last line, %d, of B", o_state );
                        end
                        
                    default: 
                        begin
                            next_o_state = next_o_state + 1;
                            //$display( "batch: %d, o_feature: %d", batch_state, o_state);
                            //$display( "Reading line, %d, of B", o_state );
                        end
                        
                endcase
            end
            
        endcase 
    end
    
    always @(posedge clk) begin
        $display( "Reading line %d of B while on line %d of A", o_state, batch_state );
    end

    // DFFs, next state is reached at each clock cycle
    always @(posedge clk) begin
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