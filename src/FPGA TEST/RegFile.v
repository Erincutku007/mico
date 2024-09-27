`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 02:24:37 PM
// Design Name: 
// Module Name: RegFile
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


module RegFile#(parameter WIDTH = 32,parameter ADRESS_WIDTH = 5,parameter DEPTH = 32)(
        input wire clk,
        input wire rst,
        input wire [ADRESS_WIDTH-1:0]rd_addr0,rd_addr1,wr_addr0,
        input wire [WIDTH-1:0]wr_din0,
        input wire we0,
        output reg [WIDTH-1:0]rd_dout0,rd_dout1
    );
    reg [WIDTH-1:0] ram_block [DEPTH-1:0];
    integer i = 0;
    always @(posedge clk) begin
            if (we0 & (wr_addr0 != 5'd0))
                ram_block[wr_addr0] <= wr_din0;
        end
    always @(*) begin
        rd_dout0 = (rd_addr0 == 5'b0) ? 32'b0 : ram_block[rd_addr0];
        rd_dout1 = (rd_addr1 == 5'b0) ? 32'b0 : ram_block[rd_addr1];
    end
endmodule
