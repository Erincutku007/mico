`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 10:00:31 PM
// Design Name: 
// Module Name: mem_1r1w
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


module mem_2r1w #(parameter WIDTH = 32,parameter DEPTH = 32,parameter MEMDATA = "")(
        input wire clk,
        input wire rst,
        input wire [ $clog2(DEPTH)+1:0]rd_addr0,rd_addr1,wr_addr0,
        input wire [WIDTH-1:0]wr_din0,
        input wire we0,
        input wire [3:0]wmask,
        output reg [WIDTH-1:0]rd_dout0,rd_dout1
    );
    localparam ByteWidth = 8;
    integer i = 0;
    reg [WIDTH-1:0] ram_block [DEPTH-1:0];
    wire [$clog2(DEPTH)-1:0]write_adr = {2'b00,wr_addr0[$clog2(DEPTH)+1:2]};
    always @(posedge clk) begin
        if (we0)
            for (i=0 ; i<4 ; i=i+1) begin
                if (wmask[i]) begin
                    ram_block[write_adr][i*ByteWidth+:ByteWidth] <= wr_din0[i*ByteWidth+:ByteWidth];
                end
            end
    end
//    ram_block[write_adr] <= wr_din0;
    wire [$clog2(DEPTH)-1:0]read_adr0 = {2'b00,rd_addr0[$clog2(DEPTH)+1:2]};
    wire [$clog2(DEPTH)-1:0]read_adr1 = {2'b00,rd_addr1[$clog2(DEPTH)+1:2]};
    always @(*) begin
        rd_dout0 = ram_block[read_adr0];
        rd_dout1 = ram_block[read_adr1];
    end
    
    initial begin
        if (MEMDATA != "")
            $display("veri yukleniyor");
            $readmemh(MEMDATA,ram_block);
     end
endmodule
