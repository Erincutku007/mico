`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2024 09:54:49 PM
// Design Name: 
// Module Name: CoreWithAXIIF
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


module CoreWithAXIIF(
    // {{{
		input	wire			i_clk, i_reset,
		// AXI Write Channel
		// {{{
		output	wire			M_AXI_AWVALID,
		input	wire			M_AXI_AWREADY,
		output	wire	[3:0]	M_AXI_AWADDR,
		output	wire	[2:0]	M_AXI_AWPROT,
		//
		output	wire			M_AXI_WVALID,
		input	wire			M_AXI_WREADY,
		output	wire	[31:0]	M_AXI_WDATA,
		output	wire	[3:0]	M_AXI_WSTRB,
		//
		input	wire			M_AXI_BVALID,
		output	wire			M_AXI_BREADY,
		input	wire	[1:0]	M_AXI_BRESP,
		// }}}
		// AXI Read channel
		// {{{
		output	wire			M_AXI_ARVALID,
		input	wire			M_AXI_ARREADY,
		output	wire	[3:0]	M_AXI_ARADDR,
		output	wire	[2:0]	M_AXI_ARPROT,
		//
		input	wire			M_AXI_RVALID,
		output	wire			M_AXI_RREADY,
		input	wire	[31:0]	M_AXI_RDATA,
		input	wire	[1:0]	M_AXI_RRESP
		// }}}
		// }}}
    );
    
    wire o_rsp_stb,o_cmd_busy,i_valid,i_write;
    wire [3:0]i_addr;
    wire [31:0]o_rsp_word,i_data;
    MemoryCoreWrapper core_ins(
        .clk(i_clk),
        .rst(i_reset),
        //AXI IF signals
        .o_rsp_stb(o_rsp_stb),
		.o_rsp_word(o_rsp_word),
        .o_cmd_busy(o_cmd_busy),
        .i_valid(i_valid),
		.i_write(i_write),
		.i_data(i_data),
		.i_addr(i_addr)
    );
    
    CoreAXIInterface axi_interface(
		// {{{
		.i_clk(i_clk),
		.i_reset(i_reset),
		// The input command channel
		.i_valid(i_valid),
		.i_write(i_write),
		.i_data(i_data),
		.i_addr(i_addr),
		.o_cmd_busy(o_cmd_busy),
		// The return command channel
		.o_rsp_stb(o_rsp_stb),
		.o_rsp_word(o_rsp_word),
		// AXI Write Channel
		// {{{
		.M_AXI_AWVALID(M_AXI_AWVALID),
		.M_AXI_AWREADY(M_AXI_AWREADY),
		.M_AXI_AWADDR(M_AXI_AWADDR),
		.M_AXI_AWPROT(M_AXI_AWPROT),
		//
		.M_AXI_WVALID(M_AXI_WVALID),
		.M_AXI_WREADY(M_AXI_WREADY),
		.M_AXI_WDATA(M_AXI_WDATA),
		.M_AXI_WSTRB(M_AXI_WSTRB),
		//
		.M_AXI_BVALID(M_AXI_BVALID),
		.M_AXI_BREADY(M_AXI_BREADY),
		.M_AXI_BRESP(M_AXI_BRESP),
		// }}}
		// AXI Read channel
		// {{{
		.M_AXI_ARVALID(M_AXI_ARVALID),
		.M_AXI_ARREADY(M_AXI_ARREADY),
		.M_AXI_ARADDR(M_AXI_ARADDR),
		.M_AXI_ARPROT(M_AXI_ARPROT),
		//
		.M_AXI_RVALID(M_AXI_RVALID),
		.M_AXI_RREADY(M_AXI_RREADY),
		.M_AXI_RDATA(M_AXI_RDATA),
		.M_AXI_RRESP(M_AXI_RRESP)
		// }}}
		// }}}
	);
endmodule
