`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2024 08:08:14 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input wire [6:0]funct7,
    input wire [2:0]funct3,
    input wire [31:0]A,B,
    output wire [31:0]result,
    output wire [3:0]alu_flags
    );
    wire sub,cout,less_than_signed,less_than_unsigned,V,C,N,Z;
    wire [31:0]adder_out,adder_b,shift_out;
    reg  [31:0]res;
    assign sub = funct7[5];
    assign adder_b = sub ? ~B : B;
    assign V = (A[31]^adder_out[31]) & ~(A[31]^B[31]^sub);
    assign C = cout;
    assign N = adder_out[31];
    assign Z = (32'b0 == adder_out);
    assign less_than_signed = N^V;
    assign less_than_unsigned = ~cout;
    
    assign alu_flags = {V,C,N,Z};
    
    Adder add(
        .cin(sub),
        .a(A),
        .b(adder_b),
        .y(adder_out),
        .cout(cout)
    );
    
    Shifter shifter (
        .a(A),
        .b(B[4:0]),
        .mode(funct7[5]),
        .sel(funct3[2]),
        .y(shift_out)
    );
    
    always@(*) begin
        case(funct3)
            3'b000: res = adder_out;
            3'b001: res = shift_out;
            3'b010: res = {31'b0,less_than_signed};
            3'b011: res = {31'b0,less_than_unsigned};
            3'b100: res = A ^ B;
            3'b101: res = shift_out;
            3'b110: res =  A | B;
            3'b111: res =  A & B;
        endcase
    end
    assign result = res;
endmodule
