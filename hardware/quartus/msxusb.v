module msxusb (in_a7_a0,in_a15_a13,data,iorq_n,rd_n,wr_n,sltsl_n,reset_n,cs_ch376s_n,busdir,out_a13_a18);
	input [7:0] in_a7_a0;
	input [1:0] in_a15_a13;
	input [5:0] data;
	input iorq_n,rd_n,wr_n,sltsl_n,reset_n;
	
	output cs_ch376s_n;
	output busdir;
	output [5:0] out_a13_a18;
	
	ch376 CH376 (in_a7_a0,iorq_n,rd_n,cs_ch376s_n,busdir);
	scc_rom_mapper ROM_MAPPER (wr_n,sltsl_n,reset_n,in_a15_a13,data,out_a13_a18);
endmodule

module ch376 (io_address,iorq_n,rd_n,cs_ch376s_n,busdir);
	input [7:0] io_address;
	input iorq_n,rd_n;
	output cs_ch376s_n;
	output busdir;

	assign cs_ch376s_n = !((io_address == 8'h10) && iorq_n==0);
	assign busdir = cs_ch376s_n || rd_n;
endmodule

// Testbench Code Goes here
module t_ch376;
	reg [7:0] address;
	reg iorq_n, rd_n;
	reg [2:0] i;
	wire busdir, cs;
	
	ch376 TST (address,iorq_n,rd_n,cs,busdir);
	
	initial
	begin
		address = 17;
		iorq_n = 0;
		rd_n = 0;
		$monitor(address,iorq_n,rd_n,busdir,cs);
		for (i = 0; i < 4; i = i + 1) begin
			{iorq_n,rd_n} = i;
			#10;
		end
		address = 16;
		for (i = 0; i < 4; i = i + 1) begin
			{iorq_n,rd_n} = i;
			#10;
		end
	end
endmodule
/*
Page (8kB)									Switching address					Initial segment
4000h~5FFFh (mirror: C000h~DFFFh)	5000h (mirrors: 5001h~57FFh)	0
6000h~7FFFh (mirror: E000h~FFFFh)	7000h (mirrors: 7001h~77FFh)	1
8000h~9FFFh (mirror: 0000h~1FFFh)	9000h (mirrors: 9001h~97FFh)	2
A000h~BFFFh (mirror: 2000h~3FFFh)	B000h (mirrors: B001h~B7FFh)	3
*/
module scc_rom_mapper (wr_n,sltsl_n,reset_n,a15_a13,data,address_upper);
	input [1:0] a15_a13;
	input wr_n,sltsl_n,reset_n;
	input [5:0] data;
	
	output reg [5:0] address_upper = 0;
	
	// 4-byte storage
	reg [5:0] mem0 = 6'b000000;
	reg [5:0] mem1 = 6'b000001;
	reg [5:0] mem2 = 6'b000010;
	reg [5:0] mem3 = 6'b000011;
	
	always @ (sltsl_n or wr_n or a15_a13 or reset_n) begin
		// back to defaults when reset
		if (!reset_n) begin
			 mem0 <= 6'b000000;
			 mem1 <= 6'b000001;
			 mem2 <= 6'b000010;
			 mem3 <= 6'b000011;
		end
		// write new value
		if (!sltsl_n) begin
		  if (!wr_n) begin
			  if (a15_a13 == 2'b00) begin
				  mem0 <= data;
			  end
			  if (a15_a13 == 2'b01) begin
				  mem1 <= data;
			  end
			  if (a15_a13 == 2'b10) begin
				  mem2 <= data;
			  end
			  if (a15_a13 == 2'b11) begin
				  mem3 <= data;
			  end
			end else begin
			  if (a15_a13 == 2'b00) begin
			    address_upper <= mem0;
		     end
		     if (a15_a13 == 2'b01) begin
			    address_upper <= mem1;
		     end
		     if (a15_a13 == 2'b10) begin
			    address_upper <= mem2;
		     end
		     if (a15_a13 == 2'b11) begin
			    address_upper <= mem3;
		     end
			end
		end
	end
endmodule

module t_scc_rom_mapper;
	wire [5:0] address_upper;
	reg wr_n,sltsl_n,reset_n;
	reg [5:0] data;
	reg [1:0] a15_a13;
	reg [4:0] i;
	
	scc_rom_mapper TST (wr_n,sltsl_n,reset_n,a15_a13,data,address_upper);
	
	initial
	begin
	  $monitor(wr_n,sltsl_n,reset_n,a15_a13,data,address_upper);
		wr_n = 1;
		sltsl_n = 1;
		reset_n = 1;
		#5;
		// check init state
		wr_n = 1; // RD
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			#5;
		end
		// write data
		wr_n = 0;
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			data = i*4;
			#5;
		end
		// read back memory
		wr_n = 1; // RD
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			#5;
		end
		reset_n = 0;
		#5;
		reset_n = 1;
		#5;
		// read back memory
		wr_n = 1; // RD
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			#5;
		end
		// when this slot is not selected
		// write data
		wr_n = 0;
		sltsl_n = 1; // this slot NOT selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			data = i;
			#5;
		end
		// read back memory
		wr_n = 1; // RD
		sltsl_n = 1; // this slot NOT selected
		for (i = 0; i < 4; i = i + 1) begin
			a15_a13 = i;
			#5;
		end
	end
endmodule
