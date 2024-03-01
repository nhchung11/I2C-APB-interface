module tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PSELx;
    reg             PWRITE;
    reg             PENABLE;
    reg     [6:0]   PADDR;
    reg     [7:0]   PWDATA;
    reg     [7:0]   status_reg;
    reg     [7:0]   receive_reg;

    wire            PREADY;
    wire    [7:0]   PRDATA;

    wire    [7:0]   transmit_reg;
    wire    [7:0]   command_reg;
    wire    [7:0]   prescale_reg;
    wire    [7:0]   address_reg;

    apb apb_dut
    (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSELx(PSELx),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .status_reg(status_reg),
        .receive_reg(receive_reg),
        
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        
        .transmit_reg(transmit_reg),
        .command_reg(command_reg),
        .prescale_reg(prescale_reg),
        .address_reg(address_reg)
    );

    
	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        PRESETn = 1;
        PADDR = 7'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'b00000000;
        PENABLE = 0;
        status_reg = 8'b00000000;   // ack, not_busy, not_empty, not_full

        #10;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'b01010101;

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        #20;
        PADDR = 7'b1001100;
        PWRITE = 0;
        PSELx = 1;
        receive_reg = 8'b10101010;        // Receive from FIFO      

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        
        #20;
        $finish;
    end
endmodule