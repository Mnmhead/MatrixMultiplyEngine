`timescale 1ns / 10ps
/*
 * This module serves as a testbench for the parallel_adder module.
 */
module parallelAdder4_testbench();

    reg Clock;
    reg Reset;
    reg [(32*4)-1:0] vector;
    wire [33:0] sum;
    wire finished;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=100;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // unit under test
    parallelAdder4 uut(.Clock(Clock), .Reset(Reset), .vector(vector), .finished(finished), .sum(sum));    
        
    // Set up the inputs to the design. Each line is a clock cycle.
    initial begin
        // Initialize inputs
        vector = 0;
        #100;
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
     vector = 128'b00000000000000000000000000011000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000; @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                                                        @(posedge Clock);
                         
        #300;
        $stop; // End the simulation.
    end
endmodule
