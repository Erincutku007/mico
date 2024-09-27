`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 01:09:26 PM
// Design Name: 
// Module Name: Adder
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

module Adder (input wire cin,
              input [31:0] a, b,
              output cout,
              output [31:0] y);
    assign {cout,y} = a+b+cin;
endmodule

