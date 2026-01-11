`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 05:48:09 PM
// Design Name: 
// Module Name: pixel_generator
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


module pixel_generator(
    input wire clk,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire video_on,
    output wire [9:0] x,
    output wire [9:0] y
    );
reg [9:0] hcount;
reg [9:0] vcount;

always@(posedge clk or posedge reset)begin
    if(reset)begin
        hcount<=0;
    end else if (hcount==799) begin
        hcount<=0;
    end else begin
        hcount<=hcount+1;
    end
end

always@(posedge clk or posedge reset)begin
    if(reset)begin
        vcount<=0;
    end else if (hcount==799) begin
        if (vcount==524)
            vcount<=0;
        else
            vcount<=vcount+1;
    end
end

assign hsync= (hcount>=656 && hcount<752)?0:1;
assign vsync= (vcount>=490 && vcount<492)?0:1;
 
assign video_on=(hcount<640 && vcount<480);
assign x=hcount;
assign y=vcount;

endmodule
