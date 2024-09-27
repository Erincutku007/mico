`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 03:06:15 PM
// Design Name: 
// Module Name: MemStage
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


module MemStageWithoutMemory(
        input wire [31:0]calculated_adr,ALU_result,regfileb_ex,data_read_from_memory,
        input wire [13:0]control_word_ex,
        output wire [31:0] mem_write_in,target_pc,ALU_result_mem,memory_stage_data,
        output wire [8:0]control_word_mem,
        output wire [3:0]wmask
    );
    wire branch_taken,rf_wb,mem_we,pc_src,pc_src_mem;
    wire [1:0] wb_src;
    wire [2:0] funct3;
    wire [4:0] rd;
    assign {branch_taken,rf_wb,mem_we,wb_src,pc_src,rd,funct3} = control_word_ex;
    //mem module instantation
    DataMemWithoutMem #(.MEM_DEPTH(32),.MEMDATA("dmem.mem")) dmem_if (
        .rd_addr0(calculated_adr),
        .wr_addr0(calculated_adr),
        .wr_din0(regfileb_ex),
        .wr_strb(funct3),
        .memory_read_val_raw(data_read_from_memory),
        .rd_dout0(memory_stage_data),
        .mem_write_in(mem_write_in),
        .wmask(wmask)
    );
    //new control word
    assign pc_src_mem = branch_taken | pc_src;
    assign control_word_mem = {rf_wb,wb_src,pc_src_mem,rd};
    assign target_pc = calculated_adr;
    assign ALU_result_mem = ALU_result;
endmodule
