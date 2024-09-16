`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 08:42:48 PM
// Design Name: 
// Module Name: SRTDivWithSkip
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


module SRTDivWithSkip(
    input wire clk,reset,
    input wire [31:0]a,b,
    output wire [31:0]y
    );
    wire done,s_i_sign,g_e_one_over_two,l_minus_one_over_two,s_i_within_range;
    wire [1:0] leading_sign_bit_amt;
    wire [3:0] encoder_input;
    wire [4:0] a_zeros,b_zeros,counter_threshold,count_next,remaining_iterations;
    wire [31:0] a_shifted,b_shifted,s_i;
    PriorityEncoder32 a_pri_enc(a,a_zeros);
    PriorityEncoder32 b_pri_enc(b,b_zeros);
    
    assign a_shifted = a << a_zeros - 5'd1;
    assign b_shifted = b << b_zeros - 5'd1;
    
    assign counter_threshold = (5'd31-a_zeros) - (5'd31-b_zeros) + 5'd1;
    
    Counter count(
    .reset(reset),
    .clk(clk),
    .skip(),
    .threshold(counter_threshold),
    .skip_amt(),
    .done(),
    .count_next(count_next)
    );
    
    FFSyncReset s_i_reg(
    .clk(clk),
    .reset(reset),
    .syn_reset(),
    .d(),
    .q(s_i)
    );
    
    assign s_i_sign = s_i[31];
    assign g_e_one_over_two = (2'b01 == s_i[31:30]);
    assign l_minus_one_over_two = (2'b01 == s_i[31:30]);
    assign s_i_within_range = ~(g_e_one_over_two | l_minus_one_over_two);
    assign encoder_input = s_i_sign ? ~s_i[31:28] : s_i[31:28] ;
    
    PriorityEncoder4 skip_amt(encoder_input,leading_sign_bit_amt);
    
    remaining_iterations = counter_threshold - count_next;
    //leading_sign_bit_amt
    //92. satirdayim.
endmodule
