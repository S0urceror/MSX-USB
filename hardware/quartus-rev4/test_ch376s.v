// Testbench Code Goes here
module t_ch376;
	reg [7:0] address;
	reg iorq_n, rd_n;
	reg [2:0] i;
	wire busdir, cs;
	
	ch376 TST (address,iorq_n,rd_n,cs,busdir);
	
	initial
	begin
		address = 8'h12;
		iorq_n = 0;
		rd_n = 0;
		$monitor(address,iorq_n,rd_n,busdir,cs);
		for (i = 0; i < 4; i = i + 1) begin
			{iorq_n,rd_n} = i;
			#10;
		end
		address = 8'h10;
		for (i = 0; i < 4; i = i + 1) begin
			{iorq_n,rd_n} = i;
			#10;
		end
		address = 8'h11;
		for (i = 0; i < 4; i = i + 1) begin
			{iorq_n,rd_n} = i;
			#10;
		end
	end
endmodule