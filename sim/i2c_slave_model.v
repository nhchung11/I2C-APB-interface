`timescale 1ns/1ns
module i2c_slave_model (scl, sda);
	parameter I2C_ADR = 7'b001_0000;

	input scl;
	inout sda;

	wire debug = 1'b1;

	reg [7:0] mem [2:0]; // initiate memory
	reg [7:0] mem_adr;   // memory address
	reg [7:0] mem_do;    // memory data output

	// always @* begin
	// 	saved_data = mem;
	// end

	reg sta, d_sta;
	reg sto, d_sto;

	reg [7:0] sr;        // 8bit shift register
	reg       rw;        // read/write direction

	wire      my_adr;    // my address called ??
	wire      i2c_reset; // i2c-statemachine reset
	reg [2:0] bit_cnt;   // 3bit downcounter
	wire      acc_done;  // 8bits transfered
	reg       ld;        // load downcounter

	reg       sda_o;     // sda-drive level
	wire      sda_dly;   // delayed version of sda

	// statemachine declaration
	parameter idle        = 3'b000;		
	parameter slave_ack   = 3'b001;
	parameter get_mem_adr = 3'b010;
	parameter gma_ack     = 3'b011;
	parameter data        = 3'b100;
	parameter data_ack    = 3'b101;

	reg [2:0] state;
	initial
	begin
	   	sda_o = 1'b1;
	   	state = idle;
	end

	// generate shift register
	always @(posedge scl)
	  	sr <= #1 {sr[6:0],sda};

	//detect my_address
	assign my_adr = (sr[7:1] == I2C_ADR);

	always @(posedge scl)
	  	if(ld)
	    	bit_cnt <= #1 3'b111;
	  	else
	    	bit_cnt <= #1 bit_cnt - 3'h1;

	assign acc_done = !(|bit_cnt);
	assign #1 sda_dly = sda;


	//detect start condition
	always @(negedge sda)
		if(scl)
			begin
				sta   <= #1 1'b1;
				d_sta <= #1 1'b0;
				sto   <= #1 1'b0;

				if(debug)
				$display("DEBUG i2c_slave; start condition detected at \t %t", $time);
			end
		else
			sta <= #1 1'b0;

	always @(posedge scl)
	  	d_sta <= #1 sta;

	// detect stop condition
	always @(posedge sda)
		if(scl)
			begin
			sta <= #1 1'b0;
			sto <= #1 1'b1;

			if(debug)
				$display("DEBUG i2c_slave; stop condition detected at \t %t", $time);
			end
		else
			sto <= #1 1'b0;

	//generate i2c_reset signal
	assign i2c_reset = sta || sto;

	// generate statemachine
	always @(negedge scl or posedge sto)
		if (sto || (sta && !d_sta) )
			begin
				state <= #1 idle; // reset statemachine

				sda_o <= #1 1'b1;
				ld    <= #1 1'b1;
			end
		else
			begin
				// initial settings
				sda_o <= #1 1'b1;
				ld    <= #1 1'b0;

				case(state) // synopsys full_case parallel_case
					idle: // idle state
					if (acc_done && my_adr)
						begin
							state <= #1 slave_ack;
							rw <= #1 sr[0];
							sda_o <= #1 1'b0; // generate i2c_ack

							#2;
							if(debug && rw)
							$display("DEBUG i2c_slave; command byte received (read) at \t %t", $time);
							if(debug && !rw)
							$display("DEBUG i2c_slave; command byte received (write) at \t %t", $time);

							if(rw)
							begin
								mem_adr <= 0;
								mem_do <= #1 mem[0];

								if(debug)
									begin
										#2 $display("DEBUG i2c_slave; data block read %x from address %x (1)", mem_do, mem_adr);
										#2 $display("DEBUG i2c_slave; memcheck [0]=%x, [1]=%x, [2]=%x", mem[4'h0], mem[4'h1], mem[4'h2]);
									end
							end
						end

					slave_ack:
					begin
						if(rw)
							begin
								state <= #1 data;
								sda_o <= #1 mem_do[7];
							end
						else
							state <= #1 get_mem_adr;

						ld    <= #1 1'b1;
					end

					get_mem_adr: // wait for memory address
					if(acc_done)
						begin
							state <= #1 gma_ack;
							mem_adr <= #1 sr; // store memory address
							sda_o <= #1 !(sr <= 15); // generate i2c_ack, for valid address

							if(debug)
							#1 $display("DEBUG i2c_slave; address received. adr=%x, ack=%b", sr, sda_o);
						end

					gma_ack:
					begin
						state <= #1 data;
						ld    <= #1 1'b1;
					end

					data: // receive or drive data
					begin
						if(rw)
							sda_o <= #1 mem_do[7];

						if(acc_done)
							begin
								state <= #1 data_ack;
								mem_adr <= #2 mem_adr + 8'h1;
								sda_o <= #1 (rw && (mem_adr <= 15) ); // send ack on write, receive ack on read

								if(rw)
								begin
									#3 mem_do <= mem[mem_adr];

									if(debug)
										#5 $display("DEBUG i2c_slave; data block read %x from address %x (2)", mem_do, mem_adr);
								end

								if(!rw)
								begin
									mem[ mem_adr[3:0] ] <= #1 sr; // store data in memory

									if(debug)
										#2 $display("DEBUG i2c_slave; data block write %x to address %x", sr, mem_adr);
								end
							end
					end

					data_ack:
					begin
						ld <= #1 1'b1;

						if(rw)
							if(sr[0]) // read operation && master send NACK
							begin
								state <= #1 idle;
								sda_o <= #1 1'b1;
							end
							else
							begin
								state <= #1 data;
								sda_o <= #1 mem_do[7];
							end
						else
							begin
								state <= #1 data;
								sda_o <= #1 1'b1;
							end
					end

				endcase
			end

	// read data from memory
	always @(posedge scl)
		if(!acc_done && rw)
			mem_do <= #1 {mem_do[6:0], 1'b1}; // insert 1'b1 for host ack generation

	// generate tri-states
	assign sda = sda_o ? 1'bz : 1'b0;
endmodule


