module msxusb (in_a7_a0,in_a15_a13_a12,data,iorq_n,rd_n,wr_n,sltsl_n,reset_n,cs_ch376s_n,busdir,out_a13_a18);
	input [7:0] in_a7_a0;
	input [2:0] in_a15_a13_a12;
	input [5:0] data;
	input iorq_n,rd_n,wr_n,sltsl_n,reset_n;
	
	output cs_ch376s_n;
	output busdir;
	output [5:0] out_a13_a18;
	
	ch376 CH376 (in_a7_a0,iorq_n,rd_n,cs_ch376s_n,busdir);
	scc_rom_mapper ROM_MAPPER (rd_n,wr_n,sltsl_n,reset_n,in_a15_a13_a12,data,out_a13_a18);
endmodule

module ch376 (io_address,iorq_n,rd_n,cs_ch376s_n,busdir);
	input [7:0] io_address;
	input iorq_n,rd_n;
	output cs_ch376s_n;
	output busdir;

	assign cs_ch376s_n = !(((io_address == 8'h10)||(io_address == 8'h11)) && iorq_n==0);
	assign busdir = cs_ch376s_n || rd_n;
endmodule

/*
Page (8kB)							Switching address				Initial segment
4000h~5FFFh (mirror: C000h~DFFFh)	5000h (mirrors: 5001h~57FFh)	0
6000h~7FFFh (mirror: E000h~FFFFh)	7000h (mirrors: 7001h~77FFh)	1
8000h~9FFFh (mirror: 0000h~1FFFh)	9000h (mirrors: 9001h~97FFh)	2
A000h~BFFFh (mirror: 2000h~3FFFh)	B000h (mirrors: B001h~B7FFh)	3
*/
module scc_rom_mapper (rd_n,wr_n,sltsl_n,reset_n,a15_a13_a12,data,address_upper);
	input [2:0] a15_a13_a12;
	input [5:0] data;
	input rd_n,wr_n,sltsl_n,reset_n;
	
	output reg [5:0] address_upper = 0;
	
	// 4*6 bits storage
	reg [5:0] mem0;
	reg [5:0] mem1;
	reg [5:0] mem2;
	reg [5:0] mem3;

	initial begin
		mem0 = 6'b000000;
		mem1 = 6'b000001;
		mem2 = 6'b000010;
		mem3 = 6'b000011;
	end

	wire WE;
	assign WE = !reset_n || (!sltsl_n && !wr_n);

	wire ADDR_SEL;
	assign ADDR_SEL = !sltsl_n && (!wr_n || !rd_n);

	// read memory
	////////////////////////
	always @(posedge ADDR_SEL) begin
		// always select correct bank when reading or writing
		case(a15_a13_a12[2:1])
			2'b00: address_upper = mem0;
			2'b01: address_upper = mem1;
			2'b10: address_upper = mem2;
			2'b11: address_upper = mem3;
		endcase   
	end
	// write memory
	//////////////////
	always @(posedge WE) begin
		if (!reset_n) begin
			mem0 = 6'b000000;
			mem1 = 6'b000001;
			mem2 = 6'b000010;
			mem3 = 6'b000011;
		end
		if (!sltsl_n) begin
			// store only when upper 4k is selected
			case(a15_a13_a12)
				3'b001: mem0 = data;
				3'b011: mem1 = data;
				3'b101: mem2 = data;
				3'b111: mem3 = data;
				default: ;
			endcase   
		end
	end
endmodule




