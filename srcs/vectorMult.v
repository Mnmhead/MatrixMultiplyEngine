`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: vectorMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module multiplies the elements of two vectors, u and v, to produce a resulting vector 
// of the same dimensions as u and v. The bit-width of the elements of u and v are parameterizable.
// The resulting vector's bit-width will be sufficiently large as to prevent overflow.
//
//////////////////////////////////////////////////////////////////////////////////

module vectorMult
    #( parameter DIM=10,
       parameter W_u=32,
       parameter W_v=32 )
    ( Clock, u, v, result );
      
      // Clock
      input Clock;
      
      // input vectors u and v. Each has DIM amount of elements with bit-width specified by parameters,
      input [(DIM*W_u)-1:0] u;
      input [(DIM*W_v)-1:0] v;
      
      // The result of vector 'element-wise' multiplication
      output [(DIM*(W_u + W_v))-1:0] result;
      
      // register to hold the multiplication values
      reg [(DIM*(W_u + W_v))-1:0] m1;
      // wire to hold outputs of noOverFlowMult
      wire [(DIM*(W_u + W_v))-1:0] m2;
      
      // Instantiate DIM number of noOverflowMult modules.
      // These modules will compute the product of each u[c] v[c] pair and store them in the register m2.
      genvar c;
      generate
          for (c = 0; c < DIM; c = c + 1) begin : multiply
                noOverflowMult #(W_u,W_v) m( .Clock(Clock), 
                                             .a( u[(W_u*c) +: W_u] ), 
                                             .b( v[(W_v*c) +: W_v] ), 
                                             .product( m2[((W_u+W_v)*c) +: (W_u+W_v)] ) );
          end
      endgenerate    
      
      // output assignment
      assign result = m1;
      
      // Next state logic
      always @(posedge Clock) begin
          m1[(DIM*(W_u + W_v))-1:0] <= m2[(DIM*(W_u + W_v))-1:0];
      end      
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/25/2017 12:04:27 PM
// Module Name: vectorMult
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//      This module multiplies the elements of two vectors, u and v, to produce a resulting vector 
// of the same dimensions as u and v. 
//
//////////////////////////////////////////////////////////////////////////////////
/*
module vectorMult_testbench();
    localparam DIM = 10;
    localparam W_v = 8;  // represents the bit-width of input a
    localparam W_u = 8;  // represents the bit-width of input b
    reg Clock;
    reg [(W_u*DIM)-1:0] u;
    reg [(W_v*DIM)-1:0] v;
    wire [((W_u+W_v)*DIM)-1:0] result;
    
    // Set up the clock.
    parameter CLOCK_PERIOD=10;
    initial Clock=1;
    always begin
        #(CLOCK_PERIOD/2);
        Clock = ~Clock;
    end
    
    // Unit Under Test
    vectorMult #(DIM, W_u, W_v) uut( .Clock(Clock), .u(u), .v(v), .result(result) );
    
    initial begin  
        // Initialize inputs
        u = 0;
        v = 0;
        // pause for 100 ns
        #20;
        
        //u = [8,8,8,8,8,8,8,8,8,8]
        u = 80'b00001000000010000000100000001000000010000000100000001000000010000000100000001000;
        //u = [1,2,3,4,5,6,7,8,9,10]
        v = 80'b00000001000000100000001100000100000001010000011000000111000010000000100100001010;
        
        #10;
        
        //u = [16,16,....,16]
        u = 80'b00010000000100000001000000010000000100000001000000010000000100000001000000010000;
        //u = [1,2,3,4,5,6,7,8,9,10]
        v = 80'b00000001000000100000001100000100000001010000011000000111000010000000100100001010;
               
        #30;
    end 
endmodule
*/