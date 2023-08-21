`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:56 03/19/2013 
// Design Name: 
// Module Name:    segdisplay 
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
module segdisplay(
	input wire segclk,		//7-segment clock
	output reg [6:0] seg,	//7-segment display LEDs
	output reg [3:0] an		//7-segment display anode enable
	);

// constants for displaying letters on display
localparam N = 7'b1001000;
localparam E = 7'b0110000;
localparam R = 7'b1001100;
localparam P = 7'b0001010;

// Finite State Machine (FSM) states
localparam left = 2'b00;
localparam midleft = 2'b01;
localparam midright = 2'b10;
localparam right = 2'b11;

// state register
reg [1:0] state;

// FSM which cycles though every digit of the display every 2.62ms.
// This should be fast enough to trick our eyes into seeing that
// all four digits are on display at the same time.
always @(posedge segclk)
begin
		case(state)
			left:
			begin
				seg <= N;
				an <= 4'b0111;
				state <= midleft;
			end
			midleft:
			begin
				seg <= E;
				an <= 4'b1011;
				state <= midright;
			end
			midright:
			begin
				seg <= R;
				an <= 4'b1101;
				state <= right;
			end
			right:
			begin
				seg <= P;
				an <= 4'b1110;
				state <= left;
			end
		endcase
end

endmodule
