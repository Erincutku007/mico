`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 04:24:07 PM
// Design Name: 
// Module Name: DivMulALUFused
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


module DivMulALUFused(
        input  wire clk,reset,mul_valid,div_valid,flush_ex,
        input  wire [31:0]a,
        input  wire [31:0]b,
        input  wire [2:0]funct3,
        output wire [31:0]res,y,
        output wire division_done,multiplication_done
    );
    
    wire [31:0]a_abs,b_abs,y_shifted;
    wire [63:0]y_unsigned,y_signed;
    wire sign,zero_result;
    wire take_abs_a_mul,take_abs_b_mul,take_abs_a_div,take_abs_b_div,take_abs_a,take_abs_b;
    //input sign logic
    assign take_abs_a_div = (a[31] & ~funct3[0]);
    assign take_abs_b_div = (b[31] & ~funct3[0]);
    
    assign take_abs_a_mul = a[31] & ~(funct3[1:0] == 2'b11);
    assign take_abs_b_mul = b[31] & ~funct3[1];
    
    assign take_abs_a = funct3[2] ? take_abs_a_div : take_abs_a_mul;
    assign take_abs_b = funct3[2] ? take_abs_b_div : take_abs_b_mul;
    
    assign a_abs = take_abs_a ? (-a) : a;
    assign b_abs = take_abs_b ? (-b) : b;
    assign zero_result = (a==32'b0) | (b==32'b0);
    
    MULPipelined mul(
    .clk(clk),
    .rst(reset),
    .valid(mul_valid),
    .flush_ex(flush_ex),
    .a(a_abs),
    .b(b_abs),
    .y(y_unsigned),
    .done(multiplication_done)
    );
    
    assign sign = take_abs_a ^ take_abs_b;
    assign y_signed = sign ? (-y_unsigned) : y_unsigned;
    assign y_shifted = |funct3[1:0] ? y_signed[63:32] : y_signed[31:0];
    assign y = zero_result ? 32'b0 : y_shifted;
    
    //div
    wire [31:0]y,rem,res_muxed,res_muxed_q;
    wire [31:0]y_abs,rem_abs;
    wire invert_y,invert_rem,invert_res,div_done,invert_res_q;
    reg state,next_state;
    
    NonrestroingDivide divide(
    .clk(clk),
    .reset(reset),
    .valid(div_valid),
    .flush_ex(flush_ex | state),
    .funct3(funct3),
    .a(a_abs),
    .b(b_abs),
    .y(y_abs),
    .rem(rem_abs),
    .done(div_done)
    );
    
//    assign invert_y = (a[31] ^ b[31]) & ~funct3[0];
//    assign invert_rem = (a[31] & ~funct3[0]);
//    assign y = invert_y ? -y_abs : y_abs ;
//    assign rem = invert_rem ? -rem_abs : rem_abs ;
//    assign res_reg_d = funct3[1] ? rem : y ;

    assign invert_y = (a[31] ^ b[31]) & ~funct3[0];
    assign invert_rem = (a[31] & ~funct3[0]);
    assign invert_res = funct3[1] ? invert_rem : invert_y ;
    assign res_muxed = funct3[1] ? rem_abs : y_abs;
//    assign res_reg_d = invert_res ? -res_muxed : res_muxed ;
    
    FlipFlopEnable  #(33) res_reg(
        .clk(clk),
        .rst(reset),
        .enable(div_done),
        .d({invert_res,res_muxed}),
        .q({invert_res_q,res_muxed_q})
    );
    assign res = invert_res_q ? -res_muxed_q : res_muxed_q ;
    
    //small microcontroller logic
    always@(posedge clk,negedge reset) begin
        if (!reset)
            state <= 0;
        else
            state <= next_state;
    end
    
    always@(*) begin
        case(state)
            1'b0: begin
                if (div_done)
                    next_state = 1'b1;
                else
                    next_state = 1'b0;
            end
            1'b1: next_state = 1'b0;
        endcase
     end
     assign division_done = state;
    
endmodule
