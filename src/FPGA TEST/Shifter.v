`timescale 1ns / 1ps

module Shifter(
        input wire signed [31:0]a,
        input wire signed [4:0]b,
        input wire mode,
        input wire sel,
        output wire signed [31:0]y
    );
    wire [31:0] right_shift, left_shift;

    assign right_shift = mode ? a >>> b :  a >> b;
    assign left_shift = a << b;

    assign y = sel ? right_shift : left_shift;

endmodule
