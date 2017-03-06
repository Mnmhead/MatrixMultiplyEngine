`timescale 1ns / 1ps
//`include "clogb2.v"
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/27/2017 11:41:27 PM
// Module Name: vectorSum_testbench
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//		This module serves as a testbench for the vectorSum module.
//
//////////////////////////////////////////////////////////////////////////////////
module vectorSum_testbench();
	localparam DIM = 5;  // number of elements
	localparam W_u = 8;  // bit-width of each element

	reg Clock;
	reg [(DIM*W_u)-1:0] u;
	wire [(W_u+1)-1:0] sum;  // should be [(W_u + `CLOG2(DIM))-1:0]
	wire readEn;

	// Set up the clock.
	parameter CLOCK_PERIOD=10;
	initial Clock=1;
	always begin
		#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end 
	
	// unit under test
	vectorSum #(DIM, W_u) uut( .Clock(Clock), .u(u), .sum(sum), .readEn(readEn) );

	// Start Simulation
	initial begin
		// Initialize inputs
		u = 0;
		// pause for 100ns	
		#100;
		// u = [1,2,3,4,5]
		u = 40'b0000000100000010000000110000010000000101;                      @(posedge Clock);
                                                                               @(posedge Clock);
        // u = 16 16 17  8 148                                    
        u = 40'b0001000000010000000100010000100010010100;                      @(posedge Clock);
                                                                               @(posedge Clock);
      #100;
      $stop;
   end
endmodule
