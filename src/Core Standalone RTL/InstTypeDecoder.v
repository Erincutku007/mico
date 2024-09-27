`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 09:17:09 PM
// Design Name: 
// Module Name: InstTypeDecoder
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


module InstTypeDecoder(
    input wire[6:0]op_code,
    output wire[2:0]op_type
    );
//I=0
//S=2
//B=3
//U=4
//J=5
//R=6
    reg [2:0]inst_type;
    always@(*) begin
        case(op_code)
            7'b011_0011:inst_type = 3'h6;//R;
            7'b001_0011:inst_type = 3'h0;//I;
            7'b010_0011:inst_type = 3'h2;//S;
            7'b110_0011:inst_type = 3'h3;//B;
            7'b110_1111:inst_type = 3'h5;//J;
            7'b110_0111:inst_type = 3'h0;//I;
            7'b001_0111:inst_type = 3'h4;//U;
            7'b011_0111:inst_type = 3'h4;//U;
            7'b111_0011:inst_type = 3'h0;//I;
            default: inst_type = 3'h0;
        endcase
    end
    assign op_type = inst_type;
endmodule
