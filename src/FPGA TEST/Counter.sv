`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 09:38:20 PM
// Design Name: 
// Module Name: Counter
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


module Counter #(parameter WIDTH = 6)(
    input wire reset,clk,syn_reset,
    input wire [WIDTH-1:0]threshold,
    output wire done,
    output reg [WIDTH-1:0]count,
    output wire [WIDTH-1:0]count_next
    );
   
    
    always_ff @(posedge clk,negedge reset)begin
        if (!reset)
            count <= 0;
        else
            count <= (syn_reset | done) ? 0 : count_next;
    end
    
    assign count_next = count + 1;
    assign done = (threshold == count_next);
    
endmodule
