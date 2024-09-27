`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2024 08:27:21 PM
// Design Name: 
// Module Name: stable_to_strobe
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


module stable_to_strobe(
        input wire clk,rst,
        input wire d,
        output reg q,
        output wire strobe
    );
    always@(posedge clk, negedge rst) begin
        if (!rst)
            q <= 0;
        else begin
            q <= d;
        end
    end
    assign strobe = !q & d;
endmodule
