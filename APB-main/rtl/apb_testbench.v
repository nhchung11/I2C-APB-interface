module apb_testbench;

	parameter ADDRESSWIDTH= 4;
	parameter DATAWIDTH= 32;
	
	reg PCLK;
	reg PRESETn;
	reg [ADDRESSWIDTH-1:0]PADDR;
	reg [DATAWIDTH-1:0] PWDATA;
	reg PWRITE;
	reg PSELx;
	reg PENABLE;
	wire [DATAWIDTH-1:0] PRDATA;
	wire PREADY;
	reg clk;
	wire i2c_sda;
	wire i2c_scl;

	apb_slave dut(
		.PCLK(PCLK), 
		.PRESETn(PRESETn), 
		.PADDR(PADDR), 
		.PWDATA(PWDATA), 
		.PWRITE(PWRITE), 
		.PSELx(PSELx), 
		.PENABLE(PENABLE), 
		.PRDATA(PRDATA),
		.PREADY(PREADY)
	);

	initial begin
		PCLK = 0;
		forever begin
			PCLK = #5 ~PCLK;
		end		
	end
	initial begin
		clk = 0;
		forever begin
			PCLK = #5 ~PCLK;
		end		
	end
	initial begin
		PCLK = 0;
		PRESETn = 0;
		PADDR = 0;
		PWDATA = 0;
		PWRITE = 0; 
		PSELx = 0;
		PENABLE = 0;
		#5
       		PRESETn = 1;
		#13
		PADDR = 4;
		PWDATA = 8'b00001111;
		PWRITE = 1; 
		PSELx = 1;
		#10
		PENABLE = 1;
		#10
		PENABLE = 0;
		PSELx = 0;
		#200
		$finish;
	end    
endmodule
