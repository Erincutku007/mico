`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 03:08:27 PM
// Design Name: 
// Module Name: WriteBackStage
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


module WriteBackStage(
        input wire [31:0] mem_data_out,ALU_result_mem,
        input wire [8:0]control_word_mem,
        output wire wb_rf_wb,
        output wire [4:0] wb_rd,
        output wire [31:0] wb_data
    );
    wire rf_wb,pc_src,wb_pc_src;
    wire [1:0] wb_src;
    wire [4:0] rd;
    reg [31:0] selected_data;
    assign {rf_wb,wb_src,pc_src,rd} = control_word_mem;
    always@(*) begin
        case(wb_src)
        2'b00: selected_data = ALU_result_mem;
        2'b01: selected_data = ALU_result_mem;
        2'b10: selected_data = mem_data_out;
        default: selected_data = 32'b0; 
        endcase 
    end
    
    assign wb_rd = rd;
    assign wb_pc_src = pc_src;
    assign wb_rf_wb = rf_wb;
    assign wb_data = selected_data;
endmodule
