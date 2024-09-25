`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 04:59:44 PM
// Design Name: 
// Module Name: FetchStage
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


module FetchStageWithoutImem(
        input clk,rst,stall_fetch,forward_adr_from_ex,
        input [31:0]target_pc,
        output [31:0]PC_if,PC_plus_four_if
    );
    wire [31:0]PC_plus_four,PC_next,PC;
    
    assign PC_plus_four = PC + 32'd4;
    assign PC_next = forward_adr_from_ex ? target_pc : PC_plus_four ;
    
    
    FlipFlopEnable pc_ff (
        .clk(clk),
        .rst(rst),
        .enable(stall_fetch),
        .d(PC_next),
        .q(PC)
    );
    
    assign PC_plus_four_if = PC_plus_four;
    assign PC_if = PC;
endmodule