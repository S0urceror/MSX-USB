// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Sat Mar 28 20:25:40 2020"

module msxusb(
	IORQ_N,
	RD_N,
	A,
	BUSDIR,
	CS_CH376S_N
);


input wire	IORQ_N;
input wire	RD_N;
input wire	[7:0] A;
output wire	BUSDIR;
output wire	CS_CH376S_N;

wire	SYNTHESIZED_WIRE_0;

assign	CS_CH376S_N = SYNTHESIZED_WIRE_0;




IO_Busdir	b2v_inst(
	.rd_n(RD_N),
	.cs_ch376s_n(SYNTHESIZED_WIRE_0),
	.busdir(BUSDIR));


CH376s_IO_Address_Selector	b2v_inst2(
	.iorq_n(IORQ_N),
	.address_bus(A),
	.cs_ch376s_n(SYNTHESIZED_WIRE_0));


endmodule

// Testbench Code Goes here
module test;
	reg [7:0] address;
	reg iorq_n, rd_n;
	reg [2:0] i;
	wire busdir, cs;
	
	//	IORQ_N,RD_N,A,BUSDIR,CS_CH376S_N
	msxusb TST (iorq_n,rd_n,address,busdir,cs);
	
	initial
	begin
		address = 17;
		iorq_n = 0;
		rd_n = 0;
		$monitor(address,iorq_n,rd_n,busdir,cs);
		for (i = 0; i < 4; i = i + 1) begin
			#10;
			{iorq_n,rd_n} = i;
		end
		address = 16;
		for (i = 0; i < 4; i = i + 1) begin
			#10;
			{iorq_n,rd_n} = i;
		end
	end

endmodule
