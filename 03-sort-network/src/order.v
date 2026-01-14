`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 08:09:49 PM
// Design Name: 
// Module Name: order
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module order(
    input wire[2:0] a,
    input wire[2:0] b,
    input wire clk,
    input wire reset,
    output wire[2:0] c,
    output wire[2:0] d
    );
    assign c = (a < b) ? a : b;
    assign d = (a < b) ? b : a;
endmodule
