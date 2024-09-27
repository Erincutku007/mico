`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2024 11:13:07 PM
// Design Name: 
// Module Name: PriorityEncoder8
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


module PriorityEncoder8(
        input wire [7:0] data,
        output reg [2:0] index
        );
        
        always @ (*) begin
            casex(data)
                8'b1XXX_XXXX: index = 3'b000; 
                8'b01XX_XXXX: index = 3'b001; 
                8'b001X_XXXX: index = 3'b010; 
                8'b0001_XXXX: index = 3'b011; 
                8'b0000_1XXX: index = 3'b100; 
                8'b0000_01XX: index = 3'b101; 
                8'b0000_001X: index = 3'b110;
                8'b0000_0001: index = 3'b111; 
                default: index = 0;
            endcase
        end
endmodule
