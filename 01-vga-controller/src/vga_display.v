`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2025 03:56:41 PM
// Design Name: 
// Module Name: vga_display
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


module vga_display(
    input wire video_on,
    input wire [9:0] x,
    input wire [9:0] y, 
    input wire [31:0] img,
    output reg [11:0] rgb
    );
always@(*) begin
    if(!video_on)begin
        rgb=12'h000;
    end else begin
        rgb=img[11:0];      // Gray
    end
end

endmodule
