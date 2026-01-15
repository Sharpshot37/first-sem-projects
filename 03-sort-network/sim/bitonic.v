`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2026 03:50:00 PM
// Design Name: 
// Module Name: bitonic
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

module bitonic(
    input wire[23:0] nums,
    input wire clk,
    input wire reset,
    output reg[23:0] sout
    );
    wire[2:0] num[0:7];
    wire[2:0] stage1[0:7];
    wire[2:0] stage2[0:7];
    wire[2:0] stage3[0:7];
    wire[2:0] stage4[0:7];
    wire[2:0] stage5[0:7];
    wire[2:0] stage6[0:7];
    genvar i;
    genvar n;
    genvar v;
    generate
        for(i=0;i<8;i=i+1)begin: gen_inputs
            assign num[i]=nums[i*3+:3];
        end
    endgenerate 
    
    order order1(num[0],num[1],clk,reset,stage1[0],stage1[1]);
    order order2(num[3],num[2],clk,reset,stage1[3],stage1[2]);
    order order3(num[4],num[5],clk,reset,stage1[4],stage1[5]);
    order order4(num[6],num[7],clk,reset,stage1[7],stage1[6]);
    
    order order5(stage1[0],stage1[2],clk,reset,stage2[0],stage2[2]);
    order order6(stage1[1],stage1[3],clk,reset,stage2[1],stage2[3]);
    order order7(stage1[5],stage1[7],clk,reset,stage2[7],stage2[5]);
    order order8(stage1[4],stage1[6],clk,reset,stage2[6],stage2[4]);
    
    order order9(stage2[0],stage2[1],clk,reset,stage3[0],stage3[1]);
    order order10(stage2[2],stage2[3],clk,reset,stage3[2],stage3[3]);
    order order11(stage2[4],stage2[5],clk,reset,stage3[5],stage3[4]);
    order order12(stage2[6],stage2[7],clk,reset,stage3[7],stage3[6]);
    
    order order13(stage3[0],stage3[4],clk,reset,stage4[0],stage4[4]);
    order order14(stage3[1],stage3[5],clk,reset,stage4[1],stage4[5]);
    order order15(stage3[2],stage3[6],clk,reset,stage4[2],stage4[6]);
    order order16(stage3[3],stage3[7],clk,reset,stage4[3],stage4[7]);
    
    order order17(stage4[0],stage4[2],clk,reset,stage5[0],stage5[2]);
    order order18(stage4[1],stage4[3],clk,reset,stage5[1],stage5[3]);
    order order19(stage4[4],stage4[6],clk,reset,stage5[4],stage5[6]);
    order order20(stage4[5],stage4[7],clk,reset,stage5[5],stage5[7]);
    
    order order21(stage5[0],stage5[1],clk,reset,stage6[0],stage6[1]);
    order order22(stage5[2],stage5[3],clk,reset,stage6[2],stage6[3]);
    order order23(stage5[4],stage5[5],clk,reset,stage6[4],stage6[5]);
    order order24(stage5[6],stage5[7],clk,reset,stage6[6],stage6[7]);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sout <= 24'b0;
        end else begin
            sout <= {stage6[0], stage6[1], stage6[2], stage6[3], stage6[4], stage6[5], stage6[6], stage6[7]};
        end
    end
endmodule

// orignally did not notice that the series needs to be increasing-decreasing / vice-versa sorted initially to be able to conduct a bitonic sort in the first place especially in each step of the bitonic series initially
/*
module bitonic(
    input wire[23:0] nums,
    input wire clk,
    input wire reset,
    output reg[23:0] sout
    );
    wire[2:0] num[0:7];
    wire[2:0] stage1[0:7];
    wire[2:0] stage2[0:7];
    wire[2:0] stage3[0:7];
    genvar i;
    genvar n;
    genvar v;
    generate
        for(i=0;i<8;i=i+1)begin: gen_inputs
            assign num[i]=nums[i*3+:3];
        end
    endgenerate 
    order order1(num[0],num[4],clk,reset,stage1[0],stage1[4]);
    order order2(num[1],num[5],clk,reset,stage1[1],stage1[5]);
    order order3(num[2],num[6],clk,reset,stage1[2],stage1[6]);
    order order4(num[3],num[7],clk,reset,stage1[3],stage1[7]);
    
    order order5(stage1[0],stage1[2],clk,reset,stage2[0],stage2[2]);
    order order6(stage1[1],stage1[3],clk,reset,stage2[1],stage2[3]);
    order order7(stage1[4],stage1[6],clk,reset,stage2[4],stage2[6]);
    order order8(stage1[5],stage1[7],clk,reset,stage2[5],stage2[7]);
    
    order order9(stage2[0],stage2[1],clk,reset,stage3[0],stage3[1]);
    order order10(stage2[2],stage2[3],clk,reset,stage3[2],stage3[3]);
    order order11(stage2[4],stage2[5],clk,reset,stage3[4],stage3[5]);
    order order12(stage2[6],stage2[7],clk,reset,stage3[6],stage3[7]);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sout <= 24'b0;
        end else begin
            sout <= {stage3[7], stage3[6], stage3[5], stage3[4], stage3[3], stage3[2], stage3[1], stage3[0]};
        end
    end
endmodule

*/
