module apb_tb;
    reg PCLK;
    reg PRESETn;
    reg PSELx;
    reg PWRITE;
    reg PENABLE;
    reg [7:0] PADDR;
    reg [7:0] PWDATA;
    reg [7:0] APB_RX;
    reg WRITE_FULL;
    reg READ_EMPTY;

    wire PREADY;
    wire [7:0] PRDATA;
    wire R_ENA;
    wire W_ENA;
    wire [7:0] APB_TX;

    apb apb_dut
    (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSELx(PSELx),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .APB_RX(APB_RX),
        .WRITE_FULL(WRITE_FULL),
        .READ_EMPTY(READ_EMPTY),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .R_ENA(R_ENA),
        .W_ENA(W_ENA),
        .APB_TX(APB_TX)
    );

    
	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        PRESETn = 1;
        PADDR = 8'b00001111;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'b00000000;
        PENABLE = 0;
        APB_RX = 0;             // Not receive from FIFO
        WRITE_FULL = 0;
        READ_EMPTY = 0;

        #10;
        PADDR = 8'd0;
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
        PADDR = 8'd4;
        PWRITE = 0;
        PSELx = 1;
        APB_RX = 8'b01010101;        // Receive from FIFO      

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        
        #20;
        $finish;
    end
endmodule