`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2024 01:35:48 PM
// Design Name: 
// Module Name: DecEx
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
////////////////////////////////////////////////////////////////////////////////////
//module mem_2r1w #(parameter WIDTH = 32,parameter DEPTH = 4,parameter MEMDATA = "")(
//        input clk,
//        input rst,
//        input [ $clog2(DEPTH)+1:0]rd_addr0,rd_addr1,wr_addr0,
//        input [WIDTH-1:0]wr_din0,
//        input we0,
//        output reg [WIDTH-1:0]rd_dout0,rd_dout1
//    );

module CorePipelinedWithoutMemory(
    input wire clk,
    input wire rst,
    input wire mem_valid,
    input wire [31:0]instruction,memory_data_output,
    output wire [31:0]pc_if,mem_read_adr,mem_write_adr,
    output wire [31:0]mem_write_data,
    output wire mem_we0,
    output wire [3:0]wmask
    );
    
    //writeback output signals
    wire wb_rf_wb;
    wire [4:0]wb_rd_wb;
    wire [31:0]wb_target_pc_wb,wb_data_wb,calculated_adr_ex;
    //ex done signal
    wire done_ex;
    //stall and flush signals
    wire flush_ex,flush_dec,stall_if,stall_dec,stall_ex,flush_mem,flush_wb;
    wire stall_mem,branch_taken_E,stall_wb;
    wire forward_adr_from_ex,pc_src_E;
    assign stall_wb = 1'b0;
    assign forward_adr_from_ex = branch_taken_E | pc_src_E;
    //core connections
    wire [31:0]pc_plus_4_if;
    FetchStageWithoutImem fetch(
        .clk(clk),
        .rst(rst),
        .stall_fetch(~stall_if),
        .forward_adr_from_ex(forward_adr_from_ex),
        .target_pc(calculated_adr_ex),
        .PC_if(pc_if),
        .PC_plus_four_if(pc_plus_4_if)
    );
    localparam if_dec_reg_size = 32*3;
    wire [if_dec_reg_size:0] fetch_to_dec_in,fetch_to_dec_out;
    assign fetch_to_dec_in = {~flush_dec,pc_if,pc_plus_4_if,instruction};
    
    FlipFlopEnable #(if_dec_reg_size+1) fetch_dec_pipe_reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_dec),
        .d(fetch_to_dec_in),
        .q(fetch_to_dec_out)
    );
    
    //decode input signals
    wire decode_valid_raw,decode_valid;
    wire [31:0] pc_if_to_dec,pc_plus_4_if_to_dec,instruction_to_dec;
    assign {decode_valid_raw,pc_if_to_dec,pc_plus_4_if_to_dec,instruction_to_dec} = fetch_to_dec_out;
    //decode output signals
    wire [31:0]regfilea_dec,regfileb_dec,imm_dec,pc_dec,pc_plus_4_dec;
    wire [27:0]control_word_dec;
    assign decode_valid = decode_valid_raw & ~flush_ex;
    localparam dec_ex_reg_size = 5*32+28;
    wire [dec_ex_reg_size:0] dec_ex_reg_in,dec_ex_reg_out;
    assign dec_ex_reg_in = {decode_valid,regfilea_dec,regfileb_dec,imm_dec,pc_dec,pc_plus_4_dec,control_word_dec};
    //hazard handling wires
    wire wb_valid;
    wire [1:0] RAW_mem_wb_hazards;
    wire [3:0] RAW_hazards;
    wire [31:0]ALU_result_ex,ALU_result_mem;
    wire [4:0] rs1_dec,rs2_dec;
    //wire [3:0] RAW_mem_hazards;
    
    DecodeStagePipelined dec(
    .clk(clk),
    .rst(rst),
    .RAW_hazards(RAW_hazards),
    .instruction(instruction_to_dec),
    .pc_if(pc_if_to_dec),
    .pc_plus_4_if(pc_plus_4_if_to_dec),
    .wb_data(wb_data_wb),
    .execute_data(ALU_result_ex),
    .memory_data(ALU_result_mem),
    .wadr(wb_rd_wb),
    .we_wb(wb_rf_wb),
    .we_valid(wb_valid),
    .RAW_mem_wb_hazards(RAW_mem_wb_hazards),
    .regfilea(regfilea_dec),
    .regfileb(regfileb_dec),
    .imm(imm_dec),
    .pc_dec(pc_dec),
    .pc_plus_4_dec(pc_plus_4_dec),
    .control_word_dec(control_word_dec),
    .rs1_o(rs1_dec),
    .rs2_o(rs2_dec)
    );
    
    FlipFlopEnable #(dec_ex_reg_size+1) dec_ex_pipe_reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_ex),
        .d(dec_ex_reg_in),
        .q(dec_ex_reg_out)
    );
    //execute input signals
    wire execute_valid_raw,execute_valid;
    wire [31:0] regfilea_dec_to_ex,regfileb_dec_to_ex,imm_dec_to_ex,pc_dec_to_ex,pc_plus_4_dec_to_ex;
    wire [27:0] control_word_dec_to_ex,control_word_dec_to_ex_raw;
    assign {execute_valid_raw,regfilea_dec_to_ex,regfileb_dec_to_ex,imm_dec_to_ex,pc_dec_to_ex,pc_plus_4_dec_to_ex,control_word_dec_to_ex_raw} = dec_ex_reg_out;
    assign control_word_dec_to_ex = control_word_dec_to_ex_raw &  {28{execute_valid_raw}};
    //execute output signals
    wire [31:0] regfileb_ex;
    wire [13:0]control_word_ex;
    assign execute_valid = execute_valid_raw & ~flush_mem ;
    localparam ex_mem_reg_size = 32*3+14;
    wire [ex_mem_reg_size:0] ex_mem_reg_in,ex_mem_reg_out;
    assign ex_mem_reg_in = {execute_valid,calculated_adr_ex,ALU_result_ex,regfileb_ex,control_word_ex};
    
    ExecuteStagePipelined ex(
        .clk(clk),
        .rst(rst),
        .valid_ex(execute_valid_raw),
        .flush_ex(0),
        .control_word_dec(control_word_dec_to_ex),
        .pc_plus_4_dec(pc_plus_4_dec_to_ex),
        .pc_dec(pc_dec_to_ex),
        .imm(imm_dec_to_ex),
        .regfilea(regfilea_dec_to_ex),
        .regfileb(regfileb_dec_to_ex),
        .calculated_adr(calculated_adr_ex),
        .ALU_result(ALU_result_ex),
        .regfileb_ex(regfileb_ex),
        .control_word_ex(control_word_ex),
        .done_ex(done_ex)
    );
    
    FlipFlopEnable #(ex_mem_reg_size+1) ex_mem_pipe_reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_mem),
        .d(ex_mem_reg_in),
        .q(ex_mem_reg_out)
    );
    //memory input signals
    wire memory_valid_raw,memory_valid;
    wire [31:0] calculated_adr_ex_to_mem,ALU_result_ex_to_mem,regfileb_ex_to_mem;
    wire [13:0]control_word_ex_to_mem,control_word_ex_to_mem_raw;
    assign {memory_valid_raw,calculated_adr_ex_to_mem,ALU_result_ex_to_mem,regfileb_ex_to_mem,control_word_ex_to_mem_raw} = ex_mem_reg_out;
    //{branch_taken,rf_wb,mem_we,wb_src,pc_src,rd,funct3}
    assign control_word_ex_to_mem = control_word_ex_to_mem_raw & {14{memory_valid_raw}};
    //memory output signals
    assign memory_valid = memory_valid_raw & ~flush_wb;
    wire [31:0]mem_data_out_mem;
    wire [8:0]control_word_mem;
    localparam mem_wb_reg_size = 3*32+9;
    wire [mem_wb_reg_size:0]mem_wb_reg_in,mem_wb_reg_out;
    assign mem_wb_reg_in = {memory_valid,mem_data_out_mem,ALU_result_mem,control_word_mem};
    //mem-core interface
//     {branch_taken,rf_wb,mem_we,wb_src,pc_src,rd,funct3}
    assign mem_we0 = control_word_ex_to_mem[11];
    assign mem_read_adr = calculated_adr_ex_to_mem;
    assign mem_write_adr = calculated_adr_ex_to_mem;
    MemStageWithoutMemory mem(
        .calculated_adr(calculated_adr_ex_to_mem),
        .ALU_result(ALU_result_ex_to_mem),
        .regfileb_ex(regfileb_ex_to_mem),
        .data_read_from_memory(memory_data_output),
        .control_word_ex(control_word_ex_to_mem),
        .mem_write_in(mem_write_data),
        .ALU_result_mem(ALU_result_mem),
        .memory_stage_data(mem_data_out_mem),
        .control_word_mem(control_word_mem),
        .wmask(wmask)
    );
    
    FlipFlopEnable #(mem_wb_reg_size+1) mem_wb_pipe_reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_wb),
        .d(mem_wb_reg_in),
        .q(mem_wb_reg_out)
    );
    //writeback input signals
    wire [31:0]mem_data_out_mem_to_wb,ALU_result_mem_to_wb;
    wire [8:0]control_word_mem_to_wb,control_word_mem_to_wb_raw;
    assign {wb_valid,mem_data_out_mem_to_wb,ALU_result_mem_to_wb,control_word_mem_to_wb_raw} = mem_wb_reg_out;
    
    assign control_word_mem_to_wb = control_word_mem_to_wb_raw & {9{wb_valid}}; 
    
    WriteBackStage wb(
        .mem_data_out(mem_data_out_mem_to_wb),
        .ALU_result_mem(ALU_result_mem_to_wb),
        .control_word_mem(control_word_mem_to_wb),
        .wb_rf_wb(wb_rf_wb),
        .wb_rd(wb_rd_wb),
        .wb_data(wb_data_wb)
    );
    
     //hazard unit
    wire we_ex,we_mem;
    wire [1:0]wb_src_ex,wb_src_mem,wb_src_wb;
    wire [4:0]rd_ex,rd_mem;
    //23 bits{b_src,adr_adder_a,is_branch,rf_wb,mem_we,wb_src,pc_src,rd,funct3,funct7};
    //14 bits {branch_taken_ex,rf_wb,mem_we,wb_src,pc_src,rd,funct3};
    assign branch_taken_E = control_word_ex[13];
    assign pc_src_E = control_word_dec_to_ex[15];
    assign we_ex = control_word_dec_to_ex[19];
    assign we_mem = control_word_ex_to_mem[12];
    assign rd_ex = control_word_dec_to_ex[14:10];
    assign rd_mem = control_word_ex_to_mem[7:3];
    assign wb_src_ex = control_word_dec_to_ex[17:16];
    assign wb_src_mem = control_word_ex_to_mem[10:9];
    assign wb_src_wb = control_word_mem_to_wb[7:6];
    HazardControlUnit hazardunit(
        .branch_taken_E(branch_taken_E),
        .pc_src_E(pc_src_E),
        .we_ex(we_ex),
        .we_mem(we_mem),
        .we_wb(wb_rf_wb),
        .valid_ex(execute_valid),
        .valid_mem(memory_valid),
        .valid_wb(wb_valid),
        .wb_src_ex(wb_src_ex),
        .wb_src_mem(wb_src_mem),
        .done_ex(done_ex),
        .mem_valid(mem_valid),
        .wb_src_wb(wb_src_wb),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .rd_wb(wb_rd_wb),
        .rs1_dec(rs1_dec),
        .rs2_dec(rs2_dec),
        .RAW_hazards(RAW_hazards),
        .RAW_mem_wb_hazards(RAW_mem_wb_hazards),
        .stall_if(stall_if),
        .stall_dec(stall_dec),
        .stall_ex(stall_ex),
        .stall_mem(stall_mem),
        .flush_ex(flush_ex),
        .flush_dec(flush_dec),
        .flush_mem(flush_mem),
        .flush_wb(flush_wb)
    );
endmodule
