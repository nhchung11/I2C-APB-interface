module apb_to_fifo_tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PSELx;
    reg             PWRITE;
    reg             PENABLE;
    reg [6:0]       PADDR;
    reg [7:0]       PWDATA;
    reg             write_clk;
    reg             read_clk;
    reg [7:0]       RX;

    wire [7:0]      TX;
    wire [7:0]      PRDATA;
    wire            PREADY;

    apb_to_fifo dut
    (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .PSELx      (PSELx),
        .PWRITE     (PWRITE),
        .PENABLE    (PENABLE),
        .PADDR      (PADDR),
        .PWDATA     (PWDATA),
        .write_clk  (write_clk),
        .read_clk   (read_clk),
        .RX         (RX),
        
        .TX         (TX),
        .PREADY     (PREADY),
        .PRDATA     (PRDATA)
    );

    
    always #5 write_clk= ~write_clk;
    always #10 read_clk= ~read_clk;

	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        write_clk = 0;
        read_clk = 0;
        PRESETn = 1;
        PADDR = 7'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'b00000000;
        PENABLE = 0;

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
        RX = 8'b10101010;        // Receive from FIFO      

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        // asd
        #20;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'b11110101;

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
        RX = 8'b11111010;        // Receive from FIFO      

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;
        
        // asdjak
        #20;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'b11110101;

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        // asdasd
        #20;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'b11110101;

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