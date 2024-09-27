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
        input   wire          clk,rst,
        //AXI IF signals
        input	wire		  o_rsp_stb,
		input	wire    [31:0]o_rsp_word,
        input	wire		  o_cmd_busy,
        output	wire		  i_valid,
		output  wire          i_write,
		output	wire	[31:0]i_data,
		output  wire     [3:0]i_addr,
		//FPGA IO
		output reg     [15:0]  LED,
		output reg      [6:0]  seg,
		output reg              dp,
		output reg      [3:0]   an
    );
    
    wire we0,peripherals_selected;
    wire [3:0]wmask;
    wire [31:0] pc_if,instruction,rd_addr1,wr_addr0,wr_din0,rd_dout1;
    reg  [31:0] data_to_core;
    
    reg valid_signal_to_core;
    wire AXI_selected,IO_selected;
    
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
    
    assign i_valid = !o_rsp_stb & (AXI_selected & peripherals_selected);
    assign i_write = we0;
    assign i_data  = wr_din0;
    assign i_addr  = rd_addr1[3:0];
    
    always@(*)begin
        case(rd_addr1[31:30])
            2'b11: data_to_core = o_rsp_word;
            default data_to_core = rd_dout1;
        endcase
    end
    assign AXI_selected = (rd_addr1[31:30] == 2'b11);
    assign IO_selected = (rd_addr1[31:30] == 2'b10) & peripherals_selected;
    
    always@(posedge clk, negedge rst) begin
        if (!rst) begin
            LED <= 0;
            seg <= 0;
            dp <= 0;
            an <= 0;
        end
        else begin
            if (IO_selected & we0)
                case (rd_addr1[1:0])
                    2'b00: LED <= wr_din0[15:0];
                    2'b01: seg <= wr_din0[6:0];
                    2'b10: dp <= wr_din0[0];
                    2'b11: an <= wr_din0[3:0];
                endcase
        end    
    end
    
    always@(*)begin
        valid_signal_to_core = 1'b1;
        if (peripherals_selected) begin
            if (AXI_selected)
                valid_signal_to_core = o_rsp_stb;
        end
        else
            valid_signal_to_core = 1'b1;
    end
    
    CorePipelinedWithoutMemory core(
    .clk(clk),
    .rst(rst),
    .mem_valid(valid_signal_to_core),
    .instruction(instruction),
    .memory_data_output(data_to_core),
    .pc_if(pc_if),
    .mem_read_adr(rd_addr1),
    .mem_write_adr(wr_addr0),
    .mem_write_data(wr_din0),
    .mem_we0(we0),
    .wmask(wmask),
    .peripherals_selected(peripherals_selected)
    );
endmodule
