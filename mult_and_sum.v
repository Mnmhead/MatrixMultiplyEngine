/* Copyright (c) Gyorgy Wyatt Muntean 2017
 *
 * This module multiplies to inputs, a and b, and adds the product to a running sum, sum.
 * Input width of both numbers a and b are specficied by parameters A_DATA_WIDTH and B_DATA_WIDTH, respectively.
 * The output bit-width is specified by parameter RES_DATA_WIDTH.
 */
module mult_and_sum #( parameter A_DATA_WIDTH=32,
                       parameter B_DATA_WIDTH=32, 
                       parameter RES_DATA_WIDTH=64 )
                    ( a, b, sum, res);
    // A and B are input vectors
    input [A_DATA_WIDTH - 1:0] a;
    input [B_DATA_WIDTH - 1:0] b;
    input [RES_DATA_WIDTH - 1:0] sum;
    
    // outputS
    output [RES_DATA_WIDTH - 1:0] res;
    
    assign res = (a * b) + sum;               
 endmodule
 
 /*
  * This module serves as a testbench for the mult_and_sum module.
  */
module mult_and_sum_testbench();
    reg [7:0] a;
    reg [7:0] b;
    reg [31:0] sum;
    wire [31:0] res;
    
    parameter A_WIDTH = 8;
    parameter B_WIDTH = 8;
    parameter RES_WIDTH = 32;
    
    // unit under test
    mult_and_sum #(A_WIDTH, B_WIDTH, RES_WIDTH) uut(.a(a), .b(b), .sum(sum), .res(res));    
    
    // Try input combinations for 8-bit numbers 
    integer i;
    integer j;   
    initial begin  
        // Initialize inputs
        a = 0;
        b = 0;
        sum = 0;
        
        // pause for 100 ns
        #100;  
        // Run the module on every combination of two 8-bit inputs.
        // Displays an error if an incorrect result is produced.
        for( i = 0; i < 255; i = i + 1 ) begin
            a = i;   
            for( j = 0; j < 255; j = j + 1 ) begin
                sum = i * j;
                b= j; #10;
                
                if( res != (2*(i*j))) begin
                    $display( "Error: Incorrect dot-product result" );
                    $finish;
                end
            end
        end  
    end 
endmodule
