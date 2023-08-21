# nexys3-tictactoe

Verilog implementation of 3-player tic-tac-toe on Nexys 3 board. Developed Spring 2023 for CS M152A at UCLA by Chloe Brandon, Narayana "Kat" Adisasmito-Smith, and Jadon Nguyen.

# Installation

Import files into new Xilinx ISE project. Optionally, rebuild .bit for project. Connect Nexys 3 board to computer and upload .bit file to board. Connect Nexys 3 to monitor via onboard VGA port, and switch monitor source to board's output.

# Gameplay

Turns cycle between Red, Green, and Blue players whenever a chip is placed. The cursor can be moved between cells with the Up/Down/Left/Right buttons (hardware A8/C9/C4/D9 respectively), and a chip can be placed with the Select button (hardware B8).

Victory requires one player to achieve four-in-a-row on the 4x4 board, which will paint all cells the color of the winner. While on the win screen, or in the event of a tie, a new game can be started by pressing the Select button.

As an easter egg, entering the Konami Code (UUDDLRLRS) will instantly win the game for the active player.
