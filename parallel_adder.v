`timescale 1ns / 10ps
`include "clogb2.v"
/* Copyright (c) Gyorgy Wyatt Muntean 2017
 *
 * This module sums all the elements of an input vector using
 * pipelining. 
 * The input vector's length is parameterized by DIM.
 * The width of the elements in the vector are parameterized by W.
 * The width of sum will be W + DIM for now.....later it will be W + ceiling( log_2( DIM ) ).
 *
 * NOTE: CIRITICAL ASSUMPTION: For now I am assuming the input length, DIM, is a power of 2.
 */
module parallel_adder #( parameter DIM = 8,
                          parameter W = 64 )
                       ( Clock, vector, finished, sum);
    
    // Represents the maximum data width we need for the resulting sum (to avoid overflow)
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam RES_W = W + EXTRA_ADD_WIDTH;
    
    // Clock
    input Clock;
    
    // Our input vector with length DIM
    input [(DIM*W) - 1:0] vector;
    
    // The width of the output should be the W + ceiling( log_2( DIM ) ).
    // For now we set it to something greater than that because I can't figure out
    // how to use functions.
    output [RES_W-1:0] sum;     
    output finished;
    
    reg ts;  // This state, represents the number of elements to add at this level
    reg ns;  // Next state
    reg [(RES_W * DIM) - 1:0] i_vector;  // intermediate vector to store sums after each level of addition
    
    // set the initial state to the top-level of the 'tree' of additions
    initial ts = DIM;
    
    // Next State logic
    always @(*) begin
        case(ts)
        
        // initial state
        DIM : begin : initialize
                 integer p;
                 integer l;
                 l = 0;
                 for( p = 0; p < ts; p = p + 2 ) begin
                    i_vector[RES_W*l +: RES_W] = vector[(W * (p+1)) +: W] + vector[(W * p) +: W];
                    l = l + 1;
                 end
                 
                 ns = ts / 2;  // set the amount of additions to do on the next level
              end
        
        // end state
        1 : begin 
                ns = ts;  
            end
        
        // intermediate states
        default: begin : p_add
                    integer i;
                    integer j;
                    j = 0;
                    for( i = 0; i < ts; i = i + 2 ) begin
                        i_vector[RES_W*j +: RES_W] = i_vector[(RES_W * (i+1)) +: RES_W] + i_vector[(RES_W * i) +: RES_W];
                        j = j + 1;
                    end
                    
                    ns = ts / 2;  // set the amount of additions to do on the next level
                 end
        endcase
    end
    
    // Output assignment logic
    // I feel like this just won't work....the value I assign 'sum' won't be correct
    // until all of the additions have been computed...
    // 
    // Maybe I need a 'finished' bit that I can set after I compute the final value.
    // Then if the 'finished' bit is high, the user knows that the value sum is correct.
    assign sum = i_vector[RES_W - 1: 0];
    assign finished = (ts == 1);
    
    // Next state logic
    always @(posedge Clock) begin
        ts <= ns;
    end          
endmodule

/*
 * This module serves as a testbench for the parallel_adder module.
 */
module parallel_adder_testbench();
    localparam DIM = 2;
    localparam WIDTH = 16;
    localparam EXTRA_ADD_WIDTH = `CLOG2(DIM);
    localparam RES_WIDTH = WIDTH + EXTRA_ADD_WIDTH;

    reg Clock;
    reg [(DIM*WIDTH)-1:0] vector;
    wire [RES_WIDTH-1:0] sum;
    wire finished;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // unit under test
    parallel_adder #(DIM, WIDTH) uut(.Clock(Clock), .vector(vector), .finished(finished), .sum(sum));    
        
    // Set up the inputs to the design. Each line is a clock cycle.
    initial begin
        #100;
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
     vector = 32'b00000000000010000000000000001000;                                                   @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                         
        #100;
        $stop; // End the simulation.
    end
endmodule
