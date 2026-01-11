`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 05:53:28 PM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
    input wire clk,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgar,
    output wire [3:0] vgag,
    output wire [3:0] vgab
    );
    wire clk2;
    wire video_on;
    wire [9:0] x,y;
    wire [11:0] rgb;
    wire [31:0] pixel_data;
    wire [14:0] pixel_addr;
    
    assign pixel_addr=(y>>2)*160+(x>>2);
    
    clock_divider clk_div(
        .clk(clk),
        .reset(reset),
        .clk2(clk2)
    );
    
    pixel_generator pgen(
        .clk(clk2),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(x),
        .y(y)
    );
    
    bram #(
        .RAM_WIDTH(32),
        .RAM_ADDR_BITS(15),
        .DATA_FILE("vgadisplay.mem"),
        .INIT_START_ADDR(0),
        .INIT_END_ADDR(19199)
    ) blocram(
        .clock(clk2),
        .ram_enable(1),
        .write_enable(0),
        .address(pixel_addr),
        .input_data(32'b0),
        .output_data(pixel_data)
    );
    
    vga_display vgad(
        .video_on(video_on),
        .x(x),
        .y(y),
        .img(pixel_data),
        .rgb(rgb)
    );
    
    assign vgar=rgb[11:8];
    assign vgag=rgb[7:4];
    assign vgab=rgb[3:0];
endmodule

