`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 02:21:19 PM
// Design Name: 
// Module Name: DataMem
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


module DataMemWithoutMem #(parameter MEM_DEPTH=32,parameter MEMDATA = "")(
    input wire [31:0]rd_addr0,wr_addr0,
    input wire [31:0]wr_din0,
    input wire [2:0]wr_strb,
    input wire [31:0]memory_read_val_raw,
    output wire[31:0]rd_dout0,
    output wire[31:0]mem_write_in,
    output reg [3:0]wmask
    );
    wire [31:0]memory_read_val_shifted,memory_write_val_shifted;
    reg  [31:0]mem_read_out;
    wire [1:0]byte_index_r,byte_index_w;
    wire [4:0]shamt_r,shamt_w;
    wire [31:0] sh_data_raw,sb_data_raw;
    reg [3:0]byte_mask,hw_mask;
    
    assign byte_index_r = rd_addr0[1:0];
    assign byte_index_w = wr_addr0[1:0];
    assign shamt_r = (byte_index_r << 3);
    assign shamt_w = (byte_index_w << 3);
    assign memory_read_val_shifted = memory_read_val_raw >> shamt_r;
    assign memory_write_val_shifted= wr_din0 << shamt_w;
    
    always @(*) begin
        case(wr_strb)
            3'b000: mem_read_out = {{24{memory_read_val_shifted[7]}},memory_read_val_shifted[7:0]};
            3'b100: mem_read_out = {24'd0,memory_read_val_shifted[7:0]};
            3'b001: mem_read_out = {{16{memory_read_val_shifted[15]}},memory_read_val_shifted[15:0]};
            3'b101: mem_read_out = {16'd0,memory_read_val_shifted[15:0]};
            3'b010: mem_read_out = memory_read_val_shifted;
            default: mem_read_out = 0;
        endcase
    end
    
    always @(*) begin
        case(byte_index_w)
            2'b00: byte_mask = 4'b0001;
            2'b01: byte_mask = 4'b0010;
            2'b10: byte_mask = 4'b0100;
            2'b11: byte_mask = 4'b1000;
            default: byte_mask = 0;
        endcase
    end
    
    always@(*)begin
        if (byte_index_w[1])
            hw_mask = 4'b11_00;
        else
            hw_mask = 4'b00_11;
    end
    
    always@(*)begin
        case(wr_strb)
            3'b000: wmask = byte_mask;
            3'b001: wmask = hw_mask;
            3'b010: wmask = 4'hf;
            default wmask = 0;
        endcase
    end
    
    assign mem_write_in = memory_write_val_shifted;
    assign rd_dout0 = mem_read_out;
endmodule
