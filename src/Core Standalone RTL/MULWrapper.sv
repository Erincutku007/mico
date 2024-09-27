`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2024 09:51:10 PM
// Design Name: 
// Module Name: MULWrapper
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


module MULWrapper(
    input  wire clk,rst,valid,flush_ex,
    input  wire [31:0]a,
    input  wire [31:0]b,
    input  wire [2:0]funct3,
    output wire [31:0]y,
    output wire done
    );
    wire [31:0]a_abs,b_abs,y_shifted;
    wire [63:0]y_unsigned,y_signed;
    wire sign,zero_result;
    wire take_abs_a,take_abs_b;
    
    assign take_abs_a = a[31] & ~(funct3[1:0] == 2'b11);
    assign take_abs_b = b[31] & ~funct3[1];
    
    assign a_abs = take_abs_a ? (-a) : a;
    assign b_abs = take_abs_b ? (-b) : b;
    assign zero_result = (a==32'b0) | (b==32'b0);
    
    MULPipelined mul(
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .flush_ex(flush_ex),
    .a(a_abs),
    .b(b_abs),
    .y(y_unsigned),
    .done(done)
    );
    
    assign sign = take_abs_a ^ take_abs_b;
    assign y_signed = sign ? (-y_unsigned) : y_unsigned;
    assign y_shifted = |funct3[1:0] ? y_signed[63:32] : y_signed[31:0];
    assign y = zero_result ? 32'b0 : y_shifted;
endmodule
