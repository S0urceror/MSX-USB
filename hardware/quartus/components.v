module CH376s_IO_Address_Selector (address_bus,iorq_n,rd_n,cs_ch376s_n,busdir);
	input iorq_n,rd_n;
	input [7:0] address_bus;
	output cs_ch376s_n;
	output busdir;

	assign cs_ch376s_n = !((address_bus == 8'h10) & iorq_n==0);
	assign busdir = cs_ch376s_n | rd_n;
endmodule

// Testbench Code Goes here
module test_components;
	reg [7:0] address;
	reg iorq_n, rd_n;
	reg [2:0] i;
	wire busdir, cs;
	
	//	IORQ_N,RD_N,A,BUSDIR,CS_CH376S_N
	CH376s_IO_Address_Selector TST (address,iorq_n,rd_n,cs,busdir);
	
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