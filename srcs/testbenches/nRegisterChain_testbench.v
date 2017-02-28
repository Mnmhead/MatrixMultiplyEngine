`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Gyorgy Wyatt Muntean 2017
// Create Date: 02/28/2017 12:13:09 PM
// Module Name: nRegisterChain_testbench
// Project Name: Matrix Multiply
// Target Devices: ZYNQ702
// Description: 
//		This module serves as a testbench for the nRegisterChain module.
//
//////////////////////////////////////////////////////////////////////////////////

module nRegisterChain_testbench();
   localparam W=16;
   localparam N=0;

   reg Clock;
	reg [W-1:0] in;
	wire [W-1:0] out;

	// Set up the clock.
	parameter CLOCK_PERIOD=10;
	initial Clock=1;
	always begin
	  #(CLOCK_PERIOD/2);
	  Clock = ~Clock;
	end 

	// unit under test
	nRegisterChain #(N,W) uut( .Clock(Clock), .in(in), .out(out) );

	// Start Simulation.	
	initial begin
		// Initialize inputs
		in = 0;
		// pause 100ns	
		#100;

		in = 16'b0100101001010101;									@(posedge Clock);
	    in = 16'b0101000101011111;									@(posedge Clock);
		in = 16'b1111111101111010;									@(posedge Clock);
		in = 16'b0000000000000001;									@(posedge Clock);
                                                                    @(posedge Clock);	
                                                                    @(posedge Clock);	
                                                                    @(posedge Clock);	
		in = 16'b1100110011001100;									@(posedge Clock);	
		in = 16'b0000000000000000;									@(posedge Clock);	
                                                                    @(posedge Clock);
                                                                    @(posedge Clock);
                                                                    @(posedge Clock);
		#100;
		$stop;  // End the simulation.
	end
endmodule
