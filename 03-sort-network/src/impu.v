`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 12:29:50 PM
// Design Name: 
// Module Name: impu
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


module impu(
    input wire clk,
    input wire reset,
    input wire btnU,
    input wire [15:0] sw,
    output wire [15:0] led
    );
    wire[26:0] new1=85621469;
    wire[26:0] result;
    
    wire [23:0] tinput;
    
    assign tinput = {sw[15:13], sw[12:10], sw[9:7], sw[6:4], sw[3:1], sw[0], 2'b0, 3'b0}; 
    
    //assign tinput = {3'd7, 3'd2, 3'd5, 3'd1, 3'd6, 3'd3, 3'd4, 3'd0};
    
    wire [23:0] sout;
    
    bitonic bitonic1(.nums(tinput),.clk(clk),.reset(reset),.sout(sout));
    
    wire [2:0] sorted [0:7];
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : extract
            assign sorted[i] = sout[i*3 +: 3];
        end
    endgenerate
    
    wire scorrect = (sorted[0] >= sorted[1]) &&
                    (sorted[1] >= sorted[2]) &&
                    (sorted[2] >= sorted[3]) &&
                    (sorted[3] >= sorted[4]) &&
                    (sorted[4] >= sorted[5]) &&
                    (sorted[5] >= sorted[6]) &&
                    (sorted[6] >= sorted[7]);
    

    assign led[15] = scorrect;     
    assign led[14:12] = sorted[0];       
    assign led[11:9] = sorted[1];        
    assign led[8:6] = sorted[7];         
    assign led[5:3] = sorted[3];         
    assign led[2:0] = 3'b111; 
    
endmodule
