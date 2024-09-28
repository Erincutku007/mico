`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 01:23:03 PM
// Design Name: 
// Module Name: ExecuteStage
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


module ExecuteStagePipelined(
        input wire clk,rst,valid_ex,flush_ex,
        input wire [27:0]control_word_dec,
        input wire [31:0]pc_plus_4_dec,pc_dec,imm,regfilea,regfileb,
        output wire [31:0]calculated_adr,ALU_result,regfileb_ex,
        output wire [13:0]control_word_ex,
        output wire done_ex
    );
    wire auipc_or_lui,r_i_op,auipc,is_jump,b_src,adr_adder_a,is_branch,rf_wb,mem_we,pc_src,arithmetic_set,branch_taken;
    wire m_set_instruction,mul_done,div_done,mul_op,div_op,mul_valid,div_valid;
    wire [1:0]wb_src;
    wire [4:0]rd;
    
    wire branch_taken_ex;
    
    wire [31:0]A,B,i_alu_result,adr_adder_a_input,ALU_result_or_4,mul_result,div_result,alu_result_muxed,m_set_result;
    wire [2:0]funct3,funct3_masked;
    wire [6:0]funct7_masked;
    wire [3:0]alu_flags;
    //deconstructing control word
    assign {arithmetic_set,auipc_or_lui,r_i_op,auipc,is_jump,b_src,adr_adder_a,is_branch,rf_wb,mem_we,wb_src,pc_src,rd,funct3,funct7_masked} = control_word_dec;
    //extension set detection
    assign m_set_instruction = (funct7_masked==7'b000_0001) & ~b_src;
    assign mul_op = ~funct3[2] & m_set_instruction;
    assign div_op = funct3[2] & m_set_instruction;
    assign mul_valid = mul_op & valid_ex;
    assign div_valid = div_op & valid_ex;
    //ALU inputs
    assign A = regfilea;
    assign B = b_src ? imm : regfileb;
    
    assign funct3_masked = (auipc_or_lui) ? 3'b000 : funct3;
    
    ALU alu(
    .funct7(funct7_masked),
    .funct3(funct3_masked),
    .A(A),
    .B(B),
    .result(i_alu_result),
    .alu_flags(alu_flags)
    );
    //M extension wrapper inputs
//    MULWrapper mul_alu(
//        .clk(clk),
//        .rst(rst),
//        .valid(mul_valid),
//        .flush_ex(flush_ex),
//        .a(A),
//        .b(B),
//        .funct3(funct3_masked),
//        .y(mul_result),
//        .done(mul_done)
//    );
    
//    DivideWrapper divide_alu(
//        .clk(clk),
//        .reset(rst),
//        .valid(div_valid),
//        .flush_ex(flush_ex),
//        .a(A),
//        .b(B),
//        .funct3(funct3_masked),
//        .res(div_result), 
//        .done(div_done)
//    );
    
    DivMulALUFused MAlu(
        .clk(clk),
        .reset(rst),
        .mul_valid(mul_valid),
        .div_valid(div_valid),
        .flush_ex(flush_ex),
        .a(A),
        .b(B),
        .funct3(funct3_masked),
        .res(div_result),
        .y(mul_result),
        .division_done(div_done),
        .multiplication_done(mul_done)
    );
    //address adder inputs
    assign adr_adder_a_input = adr_adder_a ? pc_dec : A;
    Adder address_adder(
        .cin(1'b0),
        .a(adr_adder_a_input),
        .b(imm),
        .y(calculated_adr),
        .cout()
    );
    //condition check
    ConditionCheck condcheck(
        .funct3(funct3),
        .flags(alu_flags),
        .condition_valid(branch_taken)
    );
    //new conrol word
    assign branch_taken_ex = branch_taken & is_branch;
    assign control_word_ex = {branch_taken_ex,rf_wb,mem_we,wb_src,pc_src,rd,funct3};
    //output assignments 
    assign m_set_result = funct3[2] ? div_result : mul_result;
    assign alu_result_muxed = m_set_instruction ? m_set_result : i_alu_result;
    assign ALU_result_or_4 = is_jump ? pc_plus_4_dec : alu_result_muxed;
    assign ALU_result = auipc ? calculated_adr : ALU_result_or_4;
    assign regfileb_ex = regfileb;
    assign done_ex = (~m_set_instruction) | (m_set_instruction & mul_done) | (m_set_instruction & div_done);
endmodule
