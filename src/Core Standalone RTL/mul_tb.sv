`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2024 04:17:17 PM
// Design Name: 
// Module Name: mul_tb
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


module mul_tb(
    );
    integer hata,basari,product;
    logic [31:0]a,b;
    logic [63:0]y;
    MUL dut (
    .a(a),
    .b(b),
    .y(y)
    );
    initial begin
    hata = 0;
    basari = 0;
    a=32'd1234;b=32'd1234;
    #10;
    for (int i = 0; i <1000;i++)begin
        a=$urandom%10000;
        b=$urandom%10000;
        product = a*b;
        #10;
        assert (product === y)
        begin
            basari = basari+1;
        end
        else 
        begin
            hata = hata+1;
        end
    end
    #10;
    $display ("test bitti");
    $display ("basairili cikti sayisi:%d , hatali cikti sayisi:%d",basari,hata);
    end
endmodule
