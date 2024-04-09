`timescale 1ns / 1ps

module i2c_tb;

	// Inputs
	reg clk;
	reg i2c_reset;
	reg [6:0] addr;
	reg [7:0] i2c_data_in;
	reg i2c_enable;
	reg rw;

	// Outputs
	wire [7:0] i2c_data_out;
	wire i2c_ready;

	// Bidirs
	wire i2c_sda;
	wire i2c_scl;

	// Instantiate the Unit Under Test (UUT)
	i2c_master master (
		.clk(clk), 
		.i2c_reset(i2c_reset), 
		.addr(addr), 
		.i2c_data_in(i2c_data_in), 
		.i2c_enable(i2c_enable), 
		.rw(rw), 
		.i2c_data_out(i2c_data_out), 
		.i2c_ready(ready), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl)
	);
	
		
	
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		i2c_reset = 1;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
		i2c_reset = 0;		
		addr = 7'b0101010;
		i2c_data_in = 8'b10101010;
		rw = 0;	
		i2c_enable = 1;
		#10;
		i2c_enable = 0;
				
		#200
		$finish;
		
	end      
endmodule
