`timescale 1ns / 10ps
/* Copyright (c) Gyorgy Wyatt Muntean 2017
 *
 * This module sums a 4 element input vector using
 * pipelining. Each element is 32-bits in width.
 *
 * NOTE: This module is a simplified version of parallelAdder. I created this
 * module so I could figure out how to implement a parallel adder. It was
 * best for me start with something easier.
 */
module parallelAdder4( Clock, Reset, Enable, vector, finished, sum);
    // Clock and Reset Signals
    input Clock;
    input Reset;
    input Enable;
    
    // input vector
    input [127:0] vector;
    
    // sum of vector 
    output [33:0] sum;
    // finished signal, signals that the vector sum is now readable and correctly computed     
    output finished;
    
    // states
    reg [7:0] ts;  // This state, represents the number of elements to add at this level
    reg [7:0] ns;  // Next state
    parameter start = 2'b01;
    parameter idle = 2'b00;
    parameter done = 2'b10;
    reg status;  // status of our computation
    initial status = idle;  // initialize to the idle state
    
    // temporary values
    reg [(34*2) - 1:0] i_vector;  // intermediate vector to store sums after each level of addition
    reg [33:0] temp_sum;
    
    // start the adder when vector changes to a non-zero value
    always @(vector) begin
        if( vector != 0 ) begin
            if( status == idle) begin
                $display( "setting start" );
                status = start;
            end
        end
    end
    
    // Next State logic
    always @(*) begin
        case(ts)
        
        // initial state
        4 : 
            begin : initialize
                integer p;
                integer l;
                l = 0;
                for( p = 0; p < ts; p = p + 2 ) begin
                    i_vector[34*l +: 34] = vector[(32 * (p+1)) +: 32] + vector[(32 * p) +: 32];
                    l = l + 1;
                end
                
                $display( "state 4" );
                ns = ts / 2;  // set the amount of additions to do on the next level
            end
              
        // last addition
        2: 
            begin : p_add
                temp_sum = i_vector[34 +: 34] + i_vector[0 +: 34];
                
                $display( "final addition state" );
                status = done;
                ns = 0;  // this was the last level of additions, set status to done
            end 
        
        // Idle state or finished state, 
        // either the adder has not been started or the adder is finished.
        default: 
            begin 
                if( status == start ) begin
                    ns = 8'b00000100;
                end else if( status == done ) begin
                    ns = ts;  // hold this finished state
                end else if( status == idle ) begin
                    ns = ts;  // hold this idle state
                end
                $display( "Default State. Next state: %d", ns );
            end
        
        endcase
    end
    
    assign sum = temp_sum;
    assign finished = (status == done);
    
    // Next state logic
    always @(posedge Clock) begin
        if( Reset ) begin
            ts <= 0;
            status <= idle;
        end else begin
            ts <= ns;
        end
    end          
endmodule
