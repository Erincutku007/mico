////////////////////////////////////////////////////////////////////////////////
//
// Filename:	hbexecaxi.v
// {{{
// Project:	dbgbus, a collection of 8b channel to WB bus debugging protocols
//
// Purpose:	This core is identical to hbexec, save that it issues a command
//		over an AXI-lite bus rather than a WB bus.
//
//	As with the hbexec, basic bus commands are:
//
//	2'b00	Read
//	2'b01	Write (lower 32-bits are the value to be written)
//	2'b10	Set address
//		Next 30 bits are the address
//		bit[1] is an address difference bit
//		bit[0] is an increment bit
//	2'b11	Special command
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2017-2024, Gisselquist Technology, LLC
// {{{
// This file is part of the hexbus debugging interface.
//
// The hexbus interface is free software (firmware): you can redistribute it
// and/or modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// The hexbus interface is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
// for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
// }}}
// License:	LGPL, v3, as defined and found on www.gnu.org,
// {{{
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
`default_nettype	none
// }}}
module	CoreAXIInterface(
		// {{{
		input	wire			i_clk, i_reset,
		// The input command channel
		input	wire			i_valid,
		input   wire            i_write,
		input	wire	  [31:0]i_data,
		input   wire          [3:0]i_addr,
		output	wire			o_cmd_busy,
		// The return command channel
		output	reg			o_rsp_stb,
		output	reg	[31:0]	o_rsp_word,
		// AXI Write Channel
		// {{{
		output	reg			M_AXI_AWVALID,
		input	wire			M_AXI_AWREADY,
		output	reg	    [3:0]	M_AXI_AWADDR,
		output	wire	[2:0]		M_AXI_AWPROT,
		//
		output	reg			M_AXI_WVALID,
		input	wire			M_AXI_WREADY,
		output	reg	[31:0]	M_AXI_WDATA,
		output	wire	[3:0]		M_AXI_WSTRB,
		//
		input	wire			M_AXI_BVALID,
		output	reg			M_AXI_BREADY,
		input	wire	[1:0]		M_AXI_BRESP,
		// }}}
		// AXI Read channel
		// {{{
		output	reg			M_AXI_ARVALID,
		input	wire			M_AXI_ARREADY,
		output	wire	[3:0]	M_AXI_ARADDR,
		output	wire	[2:0]		M_AXI_ARPROT,
		//
		input	wire			M_AXI_RVALID,
		output	reg			M_AXI_RREADY,
		input	wire	[31:0]	M_AXI_RDATA,
		input	wire	[1:0]		M_AXI_RRESP
		// }}}
		// }}}
	);


	//
	//
	reg	[31:0]	rsp_word;
    wire           i_cmd_stb;
	//
	// Decode our input commands
	//
	
	stable_to_strobe strobe_gen(
        .clk(i_clk),
        .rst(!i_reset),
        .d(i_valid),
        .q(),
        .strobe(i_cmd_stb)
    );
	
	wire	i_cmd_wr, i_cmd_rd;
	assign	i_cmd_rd   = (i_cmd_stb && !o_cmd_busy) && !i_write;
	assign	i_cmd_wr   = (i_cmd_stb && !o_cmd_busy) && i_write;

	// AWVALID, WVALID, BREADY
	// {{{
	initial	M_AXI_AWVALID = 0;
	initial	M_AXI_WVALID = 0;
	initial	M_AXI_BREADY = 0;

	always @(posedge i_clk ,negedge i_reset)
	if (!i_reset)
	begin
		M_AXI_AWVALID <= 0;
		M_AXI_WVALID  <= 0;
		M_AXI_BREADY <= 0;
		//
	end else if (M_AXI_BREADY)
	begin
		// We are waiting on a return
		if (M_AXI_BVALID)
			M_AXI_BREADY <= 0;

		if (M_AXI_AWREADY)
			M_AXI_AWVALID <= 0;
		if (M_AXI_WREADY)
			M_AXI_WVALID <= 0;
	end else if (i_cmd_wr)
	begin
		M_AXI_AWVALID <= 1;
		M_AXI_WVALID  <= 1;
		M_AXI_BREADY  <= 1;
	end
	// }}}

	// ARVALID, RREADY
	// {{{
	initial	M_AXI_ARVALID = 0;
	initial	M_AXI_RREADY = 0;
	always @(posedge i_clk ,negedge i_reset)
	if (!i_reset)
	begin
		M_AXI_ARVALID <= 0;
		M_AXI_RREADY <= 0;
	end else if (M_AXI_RREADY)
	begin
		// We are waiting on a return
		if (M_AXI_ARREADY)
			M_AXI_ARVALID <= 0;

		if (M_AXI_RVALID)
			M_AXI_RREADY <= 0;
	end else if (i_cmd_rd)
	begin
		M_AXI_ARVALID <= 1;
		M_AXI_RREADY  <= 1;
	end
	// }}}

	// M_AXI_AWADDR, newaddr, inc
	// {{{
	initial	M_AXI_AWADDR = 0;
	always @(posedge i_clk ,negedge i_reset)
	begin
	   if (!i_reset) 
	       M_AXI_AWADDR <= 0;
	   else
           M_AXI_AWADDR <= i_addr;
	end
	// }}}

	assign	M_AXI_ARADDR = M_AXI_AWADDR;
	assign	M_AXI_AWPROT = 0;
	assign	M_AXI_ARPROT = 0;

	assign	o_cmd_busy = M_AXI_BREADY || M_AXI_RREADY;

	// M_AXI_WDATA
	// {{{
	initial	M_AXI_WDATA = 0;
	always @(posedge i_clk ,negedge i_reset)
	if (!i_reset)
		M_AXI_WDATA <= 0;
	else if (i_cmd_wr)
		M_AXI_WDATA <= i_data;
	else if (M_AXI_WREADY)
		M_AXI_WDATA <= 0;
	// }}}

	assign	M_AXI_WSTRB = -1;

	// rsp_word
	// {{{
	always @(*)
	begin
		rsp_word = 0;

		if (M_AXI_BVALID)
		begin
			if (M_AXI_BRESP[1])
				rsp_word[31:30] = M_AXI_BRESP;
		end

		if (M_AXI_RVALID)
		begin
			if (M_AXI_RRESP[1])
				rsp_word[31:30] = M_AXI_RRESP;
			else
				rsp_word[7:0] = M_AXI_RDATA;
		end
	end
	// }}}

	// o_rsp_stb, o_rsp_word
	// {{{
	initial	o_rsp_stb = 1'b0;
	initial	o_rsp_word = 0;
	always @(posedge i_clk ,negedge i_reset)
	if (!i_reset)
	begin
		o_rsp_stb <= 1'b0;
		o_rsp_word <= 0;
	end else begin
		o_rsp_stb  <= 0;
		o_rsp_word <= 0;

		if (M_AXI_BVALID || M_AXI_RVALID)
			o_rsp_stb <= 1;

		o_rsp_word <= rsp_word;

//		if ((!M_AXI_BVALID && !M_AXI_RVALID) && ((!i_cmd_rd && !i_cmd_wr)))
//			o_rsp_word <= 0;
	end
	// }}}
////////////////////////////////////////////////////////////////////////////////
endmodule