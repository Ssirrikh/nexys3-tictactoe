`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    clockdiv 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clockdiv(
	input wire clk,		//master clock: 50MHz
	output wire dclk,		//pixel clock: 25MHz
	output wire segclk	//7-segment clock: 381.47Hz
	);

// 18-bit counter variable
reg [17:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk)
begin
		q <= q + 1;
end

// 100Mhz � 2^18 = 381.47Hz
assign segclk = q[17];

// 100Mhz � 2^2 = 25MHz
assign dclk = q[1];

endmodule
