`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2024 10:08:16 PM
// Design Name: 
// Module Name: MemoryCoreWrapper
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

//mem_2r1w #(parameter WIDTH = 32,parameter DEPTH = 4,parameter MEMDATA = "")(
//        input clk,
//        input rst,
//        input [ $clog2(DEPTH)+1:0]rd_addr0,rd_addr1,wr_addr0,
//        input [WIDTH-1:0]wr_din0,
//        input we0,
//        output reg [WIDTH-1:0]rd_dout0,rd_dout1
//    );

//CorePipelinedWithoutMemory(
//    input clk,
//    input rst,
//    input [31:0]instruction,memory_data_output,
//    output [31:0]pc_if,mem_read_adr,mem_write_adr,
//    output [31:0]mem_write_data,
//    output mem_we0
//    );
module MemoryCoreWrapper(
        input wire clk,rst
    );
    
    wire we0;
    wire [3:0]wmask;
    wire [31:0] pc_if,instruction,rd_addr1,wr_addr0,wr_din0,rd_dout1;
    //16384
    mem_2r1w #(.WIDTH(32),.DEPTH(16384),.MEMDATA("memory.mem")) memory(
        .clk(clk),
        .rst(rst),
        .rd_addr0(pc_if),
        .rd_addr1(rd_addr1),
        .wr_addr0(wr_addr0),
        .wr_din0(wr_din0),
        .we0(we0),
        .rd_dout0(instruction),
        .rd_dout1(rd_dout1),
        .wmask(wmask)
    );
    
//    input clk,
//    input rst,
//    input [31:0]instruction,memory_data_output,
//    output [31:0]pc_if,mem_read_adr,mem_write_adr,
//    output [31:0]mem_write_data,
//    output mem_we0
    
    CorePipelinedWithoutMemory core(
    .clk(clk),
    .rst(rst),
    .mem_valid(1),
    .instruction(instruction),
    .memory_data_output(rd_dout1),
    .pc_if(pc_if),
    .mem_read_adr(rd_addr1),
    .mem_write_adr(wr_addr0),
    .mem_write_data(wr_din0),
    .mem_we0(we0),
    .wmask(wmask)
    );
endmodule
