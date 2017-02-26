`timescale 1ns / 10ps
`include "clogb2.v"
/*
 * This module serves as a testbench for the parallel_adder module.
 * parallelAdder.v is incomplete!
 */
module parallelAdder_testbench();
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
    parallelAdder #(DIM, WIDTH) uut(.Clock(Clock), .vector(vector), .finished(finished), .sum(sum));    
        
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
