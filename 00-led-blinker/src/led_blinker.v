`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 01:55:47 PM
// Design Name: 
// Module Name: led_blinker
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
module led_blinker(
    input wire clk,
    input wire reset,
    output reg [15:0] led
);

reg [28:0] counter;
reg [15:0] on;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <=0;
        led <=16'h000;
    end
    else if(counter[27]) begin
        led<=~counter[18:3];
        counter<=counter+1;
    end else begin
        led<=16'h000;
        counter<=counter +1;
    end
    end
endmodule

//original designs pre-revision
/* module led_blinker(
    input wire clk,          // 100 MHz from board
    input wire reset,        // Center button
    output reg [15:0] led    // 16 LEDs
);

reg [35:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        led <= 16'h0000;
    end 
    else begin
        counter <= counter + 1;
        led <= counter[35:20];
    end
end

endmodule */


/* module led_blinker(
    input wire clk,
    input wire reset, 
    output reg [15:0] led
    );
    reg [15:0] counter;
    integer k;
    always@(posedge clk or posedge reset)begin
        if(reset)begin
            counter<=0;
            led=16'h000;
        end else if(counter<=25000000)begin
            counter <= counter + 1;
        end else begin
            counter<=0;
            led[1] <= ~led;
        end
         else if (counter<=5000000) begin
            k<=1;
            led<=~led;
        end
        else begin
            counter<=0;
            counter<=counter+1;
            
        end 
    end
    
endmodule */
