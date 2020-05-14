module t_scc_rom_mapper;
	wire [5:0] address_upper;
	reg rd_n,wr_n,sltsl_n,reset_n;
	reg [5:0] data;
	reg [2:0] a15_a13_a12;
	reg [4:0] i;
	
	scc_rom_mapper TST (rd_n,wr_n,sltsl_n,reset_n,a15_a13_a12,data,address_upper);
	
	initial
	begin
		$dumpfile("mapper.lxt");
		$dumpvars(0,t_scc_rom_mapper);

	  	$monitor("sltsl:%b, wr:%b, range: %bx%b%b, in: %d, out: %d",sltsl_n,wr_n,a15_a13_a12[2],a15_a13_a12[1],a15_a13_a12[0],data,address_upper);
		wr_n = 1;
		rd_n = 1;
		sltsl_n = 1;
		reset_n = 1;
		#5;
		
		// check init state
		$display ("\nshow init state");
		wr_n = 1;
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 8; i = i + 1) begin
			a15_a13_a12 = i;
			rd_n = 0;
			#5;
			rd_n = 1;
			#5;
		end
		sltsl_n = 1;
		rd_n = 1;
		#5;
		// write data
		$display ("\nwrite new data in register");
        sltsl_n = 0; // this slot selected
		for (i = 0; i < 8; i = i + 1) begin
            // write to register
			wr_n = 0;
			a15_a13_a12 = i;
			data = i+8;
			#5;
			wr_n = 1;
			rd_n = 0;
			a15_a13_a12 = i & 3'b110;
			#5;
			rd_n = 1;
			#5;
			a15_a13_a12 = i;
			rd_n = 0;
			#5;
			rd_n = 1;
			#5;
		end
		// when this slot is not selected
		// write data
		$display ("\nwrite without slot selected");
		wr_n = 0;
		rd_n = 1;
		sltsl_n = 1; // this slot NOT selected
		for (i = 0; i < 8; i = i + 1) begin
			a15_a13_a12 = i;
			data = i;
			#5;
		end
		// read back memory
		$display ("\nread without slot selected");
		wr_n = 1; // RD
		rd_n = 0;
		sltsl_n = 1; // this slot NOT selected
		for (i = 0; i < 8; i = i + 1) begin
			a15_a13_a12 = i;
			#5;
		end
        $display ("\nreset");
		reset_n = 0;
		#5;
		reset_n = 1;
		#5;
        // read back memory
		$display ("\nread");
		wr_n = 1;
		sltsl_n = 0; // this slot selected
		for (i = 0; i < 8; i = i + 1) begin
			a15_a13_a12 = i;
			rd_n = 0;
			#5;
			rd_n = 1;
			#5;
		end
		sltsl_n = 1;
		rd_n = 1;
		#5;
	end
endmodule