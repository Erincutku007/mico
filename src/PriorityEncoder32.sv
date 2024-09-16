`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2024 05:49:29 PM
// Design Name: 
// Module Name: PriorityEncoder46
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


module PriorityEncoder32(
    input wire [31:0]data,
    output wire [4:0] index
    );
    wire [2:0] pe0_o,pe1_o,pe2_o,pe3_o;
    PriorityEncoder8 pe0(
    .data(data[7:0]),
    .index(pe0_o)
    );
    PriorityEncoder8 pe1(
    .data(data[15:8]),
    .index(pe1_o)
    );
    PriorityEncoder8 pe2(
    .data(data[23:16]),
    .index(pe2_o)
    );
    PriorityEncoder8 pe3(
    .data(data[31:24]),
    .index(pe3_o)
    );
    wire [3:0]datas_reduced = {|data[31:24],|data[23:16], |data[15:8], |data[7:0]};
    wire [3:0]pe3_data = {((pe3_o!=3'b0) | data[31])& datas_reduced[3],((pe2_o!=3'b0) | data[23])& datas_reduced[2],((pe1_o!=3'b0) | data[15]) & datas_reduced[1], ((pe0_o!=3'b0) | data[7])& datas_reduced[0]};
    reg [2:0]last_bits;
    reg [1:0]selection;
    
    always_comb begin // this is a priority encdoer that can be instantianised but I wanted to see the logic
        casex(pe3_data)
            4'b1XXX: selection = 2'b00; // 
            4'b01XX: selection = 2'b01; // 
            4'b001X: selection = 2'b10; //
            4'b0001: selection = 2'b11; // 
        endcase
    end
    
    always_comb begin
        case(selection)
            2'd0: last_bits = pe3_o;
            2'd1: last_bits = pe2_o; 
            2'd2: last_bits = pe1_o; 
            2'd3: last_bits = pe0_o;
        endcase
    end
    assign index = {selection,last_bits};
endmodule