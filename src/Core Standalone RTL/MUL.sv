`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2024 03:49:33 PM
// Design Name: 
// Module Name: MUL
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


module MUL(
    input  wire [31:0]a,
    input  wire [31:0]b,
    output wire [63:0]y
    );
    wire [127:0]decoder_out;
    wire [15:0]decoder_out_arr[7:0];
    
    genvar i;
    MUL_DEC decoder(
    .a(a),
    .b(b),
    .y(decoder_out)
    );
    generate
        for (i=0;i<8;i=i+1)begin
            assign decoder_out_arr[i] = decoder_out[16*(i+1)-1:16*i];
        end
    endgenerate
    
    wire [63:0]branch0;
    wire [31:0]branch1,branch2;
    
    assign branch0 = {decoder_out_arr[7],decoder_out_arr[3],decoder_out_arr[1],decoder_out_arr[0]};
    assign branch1 = {decoder_out_arr[5],decoder_out_arr[2]};
    assign branch2 = {decoder_out_arr[6],decoder_out_arr[4]};
    
    wire [31:0]sum1;
    wire co1;
    wire [47:0]sum2;
    
    assign {co1,sum1} = branch1+branch2;
    assign sum2 = branch0[63:16] + {co1,sum1};
    
    assign y = {sum2,branch0[15:0]};
    
endmodule