`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/28/2017 12:13:09 PM
// Module Name: nRegisterChain
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//       This module 'stamps-out' N registers cahined togetehr by input and output.
//	Essentially, the input to this module will assign to the output at a delay of N cycles.
// The bit-width of the input and output are parameterizable.
//
//////////////////////////////////////////////////////////////////////////////////

module nRegisterChain
   #( parameter N=1,
      parameter W=32 )
   ( Clock, in, out );

   input Clock;

   // input value, a wire of width W
   input [W-1:0] in;
   
   // output, same width as input because eventually 'out' is simply 
   // assigned the same value as 'in'
   output [W-1:0] out;
   
    // N wires to chain the N registers
    reg [(N*W)-1:0] chain;   

	// Output assigment, the final output wire is assigned to the output of this module.
	assign out = chain[(N*W)-1:(N-1)*W];

    // Pipe input into first register on every clock edge.
    always @(posedge Clock) begin
      chain[W-1:0] <= in;
    end
    // Generate N-1 remaining registers.
    // We chain the output of the ith register to the input of the i+1th register.
    genvar c;
    generate
        for (c = 1; c < N; c = c + 1) begin: regs
            always @(posedge Clock) begin
                // intermediate registers chain together
                chain[(c*W) +: W] <= chain[(c-1)*W +: W];
            end
        end
    endgenerate 
endmodule