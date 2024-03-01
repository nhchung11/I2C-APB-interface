module top_level_tb;
    reg             PCLK;
    reg             PRESETn;
    reg             PSELx;
    reg             PWRITE;
    reg             PENABLE;
    reg [6:0]       PADDR;
    reg [7:0]       PWDATA;
    reg             sda_in;
    reg             i2c_core_clk_top;

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
        .i2c_core_clk_top(i2c_core_clk_top),

        .PREADY     (PREADY),
        .PRDATA     (PRDATA),
        .sda_out    (sda_out),
        .scl_out    (scl_out)
    );

    
    always #5 i2c_core_clk_top= ~i2c_core_clk_top;

	initial begin
		PCLK = 1;
		forever begin
			#5 PCLK = ~PCLK;
		end		
	end

    initial begin
        i2c_core_clk_top = 0;
        PRESETn = 0;
        PADDR = 7'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'd0;
        PENABLE = 0;
        sda_in = 1;

        #10;
        PRESETn = 1;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd1;

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        #360;
        sda_in = 0;
        #40;
        sda_in = 1;

        #320;
        sda_in = 0;
        #40
        sda_in = 1;


        i2c_core_clk_top = 0;
        PRESETn = 0;
        PADDR = 7'b0;
        PWRITE = 0;
        PSELx = 0;
        PWDATA = 8'd0;
        PENABLE = 0;
        sda_in = 1;

        #10;
        PRESETn = 1;
        PADDR = 7'b0001111;
        PWRITE = 1;
        PSELx = 1;
        PENABLE = 0;
        PWDATA = 8'd5;

        #10;
        PENABLE = 1;

        #10;
        PENABLE = 0;
        PSELx = 0;
        PWRITE = 0;

        #360;
        sda_in = 0;
        #40;
        sda_in = 1;

        #320;
        sda_in = 0;
        #40
        sda_in = 1;
        #800;
        $finish;
    end
endmodule 