`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2024 02:19:25 PM
// Design Name: 
// Module Name: mul_benchmark
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


module mul_benchmark(
    input wire [31:0]a,b,
    output wire [63:0]c
    );
    assign c = a*b;
endmodule
