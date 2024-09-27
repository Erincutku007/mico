`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 02:29:09 PM
// Design Name: 
// Module Name: ConditionCheck
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


module ConditionCheck(
        input [2:0]funct3,
        input [3:0]flags,
        output condition_valid
    );
    wire V,C,N,Z;
    reg valid;
    assign {V,C,N,Z} = flags;
    always@(*)begin
        case(funct3)
            3'b000: valid = Z;      //Branch if EQual 
            3'b101: valid = ~(N^V); //Branch if Greater or Equal (signed)
            3'b111: valid = C;      //Branch if Greater or Equal (Unsigned) 
            3'b100: valid = (N^V);  //Branch if Less Than (signed) 
            3'b110: valid = ~C;     //Branch if Less Than (Unsigned)
            3'b001: valid = ~Z;     //Branch if Not Equal
            default: valid = 0;
        endcase
    end
    assign condition_valid = valid;
endmodule
