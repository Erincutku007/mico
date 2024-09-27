`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 02:43:18 PM
// Design Name: 
// Module Name: Decode
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


module DecodeStagePipelined(
    input wire clk,
    input wire rst,
    input wire [3:0]RAW_hazards,
    input wire [31:0]instruction,pc_if,pc_plus_4_if,wb_data,execute_data,memory_data,
    input wire [4:0]wadr,
    input wire we_wb,we_valid,
    input wire [1:0]RAW_mem_wb_hazards,
    output wire [31:0]regfilea,regfileb,imm,pc_dec,pc_plus_4_dec,
    output wire [27:0]control_word_dec,
    output wire [4:0]rs1_o,rs2_o
    );
    //control signal declerations
    wire [4:0]rs2,rs1,rd;
    wire [6:0]opcode,funct7,funct7_masked;
    wire [2:0]funct3,op_type;
    wire [31:0]extended_imm,reg_a_val,reg_b_val,reg_a_val_raw,reg_b_val_raw;
    wire [1:0]wb_src;
    wire arithmetic_set,auipc_or_lui,r_i_op,auipc,is_jump,b_src,adr_adder_a,is_branch,rf_wb,mem_we,pc_src;
    //control signal assignments
    wire adr_a,r_i_op_except_srai;
    assign adr_a = (opcode == 7'b011_0111);
    
    assign rs2 = instruction[24:20];
    assign rs1 = adr_a ? 5'b0 : instruction[19:15]; 
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign opcode = instruction[6:0];
    assign funct7 = instruction[31:25];
    
    assign r_i_op_except_srai = r_i_op & ~(funct3 == 3'b101);
    assign funct7_masked = funct7 & {1'b1,~ (r_i_op_except_srai | auipc_or_lui) ,5'b1_1111} | {1'b0,(is_branch | arithmetic_set),5'b0_0000};
    //{b_src,adr_adder_a,is_branch,rf_wb,mem_we,wb_src,pc_src,rd,funct3,funct7};
    assign control_word_dec = {arithmetic_set,auipc_or_lui,r_i_op,auipc,is_jump,b_src,adr_adder_a,is_branch,rf_wb,mem_we,wb_src,pc_src,rd,funct3,funct7_masked};
    //hazard bus decontruction
    wire rs1_ex_hazard,rs2_ex_hazard,rs1_mem_hazard,rs2_mem_hazard,load_raw_wb_dec_rs1,load_raw_wb_dec_rs2;
    wire raw_dec_wb_a,raw_dec_wb_b;
    wire [2:0]raw_dec_a,raw_dec_b;
    wire [1:0]hazard_sel_a,hazard_sel_b;
    
    assign {rs1_ex_hazard,rs2_ex_hazard,rs1_mem_hazard,rs2_mem_hazard} = RAW_hazards;
    assign {load_raw_wb_dec_rs1,load_raw_wb_dec_rs2} = RAW_mem_wb_hazards;
    assign raw_dec_wb_a = ~(wadr==5'b00000) & we_valid & we_wb & !adr_a &(rs1 == wadr);
    assign raw_dec_wb_b = ~(wadr==5'b00000) & we_valid & we_wb & (rs2 == wadr);
    assign reg_a_val = raw_dec_wb_a ? wb_data : reg_a_val_raw;
    assign reg_b_val = raw_dec_wb_b ? wb_data : reg_b_val_raw;
    //raw_ex_dec_rs1,raw_ex_dec_rs2,raw_mem_dec_rs1,raw_mem_dec_rs2
    //assign {raw_ex_dec_rs1,raw_ex_dec_rs2,raw_mem_dec_rs1,raw_mem_dec_rs2} = RAW_mem_hazards;
    assign raw_dec_a = {load_raw_wb_dec_rs1,rs1_mem_hazard,rs1_ex_hazard};
    assign raw_dec_b = {load_raw_wb_dec_rs2,rs2_mem_hazard,rs2_ex_hazard};
    
    HazardEncoder enc1 (raw_dec_a,hazard_sel_a);
    HazardEncoder enc2 (raw_dec_b,hazard_sel_b);
    
    DecodeControlword controlworddecoder(
        .funct3(funct3),
        .opcode(opcode),
        .b_src(b_src),
        .adr_adder_a(adr_adder_a),
        .is_branch(is_branch),
        .rf_wb(rf_wb),
        .mem_we(mem_we),
        .wb_src(wb_src),
        .pc_src(pc_src),
        .jump(is_jump),
        .auipc(auipc),
        .r_i_op(r_i_op),
        .auipc_or_lui(auipc_or_lui),
        .arithmetic_set(arithmetic_set)
    );
    
    RegFile rf(
        .clk(clk),
        .rst(rst),
        .rd_addr0(rs1),
        .rd_addr1(rs2),
        .wr_addr0(wadr),
        .wr_din0(wb_data),
        .we0(we_wb),
        .rd_dout0(reg_a_val_raw),
        .rd_dout1(reg_b_val_raw)
    );
    InstTypeDecoder inst_type_dec(
    .op_code(opcode),
    .op_type(op_type)
    );
    ImmExtender im_dec(
        .inst(instruction),
        .op_type(op_type),
        .imm_out(extended_imm)
    );
    //control to DP connections
    assign imm = extended_imm;
    assign pc_dec = pc_if;
    assign pc_plus_4_dec = pc_plus_4_if;
    FourtoOneMux mux1(hazard_sel_a,reg_a_val,wb_data,execute_data,memory_data,regfilea);
    FourtoOneMux mux2(hazard_sel_b,reg_b_val,wb_data,execute_data,memory_data,regfileb);
    assign rs1_o = rs1;
    assign rs2_o = rs2;
endmodule

module DecodeControlword(
        input wire [2:0]funct3,
        input wire [6:0]opcode,
        output wire b_src,
        output wire adr_adder_a,
        output wire is_branch,
        output wire rf_wb,
        output wire mem_we,
        output wire [1:0]wb_src,
        output wire pc_src,
        output wire jump,
        output wire auipc,
        output wire r_i_op,
        output wire auipc_or_lui,
        output wire arithmetic_set
    );
    wire lui,mem,mem_load,arithmetic,is_control,adr_a,is_control_expect_jalr;
    //internal control signals
    assign lui = (opcode == 7'b011_0111);
    assign mem = (opcode == 7'b000_0011) | (opcode == 7'b010_0011);
    assign arithmetic = (opcode == 7'b011_0011) | (opcode == 7'b001_0011);
    assign mem_load = (opcode == 7'b000_0011);
    assign is_control_expect_jalr = (opcode == 7'b110_0011) | (opcode == 7'b110_1111);
    assign is_control = adr_adder_a | (opcode == 7'b110_0111);
    //control signal assignments
    assign arithmetic_set = arithmetic & ((funct3 == 3'b010)| (funct3 == 3'b011));
    assign auipc_or_lui = auipc | lui;
    assign r_i_op = (opcode == 7'b001_0011);
    assign auipc = (opcode == 7'b001_0111);
    assign b_src =r_i_op | mem | lui;
    assign adr_adder_a = is_control_expect_jalr | auipc;
    assign is_branch = (opcode == 7'b110_0011);
    assign rf_wb = arithmetic | mem_load | jump | lui | auipc;
    assign mem_we = (opcode == 7'b010_0011);
    assign wb_src = {mem_load,arithmetic};
    assign pc_src = jump;
    assign jump = (opcode == 7'b110_1111) | (opcode == 7'b110_0111);
endmodule

module FourtoOneMux(
    input wire [1:0]sel,
    input wire [31:0]a,b,c,d,
    output wire [31:0]y
);
    reg [31:0]selection;
    always @(*) begin
        case(sel)
            2'b00:  selection = a;
            2'b01:  selection = b;
            2'b10:  selection = c;
            2'b11:  selection = d;
        endcase
    end
    assign y = selection;
endmodule

module HazardEncoder(
    input wire [2:0]hazards,
    output wire [1:0]mux_sel
);
    wire load_raw_wb_dec,mem_hazard,ex_hazard;
    assign {load_raw_wb_dec,mem_hazard,ex_hazard} = hazards;
    reg [1:0]sel;
    always @(*) begin
        if (load_raw_wb_dec)
            sel = 2'b00;
        else begin
            casez(hazards[1:0])
                2'b00:   sel = 2'b00;
                2'b?1:   sel = 2'b10;
                2'b10:   sel = 2'b11;
                default: sel = 2'b00;
            endcase
        end
    end
    assign mux_sel = sel;
endmodule