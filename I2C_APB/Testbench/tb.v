module tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PSELx;
    reg             PWRITE;
    reg             PENABLE;
    reg     [7:0]   PADDR;
    reg     [7:0]   PWDATA;
    wire    [7:0]   PRDATA;
    wire    [7:0]   prescale_reg;
    wire    [7:0]   address_reg;
    reg     [7:0]   status_reg;
    wire    [7:0]   transmit_reg;
    reg     [7:0]   receive_reg;
    wire    [7:0]   command_reg;
    wire            PREADY;


    apb apb_dut
    (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSELx(PSELx),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .prescale_reg(prescale_reg),
        .address_reg(address_reg),
        .status_reg(status_reg),
        .transmit_reg(transmit_reg),
        .receive_reg(receive_reg),
        .command_reg(command_reg),
        .PREADY(PREADY),
        .PRDATA(PRDATA)
    );

    
	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        PRESETn = 1;
        PADDR = 8'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'b0;
        PENABLE = 0;
        status_reg = 8'b0;   // ack, not_busy, not_empty, not_full
        receive_reg = 8'd2;

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
        PWDATA = 8'd1;
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
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        
        // data = 2;
        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'd1;
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
        PWDATA = 8'd2; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        // data = 3
        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'd1;
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
        PWDATA = 8'd3; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        // data = 4
        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'd1;
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
        PWDATA = 8'd4; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        //data = 5
        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'd1;
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
        PWDATA = 8'd5; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        //data = 6
        // Address reg = 2
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b01000000;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'd1;
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
        PWDATA = 8'd6; 
        #10;
        PENABLE = 1;
        
        // Command reg = 5;
        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #10;
        PADDR = 8'b11000000;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10000000;
        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        #20;
        $finish;
    end
endmodule