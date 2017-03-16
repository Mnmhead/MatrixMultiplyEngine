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


    // Register to track write address
    reg [LOG_BATCH_SIZE-1:0] outAddr;
    initial outAddr = 32'h40000000;  // Base address for output (this is arbitrary for now, should be changed based on DMA module)
    reg [LOG_BATCH_SIZE-1:0] outRowNumber;
    initial outRowNumber = 0;
    

    // Intermediate Registers (for the dot product module)
    wire [OUTPUT_WIDTH-1:0] dotprodData;  // Holds a row of dot product outputs
    wire readEn;  // signal to indicate when a dotProduct has finished and is readable
    reg validLine;
    reg [LOG_OUTPUT_FEATURES-1:0] col_counter;  // a counter to track which row we should put our dot product data into next
    initial validLine = 0;
    initial col_counter = OUTPUT_FEATURES - 1;
    
    
    // Logic to fill the intermediate data buffer
    reg [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] intermediateData;
    always @(posedge clk) begin
        if( readEn ) begin      
            case(col_counter)
                0:
                    begin
                        intermediateData[OUTPUT_WIDTH*col_counter +: OUTPUT_WIDTH] = dotprodData;
                        validLine = 1;
                        col_counter = OUTPUT_FEATURES - 1;
                        
                        outAddr = outAddr + (outRowNumber*OUTPUT_FEATURES*OUTPUT_WIDTH);
                        outRowNumber = outRowNumber + 1;
                    end
                    
                default:
                    begin
                        validLine = 0;
                        intermediateData[OUTPUT_WIDTH*col_counter +: OUTPUT_WIDTH] = dotprodData;
                        col_counter = col_counter - 1;
                    end
            endcase
        end
    end
    
    
    // Dot product module instantiation
    dotProduct #( 
        INPUT_FEATURES, 
        INPUT_WIDTH, 
        WEIGHT_WIDTH, 
        OUTPUT_WIDTH 
    ) dotProduct( 
        .Clock(clk), 
        .start(start), 
        .A(inputData), 
        .B(weightData), 
        .DotProduct(dotprodData), 
        .readEn(readEn) 
    );    
    
    
    // Ouput-Data Assignment Logic
    assign outputData = intermediateData;   // assign the intermediate buffer to the actual output buffer.
    assign outputWrEn = validLine;          // send signal to writer that buffer is ready.
    assign outputAddr = outAddr;            // assign the output address to the address of the row we just computed.
    

    // Memories for FSM state
    reg [LOG_BATCH_SIZE-1:0] batch_state;
    reg [LOG_BATCH_SIZE-1:0] next_batch_state;
    reg [LOG_OUTPUT_FEATURES-1:0] o_state;
    reg [LOG_OUTPUT_FEATURES-1:0] next_o_state;
    // initial FSM state
    initial batch_state = 0;
    initial o_state = 0;
    initial next_batch_state = 0;
    initial next_o_state = 0;

    // Finite State Logic for reading memory
    reg [LOG_BATCH_SIZE-1:0] inAddr;
    reg [LOG_OUTPUT_FEATURES-1:0] wAddr;
    localparam baseInputAddr = 32'h20000000;
    localparam baseWeightAddr = 32'h30000000;
        
    // State Encodings
    parameter begin_batch = 1'b0;
    parameter end_batch = OUTPUT_FEATURES;
    parameter end_mm = BATCH_SIZE;
   
    // FSM for reading data
    always @(*) begin
       case(batch_state)
          end_mm:   // End state
            begin
                // loop forever on the final state
                next_batch_state = next_batch_state;
            end

          default: 
            begin
                case(o_state)
                    begin_batch:    // beginning state for an individual row of A, read in the first lines of memory by supplying addresses
                        begin
                            next_o_state = next_o_state + 1;
                            // Read in line, batch_state, of A
                            inAddr = baseInputAddr + (batch_state*INPUT_WIDTH);
                            // Read in line, o_state, of B
                            wAddr = baseWeightAddr;
                        end
                  
                    end_batch:      // end state for an individual row of A
                        begin
                            // Read in last row of B
                            wAddr = wAddr + WEIGHT_WIDTH;  
                            next_batch_state = next_batch_state + 1;
                            next_o_state = 0;
                        end
                        
                    default:        // default state, simply read in next row of B
                        begin
                            wAddr = wAddr + WEIGHT_WIDTH;
                            next_o_state = next_o_state + 1;
                        end
                        
                endcase
            end
            
        endcase 
    end
    
    // Address output assignment
    assign inputAddr = inAddr;
    assign weightAddr = wAddr;

    // DFFs, next state is reached at each clock cycle
    always @(posedge clk) begin
       batch_state <= next_batch_state;
       o_state <= next_o_state;
    end
endmodule  // matrix_mult