
`timescale 1ns / 1ps

module vga640x480(
	input wire dclk,		//pixel clock: 50MHz
	input wire btns,
	input wire btnu,
	input wire btnd,
	input wire btnl,
	input wire btnr,

	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);

//// GAME STATE ////

localparam boardSize = 4;

reg [3:0] konami = 0;

// player data
reg validMove = 0;
reg [3:0] winner = 0; // 0=unresolved, 1=p1, 2=p2, 3=p3, 4=tie
reg [3:0] currentPlayer = 1; 

// cursor position
reg [3:0] cursor = 0;
// board cell contents
reg [1:0] board0 = 0;
reg [1:0] board1 = 0;
reg [1:0] board2 = 0;
reg [1:0] board3 = 0;
reg [1:0] board4 = 0;
reg [1:0] board5 = 0;
reg [1:0] board6 = 0;
reg [1:0] board7 = 0;
reg [1:0] board8 = 0;
reg [1:0] board9 = 0;
reg [1:0] board10 = 0;
reg [1:0] board11 = 0;
reg [1:0] board12 = 0;
reg [1:0] board13 = 0;
reg [1:0] board14 = 0;
reg [1:0] board15 = 0;

// victory conditions

wire r0, r1, r2, r3;
assign r0 = board0  != 0 & board0  == board1  & board1  == board2  & board2  == board3;
assign r1 = board4  != 0 & board4  == board5  & board5  == board6  & board6  == board7;
assign r2 = board8  != 0 & board8  == board9  & board9  == board10 & board10 == board11;
assign r3 = board12 != 0 & board12 == board13 & board13 == board14 & board14 == board15;

wire c0, c1, c2, c3;
assign c0 = board0 != 0 & board0 == board4 & board4 == board8  & board8  == board12;
assign c1 = board1 != 0 & board1 == board5 & board5 == board9  & board9  == board13;
assign c2 = board2 != 0 & board2 == board6 & board6 == board10 & board10 == board14;
assign c3 = board3 != 0 & board3 == board7 & board7 == board11 & board11 == board15;

wire d0, d1;
assign d0 = board0 != 0 & board0 == board5 & board5 == board10 & board10 == board15;
assign d1 = board3 != 0 & board3 == board6 & board6 == board9  & board9  == board11;

// wire victory;
// assign victory = r0 | r1 | r2 | r3 | c0 | c1 | c2 | c3 | d0 | d1;

//// BUTTON I/O ////

// button cooldown 625000 => 1/8 of a second
reg [31:0] selectCounter = 32'hfffffff;
reg [31:0] upCounter = 32'hfffffff;
reg [31:0] downCounter = 32'hfffffff;
reg [31:0] leftCounter = 32'hfffffff;
reg [31:0] rightCounter = 32'hfffffff;

// debounce buttons and update cursor on input
always @ (posedge dclk) begin
	// select counter
    if (btns == 1) selectCounter <= 0;
    else if (selectCounter <= 32'hfffff) selectCounter <= selectCounter + 1;
    // select action
    if (selectCounter == 32'hfffff) begin
    	// reset game
    	if (winner != 0) begin
    		konami <= 0;
    		winner <= 0;
    		currentPlayer <= 1;
    		cursor <= 0;
    		board0 <= 0;
    		board1 <= 0;
    		board2 <= 0;
    		board3 <= 0;
    		board4 <= 0;
    		board5 <= 0;
    		board6 <= 0;
    		board7 <= 0;
    		board8 <= 0;
    		board9 <= 0;
    		board10 <= 0;
    		board11 <= 0;
    		board12 <= 0;
    		board13 <= 0;
    		board14 <= 0;
    		board15 <= 0;
    	end
    	else begin
    		if (konami == 8) begin
    			currentPlayer <= (currentPlayer<3) ? (currentPlayer+1) : 1;
    			winner <= currentPlayer;
    		end
    		else begin
    			// place square
	    		case (cursor)
					0: board0 <= (board0 == 0) ? currentPlayer : board0;
					1: board1 <= (board1 == 0) ? currentPlayer : board1;
					2: board2 <= (board2 == 0) ? currentPlayer : board2;
					3: board3 <= (board3 == 0) ? currentPlayer : board3;
					4: board4 <= (board4 == 0) ? currentPlayer : board4;
					5: board5 <= (board5 == 0) ? currentPlayer : board5;
					6: board6 <= (board6 == 0) ? currentPlayer : board6;
					7: board7 <= (board7 == 0) ? currentPlayer : board7;
					8: board8 <= (board8 == 0) ? currentPlayer : board8;
					9: board9 <= (board9 == 0) ? currentPlayer : board9;
					10: board10 <= (board10 == 0) ? currentPlayer : board10;
					11: board11 <= (board11 == 0) ? currentPlayer : board11;
					12: board12 <= (board12 == 0) ? currentPlayer : board12;
					13: board13 <= (board13 == 0) ? currentPlayer : board13;
					14: board14 <= (board14 == 0) ? currentPlayer : board14;
					15: board15 <= (board15 == 0) ? currentPlayer : board15;
				endcase

				// check for winner
				// if (  (board0  != 0 & board0  == board1  & board1  == board2  & board2  == board3)
				// 	| (board4  != 0 & board4  == board5  & board5  == board6  & board6  == board7)
				// 	| (board8  != 0 & board8  == board9  & board9  == board10 & board10 == board11)
				// 	| (board12 != 0 & board12 == board13 & board13 == board14 & board14 == board15)

				// 	| (board0 != 0 & board0 == board4 & board4 == board8  & board8  == board12)
				// 	| (board1 != 0 & board1 == board5 & board5 == board9  & board9  == board13)
				// 	| (board2 != 0 & board2 == board6 & board6 == board10 & board10 == board14)
				// 	| (board3 != 0 & board3 == board7 & board7 == board11 & board11 == board15)

				// 	| (board0 != 0 & board0 == board5 & board5 == board10 & board10 == board15)
				// 	| (board3 != 0 & board3 == board6 & board6 == board9  & board9  == board11)
				// 	) begin
				if (r0 | r1 | r2 | r3 | c0 | c1 | c2 | c3 | d0 | d1) begin
					winner <= currentPlayer;
				end
				// board is full but there is no winner: tie game
				else if (winner == 0 & board0 != 0 & board1 != 0 & board2 != 0 & board3 != 0 & board4 != 0 & board5 != 0 
				 & board6 != 0 & board7 != 0 & board8 != 0 & board9 != 0 & board10 != 0 
				 & board11 != 0 & board12 != 0  & board13 != 0 & board14 != 0 & board15 != 0) begin
					winner <= 4;
				end

				// inc player
				if (winner == 0) currentPlayer <= (currentPlayer<3) ? (currentPlayer+1) : 1;
    		end
    	end
    end

    // assuming canvas coordinates on board...
    
	// up counter
    if (btnu == 1) upCounter <= 0;
    else if (upCounter <= 32'hfffff) upCounter <= upCounter + 1;
    // up action
    if (upCounter == 32'hfffff) begin
    	// move cursor one row higher
    	if (cursor >= boardSize) cursor <= cursor - boardSize;
    	if (konami == 0 | konami == 1) konami <= konami + 1;
    	else konami <= 0;
    end

	// down counter
    if (btnd == 1) downCounter <= 0;
    else if (downCounter <= 32'hfffff) downCounter <= downCounter + 1;
    // down action
    if (downCounter == 32'hfffff) begin
    	// move cursor one row lower
    	if (cursor < boardSize*boardSize - boardSize) cursor <= cursor + boardSize;
    	if (konami == 2 | konami == 3) konami <= konami + 1;
    	else konami <= 0;
    end

	// left counter
    if (btnl == 1) leftCounter <= 0;
    else if (leftCounter <= 32'hfffff) leftCounter <= leftCounter + 1;
    // left action
    if (leftCounter == 32'hfffff) begin
    	// move cursor one column left
    	if (cursor%boardSize > 0) cursor <= cursor - 1;
    	if (konami == 4 | konami == 6) konami <= konami + 1;
    	else konami <= 0;
    end

	// right counter
    if (btnr == 1) rightCounter <= 0;
    else if (rightCounter <= 32'hfffff) rightCounter <= rightCounter + 1;
    // right action
    if (rightCounter == 32'hfffff) begin
    	// move cursor one column right
    	if (cursor%boardSize < boardSize-1) cursor <= cursor + 1;
    	if (konami == 5 | konami == 7) konami <= konami + 1;
    	else konami <= 0;
    end
end



//// VGA BOILERPLATE ////

// video structure constants
localparam hpixels = 800;// horizontal pixels per line
localparam vlines = 521; // vertical lines per frame
localparam hpulse = 96; 	// hsync pulse length
localparam vpulse = 2; 	// vsync pulse length
localparam hbp = 144; 	// end of horizontal back porch
localparam hfp = 784; 	// beginning of horizontal front porch
localparam vbp = 31; 		// end of vertical back porch
localparam vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = risInCurg edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk)
begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;



//////////////////////////////////////////////////////////

//// game constants ////

// grid lines

localparam gLineW = 5; // grid line width

wire isGridV, isGridH;

assign isGridV = hc-(hbp+160) < gLineW | hc-(hbp+320) < gLineW | hc-(hbp+480) < gLineW; // on vertical line
assign isGridH = vc-(vbp+120) < gLineW | vc-(vbp+240) < gLineW | vc-(vbp+360) < gLineW; // on horizontal line

// cell coordinates

wire col0, col1, col2, col3,
	 row0, row1, row2, row3;

assign col0 = hc >= hbp && hc < (hbp+160);
assign col1 = hc >= (hbp+160) && hc < (hbp+320);
assign col2 = hc >= (hbp+320) && hc < (hbp+480);
assign col3 = hc >= (hbp+480) && hc < (hbp+640);

assign row0 = vc >= (vbp) && vc < (vbp+120);
assign row1 = vc >= (vbp + 120) && vc < (vbp+240);
assign row2 = vc >= (vbp + 240) && vc < (vbp+360);
assign row3 = vc >= (vbp + 360) && vc < (vbp+480);

// cursors

localparam curW = 10; // cursor sidelength

wire isInCur0,  isInCur1,  isInCur2,  isI3,
	 isInCur4,  isInCur5,  isInCur6,  isInCur7,
	 isInCur8,  isInCur9,  isInCur10, isInCur11,
	 isInCur12, isInCur13, isInCur14, isInCur15;
		 
assign isInCur0 = (hc-(hbp+80-curW/2) < curW)  & (vc-(vbp+60-curW/2) < curW);
assign isInCur1 = (hc-(hbp+240-curW/2) < curW)  & (vc-(vbp+60-curW/2) < curW);
assign isInCur2 = (hc-(hbp+400-curW/2) < curW)  & (vc-(vbp+60-curW/2) < curW);
assign isInCur3 = (hc-(hbp+560-curW/2) < curW)  & (vc-(vbp+60-curW/2) < curW);

assign isInCur4 = (hc-(hbp+80-curW/2) < curW)  & (vc-(vbp+180-curW/2) < curW);
assign isInCur5 = (hc-(hbp+240-curW/2) < curW)  & (vc-(vbp+180-curW/2) < curW);
assign isInCur6 = (hc-(hbp+400-curW/2) < curW)  & (vc-(vbp+180-curW/2) < curW);
assign isInCur7 = (hc-(hbp+560-curW/2) < curW)  & (vc-(vbp+180-curW/2) < curW);

assign isInCur8 = (hc-(hbp+80-curW/2) < curW)  & (vc-(vbp+300-curW/2) < curW);
assign isInCur9 = (hc-(hbp+240-curW/2) < curW)  & (vc-(vbp+300-curW/2) < curW);
assign isInCur10 = (hc-(hbp+400-curW/2) < curW)  & (vc-(vbp+300-curW/2) < curW);
assign isInCur11 = (hc-(hbp+560-curW/2) < curW)  & (vc-(vbp+300-curW/2) < curW);

assign isInCur12 = (hc-(hbp+80-curW/2) < curW)  & (vc-(vbp+420-curW/2) < curW);
assign isInCur13 = (hc-(hbp+240-curW/2) < curW)  & (vc-(vbp+420-curW/2) < curW);
assign isInCur14 = (hc-(hbp+400-curW/2) < curW)  & (vc-(vbp+420-curW/2) < curW);
assign isInCur15 = (hc-(hbp+560-curW/2) < curW)  & (vc-(vbp+420-curW/2) < curW);

//////////////////////////////////////////////////////////////////////////////

//// draw to screen ////

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// draw grid
		if (isGridV | isGridH)
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b00;
		end

		else if (winner != 0 & hc >= hbp & hc < hfp) begin
			red   = (winner == 2) ? 3'b111 : 3'b001;
			green = (winner == 3) ? 3'b111 : 3'b001;
			blue  = (winner == 1) ? 3'b111 : 3'b001;
		end

		// // DBG: draw all cursors in black
		// else if ( isInCur0  | isInCur1  | isInCur2  | isInCur3  | 
		// 		  isInCur4  | isInCur5  | isInCur6  | isInCur7  |
		// 		  isInCur8  | isInCur9  | isInCur10 | isInCur11 | 
		// 		  isInCur12 | isInCur13 | isInCur14 | isInCur15 )
		// begin
		// 	red = 3'b000;
		// 	green = 3'b000;
		// 	blue = 2'b00;
		// end

		// draw active cursor in white
		else if ( isInCur0&cursor==0   | isInCur1&cursor==1   | isInCur2&cursor==2   | isInCur3&cursor==3   | 
				  isInCur4&cursor==4   | isInCur5&cursor==5   | isInCur6&cursor==6   | isInCur7&cursor==7   |
				  isInCur8&cursor==8   | isInCur9&cursor==9   | isInCur10&cursor==10 | isInCur11&cursor==11 | 
				  isInCur12&cursor==12 | isInCur13&cursor==13 | isInCur14&cursor==14 | isInCur15&cursor==15 )
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end

		//// VERSION 3: USE (r,c) CANVAS COORDS FOR CELLS

		else if (row0 & col0) begin // board0 (0,0)
			red   = (board0 == 1) ? 3'b111 : 3'b001;
			green = (board0 == 2) ? 3'b111 : 3'b001;
			blue  = (board0 == 3) ? 3'b111 : 3'b001;
		end
		else if (row0 & col1) begin // board1 (0,1)
			red   = (board1 == 1) ? 3'b111 : 3'b001;
			green = (board1 == 2) ? 3'b111 : 3'b001;
			blue  = (board1 == 3) ? 3'b111 : 3'b001;
		end
		else if (row0 & col2) begin // board2 (0,2)
			red   = (board2 == 1) ? 3'b111 : 3'b001;
			green = (board2 == 2) ? 3'b111 : 3'b001;
			blue  = (board2 == 3) ? 3'b111 : 3'b001;
		end
		else if (row0 & col3) begin // board3 (0,3)
			red   = (board3 == 1) ? 3'b111 : 3'b001;
			green = (board3 == 2) ? 3'b111 : 3'b001;
			blue  = (board3 == 3) ? 3'b111 : 3'b001;
		end

		else if (row1 & col0) begin // board4 (1,0)
			red   = (board4 == 1) ? 3'b111 : 3'b001;
			green = (board4 == 2) ? 3'b111 : 3'b001;
			blue  = (board4 == 3) ? 3'b111 : 3'b001;
		end
		else if (row1 & col1) begin // board5 (1,1)
			red   = (board5 == 1) ? 3'b111 : 3'b001;
			green = (board5 == 2) ? 3'b111 : 3'b001;
			blue  = (board5 == 3) ? 3'b111 : 3'b001;
		end
		else if (row1 & col2) begin // board6 (1,2)
			red   = (board6 == 1) ? 3'b111 : 3'b001;
			green = (board6 == 2) ? 3'b111 : 3'b001;
			blue  = (board6 == 3) ? 3'b111 : 3'b001;
		end
		else if (row1 & col3) begin // board7 (1,3)
			red   = (board7 == 1) ? 3'b111 : 3'b001;
			green = (board7 == 2) ? 3'b111 : 3'b001;
			blue  = (board7 == 3) ? 3'b111 : 3'b001;
		end

		else if (row2 & col0) begin // board8 (2,0)
			red   = (board8 == 1) ? 3'b111 : 3'b001;
			green = (board8 == 2) ? 3'b111 : 3'b001;
			blue  = (board8 == 3) ? 3'b111 : 3'b001;
		end
		else if (row2 & col1) begin // board9 (2,1)
			red   = (board9 == 1) ? 3'b111 : 3'b001;
			green = (board9 == 2) ? 3'b111 : 3'b001;
			blue  = (board9 == 3) ? 3'b111 : 3'b001;
		end
		else if (row2 & col2) begin // board10 (2,2)
			red   = (board10 == 1) ? 3'b111 : 3'b001;
			green = (board10 == 2) ? 3'b111 : 3'b001;
			blue  = (board10 == 3) ? 3'b111 : 3'b001;
		end
		else if (row2 & col3) begin // board11 (2,3)
			red   = (board11 == 1) ? 3'b111 : 3'b001;
			green = (board11 == 2) ? 3'b111 : 3'b001;
			blue  = (board11 == 3) ? 3'b111 : 3'b001;
		end

		else if (row3 & col0) begin // board12 (3,0)
			red   = (board12 == 1) ? 3'b111 : 3'b001;
			green = (board12 == 2) ? 3'b111 : 3'b001;
			blue  = (board12 == 3) ? 3'b111 : 3'b001;
		end
		else if (row3 & col1) begin // board13 (3,1)
			red   = (board13 == 1) ? 3'b111 : 3'b001;
			green = (board13 == 2) ? 3'b111 : 3'b001;
			blue  = (board13 == 3) ? 3'b111 : 3'b001;
		end
		else if (row3 & col2) begin // board14 (3,2)
			red   = (board14 == 1) ? 3'b111 : 3'b001;
			green = (board14 == 2) ? 3'b111 : 3'b001;
			blue  = (board14 == 3) ? 3'b111 : 3'b001;
		end
		else if (row3 & col3) begin // board15 (3,3)
			red   = (board15 == 1) ? 3'b111 : 3'b001;
			green = (board15 == 2) ? 3'b111 : 3'b001;
			blue  = (board15 == 3) ? 3'b111 : 3'b001;
		end

		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule
