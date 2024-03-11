module write_tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PENABLE;
    reg             PSELx;
    reg             PWRITE;
    reg [7:0]       PADDR;
    reg [7:0]       PWDATA;

    reg             sda_in;
    reg             core_clk;

    wire [7:0]      PRDATA;
    wire            PREADY;
    wire            sda_out;
    wire            scl_out;

    top_level dut
    (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .PSELx      (PSELx),
        .PWRITE     (PWRITE),
        .PENABLE    (PENABLE),
        .PADDR      (PADDR),
        .PWDATA     (PWDATA),
        .sda_in     (sda_in),
        .core_clk   (core_clk),

        .PREADY     (PREADY),
        .PRDATA     (PRDATA),
        .sda_out    (sda_out),
        .scl_out    (scl_out)
    );

    
    always #20 core_clk= ~core_clk;

	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        PRESETn = 0;
        PWRITE = 0;
        PSELx = 0;
        PENABLE = 1;
        sda_in = 1;
        core_clk = 1;
        #100;
        sda_in = 1;
        PRESETn = 1;
        PADDR = 8'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'b0;
        PENABLE = 0;

        // Prescale reg = 1
        #10;
        PADDR = 8'b00100000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd4;
        #10;
        PENABLE = 1;

        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'b11110000;
        PENABLE = 0;    
        #10;
        PENABLE = 1; 

        // Status reg = 3
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01100000;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;

        // Transmit reg = 4
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b10000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd1; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 1;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b11000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 1;
        PSELx = 0;
        PWRITE = 0;
        // Transmit reg = 4
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b10000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd2; 
        #10;
        PENABLE = 1;
        
        // Transmit reg = 4
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b10000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd3; 
        #10;
        PENABLE = 1;

        // Transmit reg = 4
        #10;
        PENABLE = 1;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b10000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd4; 
        #10;
        PENABLE = 1;

        // Transmit reg = 4
        #10;
        PENABLE = 1;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b10000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd5; 
        
        #10;
        PENABLE = 1;
        PSELx = 0;
        PWRITE = 0;
        

        #10000;
        $finish;
    end
endmodule 