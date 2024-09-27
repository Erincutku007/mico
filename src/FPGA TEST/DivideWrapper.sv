`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 11:57:51 PM
// Design Name: 
// Module Name: DivideWrapper
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


module DivideWrapper(
        input  wire clk,reset,valid,flush_ex,
        input  wire [31:0]a,
        input  wire [31:0]b,
        input  wire [2:0]funct3,
        output wire [31:0]res, 
        output wire done
    );
    wire [31:0]y,rem,res_muxed,res_muxed_q;
    wire [31:0]a_abs,b_abs,y_abs,rem_abs;
    wire invert_y,invert_rem,invert_res,div_done,invert_res_q;
    reg state,next_state;
    
    assign a_abs = (a[31] & ~funct3[0]) ? -a : a;
    assign b_abs = (b[31] & ~funct3[0]) ? -b : b;
    
    NonrestroingDivide divide(
    .clk(clk),
    .reset(reset),
    .valid(valid),
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
    always_ff@(posedge clk,negedge reset) begin
        if (!reset)
            state <= 0;
        else
            state <= next_state;
    end
    
    always_comb begin
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
     assign done = state;
endmodule
