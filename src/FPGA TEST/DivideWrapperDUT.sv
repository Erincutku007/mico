`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 11:57:51 PM
// Design Name: 
// Module Name: DivideWrapper
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
// s
//////////////////////////////////////////////////////////////////////////////////


module DivideWrapperDUT(
        input  wire clk,reset,valid,
        input  wire [31:0]a,
        input  wire [31:0]b,
        input  wire [2:0]funct3,
        output wire [31:0]y,rem,
        output wire done
    );
    //REM ICIN SIGN LOGIC LAZIMM
    wire invert_y;
    wire [31:0]a_abs,b_abs,y_abs,rem_abs;
    
    assign a_abs = a[31] ? -a : a;
    assign b_abs = b[31] ? -b : b;
    
    NonrestroingDivide divide(
    .clk(clk),
    .reset(reset),
    .valid(valid),
    .a(a_abs),
    .b(b_abs),
    .y(y_abs),
    .rem(rem_abs),
    .done(done)
    );
    
    assign invert_y = a[31] ^ b[31];
    assign y = invert_y ? -y_abs : y_abs ;
    assign rem = a[31] ? -rem_abs : rem_abs ;
endmodule
