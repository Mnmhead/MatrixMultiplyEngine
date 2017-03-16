`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: matrixMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description:        Matrix multiplication testbench: [MxN] * [N*O]
//		This module serves as a testbench for the matrixMult module. 
//	This module relies on input files to provide it test vectors for adequately testing
// matrix multiply operations. Refer to the python generation scripts for more information.
//		
//////////////////////////////////////////////////////////////////////////////////

module matrixMult_testbench();

   // Memory initialization files
   parameter INPUT_MATRIX  = "input_matrix.mif";
   parameter WEIGHT_MATRIX  = "weight_matrix.mif";
   parameter OUT_MATRIX  = "out_matrix.mif";

	// module parameters
	localparam BATCH_SIZE = 8; // This is M
	localparam LOG_BATCH_SIZE = 3;
	localparam INPUT_FEATURES = 4; // This is N
	localparam LOG_INPUT_FEATURES = 2;
	localparam OUTPUT_FEATURES = 8; // This is O
	localparam LOG_OUTPUT_FEATURES = 3;
	localparam INPUT_WIDTH = 4;
	localparam WEIGHT_WIDTH = 8;
	localparam OUTPUT_WIDTH = 16;

	// module inputs
   reg clk;
   reg start;
   wire [INPUT_FEATURES*INPUT_WIDTH-1:0] inputData;
   wire [INPUT_FEATURES*WEIGHT_WIDTH-1:0] weightData;

   // module outputs
   wire [LOG_BATCH_SIZE-1:0] inputAddr;
   wire [LOG_OUTPUT_FEATURES-1:0] weightAddr;
   wire [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] outputData;
   wire [LOG_BATCH_SIZE-1:0] outputAddr;
   wire outputWrEn;

   // Input vectors and expected output vectors
   reg [INPUT_FEATURES*INPUT_WIDTH-1:0] test_inputData [BATCH_SIZE-1:0];  // M*N
   reg [INPUT_FEATURES*WEIGHT_WIDTH-1:0] test_weightData [OUTPUT_FEATURES-1:0];  // O*N
   reg [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] test_out [BATCH_SIZE-1:0];
   initial begin
      $readmemh(INPUT_MATRIX, test_inputData, 0, BATCH_SIZE-1);
      $readmemh(WEIGHT_MATRIX, test_weightData, 0, OUTPUT_FEATURES-1);
      $readmemh(OUT_MATRIX, test_out, 0, BATCH_SIZE-1);
   end

   // Input vector assignment logic
   reg rst;
   reg [LOG_BATCH_SIZE-1:0] inputIdx;
   reg [LOG_OUTPUT_FEATURES-1:0] weightIdx;
   initial inputIdx = 0;
   initial weightIdx = 0;
   always@(posedge clk) begin
		if( rst ==  1'b1 ) begin
			inputIdx 	<= 0;
            weightIdx   <= 0;
		end else if( weightIdx == OUTPUT_FEATURES - 1 ) begin
             weightIdx   <= 0;
             inputIdx    <= inputIdx+1;
        end else begin
             weightIdx   <= weightIdx+1;
		end
	end

	assign inputData = test_inputData[inputIdx];
	assign weightData = test_weightData[weightIdx];

	// Module instantiation
   matrixMult #(
		BATCH_SIZE,
		LOG_BATCH_SIZE,
		INPUT_FEATURES,
		LOG_INPUT_FEATURES,
		OUTPUT_FEATURES,
		LOG_OUTPUT_FEATURES,
		INPUT_WIDTH,
		WEIGHT_WIDTH,
		OUTPUT_WIDTH
   ) uut( 
      .clk(clk),
      .start(start),
      .inputData(inputData),
      .weightData(weightData),
      .inputAddr(inputAddr),
      .weightAddr(weightAddr),
      .outputData(outputData),
      .outputAddr(outputAddr),
      .outputWrEn(outputWrEn) 
   );

   // Clock generation
   parameter CLOCK_PERIOD=10;
   always begin
      #(CLOCK_PERIOD/2);
      clk = ~clk;
   end 
   
   // Output checking and error handling
   reg [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] expectedOut;
   integer i;
   integer errors;
   initial i = 0;
   initial errors = 0;
   always @(posedge clk) begin
        if( outputWrEn ) begin
            expectedOut = test_out[ i ];
            
            $display("\t\ttime, clk, inputData, weightData, outputData,  ref");
            $monitor("%d,   %b, %h,   %h, %h, %h",
                $time,clk,inputData,weightData,outputData,expectedOut);
    
            if (outputData != expectedOut) begin
                $display("[Info] Error. Expected out %d does not match actual out %d.", expectedOut, outputData);
                errors = errors + 1;
            end
            
            i = i + 1;
        end
   end

    // Simulation start
	initial begin
		// Initialize Inputs
		rst = 1;	
		clk = 0;
		start = 0;
		#(8*CLOCK_PERIOD)

		// Start module by de-asserting reset
		rst = 0;
		@(posedge clk);
		start = 1; // send start signal exactly one cycle after first 'read'
        #(100*CLOCK_PERIOD)
                                                      
        // End of simulation summary
		$display ("Simulation Complete.");
		if (errors == 0) begin
			$display("Validation successful.");
		end else begin
			$display("Validataion failure: %d error(s).", errors);
        end
        
		$finish;
	end
endmodule  // matrixMult_testbench
