`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2024 07:34:24 PM
// Design Name: 
// Module Name: DecEx_tb
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


module MemoryCore_tb(

    );

    reg clk,rst;
    MemoryCoreWrapper DUT(
    .clk(clk),
    .rst(rst)
    );
    
    always begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        rst = 0;
        #20;
        rst = 1;
        #200;
    end
endmodule
