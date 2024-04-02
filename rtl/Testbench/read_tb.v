module read_tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PENABLE;
    reg             PSELx;
    reg             PWRITE;
    reg [7:0]       PADDR;
    reg [7:0]       PWDATA;
    reg             core_clk;

    wire [7:0]      PRDATA;
    wire            PREADY;
    wire            sda;
    wire            scl;

    // reg             sda_en_tb;
    // reg             sda_in;
    // reg             scl_in;

    top_level dut
    (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .PSELx      (PSELx),
        .PWRITE     (PWRITE),
        .PENABLE    (PENABLE),
        .PADDR      (PADDR),
        .PWDATA     (PWDATA),
        .core_clk   (core_clk),

        .PREADY     (PREADY),
        .PRDATA     (PRDATA),
        .sda        (sda),
        .scl        (scl)
    );
    // assign sda = sda_en_tb ? sda_in : 1'bz;
    
    always #20 core_clk= ~core_clk;
	always #5 PCLK= ~PCLK;

    initial begin
        core_clk = 1;
        PCLK = 1;
        PRESETn = 0;
        PWRITE = 0;
        PSELx = 0;
        PENABLE = 0;
        // sda_en_tb = 0;
        // sda_in = 1;
        // scl_in = 1;

        #100;
        PRESETn = 1;

        // Prescale reg = 1
        #10;
        PADDR = 1;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd4;
        #10;
        PENABLE = 1;

        // Address reg = 2
        #10;
        PSELx = 0;
        #10;
        PADDR = 2;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'b00100000;
        PENABLE = 0;    
        #10;
        PENABLE = 1; 

        // Status reg = 3
        #10;
        PSELx = 0;
        #10;
        PADDR = 3;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;
 
        // Command reg = 6;
        #10;
        PSELx = 0;
        #10;
        PADDR = 6;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0; 
        PWDATA = 8'b10010000;
        #10;
        PENABLE = 1;
        
        // Transmit reg = 4
        #10;
        PSELx = 0;
        #10;
        PADDR = 4;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 0; 
        #10;
        PENABLE = 1;  

        // Transmit reg = 4
        #10;
        PSELx = 0;
        #10;
        PADDR = 4;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 1; 
        #10;
        PENABLE = 1;
        
        // Transmit reg = 4
        #10;
        PSELx = 0;
        #10;
        PADDR = 4;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 2; 
        #10;
        PENABLE = 1;

        // Transmit reg = 4
        #10;
        PSELx = 0;
        #10;
        PADDR = 4;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 3; 
        #10;
        PENABLE = 1;

        // // Transmit reg = 4
        // #10;
        // PSELx = 0;
        // #10;
        // PADDR = 4;
        // PWRITE = 1;
        // PSELx = 1;
        // PENABLE = 0;
        // PWDATA = 4; 
        // #10;
        // PENABLE = 1;

        #10;
        PSELx = 0;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;


        // Finish writing
        #20000
        // Address reg = 2
        #10;
        PSELx = 0;
        #10;
        PADDR = 2;
        PWRITE = 1;
        PSELx = 1;
        PWDATA = 8'b00100001;
        PENABLE = 0;    
        #10;
        PENABLE = 1; 

        #20000;
        // Receive reg = 5 data 1
        #10;
        PSELx = 0;
        #10;
        PADDR = 5;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;

        // Receive reg = 5 data 1
        #10;
        PSELx = 0;
        #10;
        PADDR = 5;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;

        // Receive reg = 5 data 1
        #10;
        PSELx = 0;
        #10;
        PADDR = 5;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;

        // Receive reg = 5 data 1
        #10;
        PSELx = 0;
        #10;
        PADDR = 5;
        PWRITE = 0;
        PSELx = 1;
        PENABLE = 0; 
        #10;
        PENABLE = 1;
        #1000;
        $finish;
    end
endmodule 