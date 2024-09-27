module FlipFlop  #(parameter SIZE = 32)(
        input wire clk,rst,
        input wire [SIZE-1:0]d,
        output wire [SIZE-1:0]q
    );
    reg [SIZE-1:0]register;
    always @ (posedge clk or negedge rst) begin
        if (~rst)
            register <= 0;
        else
            register <= d;
    end
    assign q = register;
endmodule

module FlipFlopEnable  #(parameter SIZE = 32)(
        input wire clk,rst,enable,
        input wire [SIZE-1:0]d,
        output wire [SIZE-1:0]q
    );
//    assign q = d;
    reg [SIZE-1:0]register;
    always @ (posedge clk or negedge rst) begin
        if (~rst)
            register <= 0;
        else begin
                if (enable)
                    register <= d;
            end
    end
    assign q = register;
endmodule