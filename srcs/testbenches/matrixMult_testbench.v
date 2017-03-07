
module matrixMult_testbench();
    localparam INPUT_FEATURES = 4;
    localparam INPUT_WIDTH = 4;
    localparam WEIGHT_WIDTH = 8;
    
    localparam LOG_BATCH_SIZE = 3;
    localparam LOG_OUTPUT_FEATURES = 3;
    localparam OUTPUT_FEATURES = 8;
    localparam OUTPUT_WIDTH = 16;

    reg clk;
    reg start;
    reg [INPUT_FEATURES*INPUT_WIDTH-1:0] inputData;
    reg [INPUT_FEATURES*WEIGHT_WIDTH-1:0] weightData;
    
    wire [LOG_BATCH_SIZE-1:0] inputAddr;
    wire [LOG_OUTPUT_FEATURES-1:0] weightAddr;
    wire [OUTPUT_FEATURES*OUTPUT_WIDTH-1:0] outputData;
    wire [LOG_BATCH_SIZE-1:0] outputAddr;
    wire outputWrEn;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial clk=1;
    always begin
      #(CLOCK_PERIOD/2);
      clk = ~clk;
    end 
    
    matrixMult uut( .clk(clk),
                    .start(start),
                    .inputData(inputData),
                    .weightData(weightData),
                    .inputAddr(inputAddr),
                    .weightAddr(weightAddr),
                    .outputData(outputData),
                    .outputAddr(outputAddr),
                    .outputWrEn(outputWrEn) );
                    
    // begin simulation
    initial begin
        // initialize inputs
        inputData = 0;
        weightData = 0;
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
       start = 1;                           @(posedge clk);
       //start = 0;                           @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk); 
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);    
                                            @(posedge clk);
                                            @(posedge clk);
                                            @(posedge clk);    
                                            @(posedge clk);
        $stop;  // end simulation
    end
endmodule
