`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 05:51:36 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
    input wire clk,
    input wire reset,
    output reg clk2
    );
    
    reg[1:0] counter;
    always@(posedge clk or posedge reset)begin
        if (reset)begin
            counter<=0;
            clk2<=0;
        end else begin
            if(counter==1) begin
                clk2<=~clk2;
                counter<=0;
            end else begin
                counter<=counter+1;
            end
        end
    end
        
endmodule

