`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 08:20:34 PM
// Design Name: 
// Module Name: ImmExtend
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


module ImmExtender(
        input wire[31:0]inst,
        input wire[2:0]op_type,
        output wire [31:0]imm_out
    );
//I=0
//S=2
//B=3
//U=4
//J=5
//R=6
    reg [31:0]imm;
    
    always@(*) begin
        case(op_type)
            3'h0: imm = { {21{inst[31]}} ,inst[30:25],inst[24:21],inst[20]};
            3'h2: imm = { {21{inst[31]}} ,inst[30:25],inst[11:8],inst[7]};
            3'h3: imm = { {20{inst[31]}} ,inst[7],inst[30:25],inst[11:8],1'b0};
            3'h4: imm = { inst[31],inst[30:20],inst[19:12],12'b0};
            3'h5: imm = { {12{inst[31]}} ,inst[19:12],inst[20],inst[30:25],inst[24:21],1'b0};
            default: imm = 32'b0;
        endcase
    end
    assign imm_out = imm;
endmodule
