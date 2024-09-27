`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 09:37:22 PM
// Design Name: 
// Module Name: FFSyncReset
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


module FFSyncReset #(parameter WIDTH = 32)(
        input wire clk,reset,syn_reset,
        input wire [WIDTH-1:0]d,
        output reg [WIDTH-1:0]q
    );
    
    wire [WIDTH-1:0] d_internal = syn_reset ? 0 : d;
    
    always_ff @(posedge clk, negedge reset)begin
        if (!reset)
            q <= 0;
        else
            q <= d_internal;
    end
endmodule
