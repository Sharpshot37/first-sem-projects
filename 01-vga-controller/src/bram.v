`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2025 08:18:56 PM
// Design Name: 
// Module Name: bram
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


module bram
    #(
        parameter RAM_WIDTH=32,
        parameter RAM_ADDR_BITS=15,
        parameter DATA_FILE="data_file.mem",
        parameter INIT_START_ADDR=0,
        parameter INIT_END_ADDR = (2**RAM_ADDR_BITS)-1
    )
    (
    input clock,
    input ram_enable,
    input write_enable,
    input [RAM_ADDR_BITS-1:0] address,
    input [RAM_WIDTH-1:0] input_data,
    output reg [RAM_WIDTH-1:0] output_data
    );
    
    (* RAM_STYLE="BLOCK" *)
    reg [RAM_WIDTH-1:0] imgram [{2**RAM_ADDR_BITS}-1:0];

    initial
        $readmemh(DATA_FILE,imgram,INIT_START_ADDR,INIT_END_ADDR);
    always @ (posedge clock)
        if(ram_enable) begin
            if (write_enable)
                imgram[address]<=input_data;
            output_data<=imgram[address];
        end
        
endmodule
