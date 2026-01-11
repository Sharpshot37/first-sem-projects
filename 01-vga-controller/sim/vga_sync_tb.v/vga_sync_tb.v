`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 10:26:20 AM
// Design Name: 
// Module Name: vga_sync_tb
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


module vga_sync_tb;
    reg clk;
    reg reset;
    wire hsync,vsync,video_on;
    wire [9:0] x,y;

    
    pixel_generator uut(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(x),
        .y(y)
    );
    initial clk=0;
    always #20 clk=~clk;
    
    initial begin
        reset=1;
        #100 
        reset=0;
        
        
        
        #100000;
        
        $display("Test Complete!");
        $finish;
    end
    
    integer cycle = 0;
    always @(posedge clk) begin
        cycle = cycle + 1;
        
        // Print every 100 clocks
        if (cycle % 100 == 0)
            $display("Cycle %4d: x=%3d, y=%3d, hsync=%b, vsync=%b", 
                     cycle, x, y, hsync, vsync);
        
        // Print when x wraps
        if (x == 799)
            $display("  >>> Line complete! x wrapping to 0, y will be %0d", y+1);
            
        // Print first few x values to verify counting
        if (cycle <= 30)
            $display("  Cycle %2d: x=%0d", cycle, x);
    end
    
    // Error detection
    always @(posedge clk) begin
        if (x > 799)
            $display("ERROR at time %0t: x=%0d (exceeds 799!)", $time, x);
        if (y > 524)
            $display("ERROR at time %0t: y=%0d (exceeds 524!)", $time, y);
    end
endmodule
