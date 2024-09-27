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

//B'yi reg'de tut ve devreye oyle sok cok fazla routing delay var
module NonrestroingDivide(
    input wire clk,reset,valid,flush_ex,
    input wire [2:0]funct3,
    input wire [31:0]a,b,
    output reg [31:0]y,rem,
    output wire done
    );
    wire s_i_sign,b_sign,a_sign,first_bit,q_next,q_en,lenght_carry,a_lower_b,divide_by_one,s_i_co,b_is_one,divide_by_zero,counter_is_zero,overflow;
    wire [4:0] a_zeros,b_zeros,a_data_lenght,b_data_lenght,b_data_lenght_neg,data_lenght_diff;
    wire [5:0] counter_threshold_calculated,counter_threshold_calculated_reg,counter_threshold,count_val,count_next;
    wire [31:0] a_shifted,b_shifted_reg_in,b_shifted,correction_amt,q,y_calculated,rem_correction_amt,rem_unshifted_corrected,q_uncorrected;
    wire [33:0] s_i_next,s_i,b_shifted_extended,s_i_unshifted,adder_op2;
    
    assign b_is_one = (b == 32'd1);
    
    PriorityEncoder32 a_pri_enc(a,a_zeros);
    PriorityEncoder32 b_pri_enc(b,b_zeros);
    
    assign a_shifted = a << a_zeros;
    assign b_shifted_reg_in = b << b_zeros;
   
    assign a_data_lenght = (5'd31-a_zeros);
    assign b_data_lenght = (5'd31-b_zeros);
    assign b_data_lenght_neg = ~b_data_lenght +5'd1;
    assign {lenght_carry,data_lenght_diff} = a_data_lenght + b_data_lenght_neg;
    assign a_lower_b = ~lenght_carry;
    
    assign counter_threshold_calculated_reg = a_lower_b ? 6'd2 : ({1'b0,data_lenght_diff} + 6'd3);
    assign counter_is_zero = (count_val == 6'd0);
    assign counter_threshold = counter_is_zero ? 6'd10 : counter_threshold_calculated;
    
    assign divide_by_one = (b == 32'd1);
    assign divide_by_zero = (b == 32'b0);
    
    FFSyncReset #(34) s_i_reg(
        .clk(clk),
        .reset(reset),
        .syn_reset(done | !valid | flush_ex),
        .d(s_i_next),
        .q(s_i)
    );
    
    FFSyncReset #(32) b_shifted_reg(
        .clk(clk),
        .reset(reset),
        .syn_reset(done | !valid | flush_ex),
        .d(b_shifted_reg_in),
        .q(b_shifted)
    );
    
    FFSyncReset #(6) threshold_reg(
        .clk(clk),
        .reset(reset),
        .syn_reset(done | !valid | flush_ex),
        .d(counter_threshold_calculated_reg),
        .q(counter_threshold_calculated)
    );
    
    Counter count(
    .reset(reset),
    .clk(clk),
    .syn_reset(!valid | flush_ex),
    .threshold(counter_threshold),
    .done(done),
    .count(count_val),
    .count_next(count_next)
    );
    
    ShiftRegister #(34) q_reg(
        .clk(clk),
        .reset(reset),
        .syn_reset(done | !valid | flush_ex),
        .en(q_en),
        .d_serial(q_next),
        .q(q)
    );
    
    assign s_i_sign = s_i[33];
    assign b_sign = 1'b0;
    assign a_sign = 1'b0;
    
    assign b_shifted_extended = { 2'b00 , b_shifted};
    assign adder_op2 = (s_i_sign == b_sign) ? -b_shifted_extended : b_shifted_extended;
    assign {s_i_co,s_i_unshifted} = s_i + adder_op2;
    assign s_i_next = (!q_en) ? {2'b0,a_shifted} : (s_i_unshifted << 1);
    
    assign first_bit = (count_val == 6'd1);
    assign q_next = first_bit ^ (s_i_sign == b_sign);
    assign q_en = (count_val != 0);
    
    assign correction_amt = {32{s_i_sign}};
    assign q_uncorrected = {q[30:0],1'b1};
    assign y_calculated = a_lower_b ? 32'b0 : q_uncorrected + correction_amt;
    
    assign overflow = (a == 32'h80000000) & (b == 32'hFF_FF_FF_FF) & (funct3[1:0] == 0);
    
    always_comb begin
        if (divide_by_zero)
            y = 32'hFFFFFFFF;
        else if (divide_by_one) 
            y = a;
        else
            y = y_calculated;
    end
    
    assign rem_correction_amt = s_i_sign ? b_shifted : 0 ;
    assign rem_unshifted_corrected = (s_i>>>1) + rem_correction_amt;
    
    always_comb begin
        if (divide_by_one | (a == 0))
            rem = 0;
        else if (a_lower_b | (b == 0)) 
            rem = a;
        else
            rem = (rem_unshifted_corrected >> (b_zeros));
    end
endmodule
