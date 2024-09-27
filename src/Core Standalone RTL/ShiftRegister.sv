`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 01:56:06 PM
// Design Name: 
// Module Name: ShiftRegister
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


module ShiftRegister #(parameter WIDTH = 32)(
        input wire clk,reset,syn_reset,d_serial,en,
        output reg [WIDTH-1:0]q
    );
    wire [WIDTH-1:0] d_internal = syn_reset ? 0 : {q[WIDTH-2:0],d_serial};
    
    always_ff @(posedge clk, negedge reset)begin
        if (!reset)
            q <= 0;
        else begin
            if (en)
                q <= d_internal;
        end
    end
endmodule
