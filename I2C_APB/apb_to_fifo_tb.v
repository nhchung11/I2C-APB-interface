module apb_to_fifo_tb
    // APB inputs and outputs
    reg PCLK;
    reg PRESETn;
    reg PSELx;
    reg PWRITE;
    reg PENABLE;
    reg [7:0] PADDR;
    reg [7:0] PWDATA;
    
    wire [7:0] APB_RX;          // Connect to fifo write_data
    wire WRITE_FULL;            // Connect to fifo write_full
    wire READ_EMPTY;            // Connect to fifo read_empty
    wire PREADY;
    wire [7:0] PRDATA;
    wire R_ENA;                 // Connect to fifo read_increment
    wire W_ENA;                 // Connect to fifo write_increment
    wire [7:0] APB_TX;          // Connect to fifo read_data

    // FIFO inputs and outputs
    reg [7:0] write_data;
    reg write_clk;
    reg write_reset_n;
    reg read_clk;
    reg read_reset_n;

    wire write_full;
    wire read_empty;
    wire write_increment;
    wire read_increment;
    wire [7:0] read_data;

    APB_toI2C_BRIDGE_TOP uut
    (
        
    )
endmodule