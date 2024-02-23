module APB_toI2C_BRIDGE_TOP
    #(parameter data_size = 8,parameter address_size = 3)
    (   
        // FIFO inputs and outputs
        input                   read_clk,
        input                   read_reset_n,
        input                   write_clk,
        input                   write_reset_n,

        wire [data_size-1:0]    write_data,
        wire                    write_increment, 
        wire                    read_increment,
        wire [data_size-1:0]    read_data,
        wire                    write_full,
        wire                    read_empty
    );

    wire [address_size-1:0] write_address, read_address;
    wire [address_size:0] write_pointer, read_pointer, write_to_read_pointer, read_to_write_pointer;

    FIFO_memory #(data_size, address_size) fifomem
    (
        .write_clk(write_clk),
        .write_clk_en(write_increment),
        .write_data(APB_TX),
        .write_address(write_address),
        .read_data(read_data),
        .read_address(read_address),
        .write_full(write_full)
    );

    read_pointer_empty #(address_size) read_pointer_empty
    (
        .read_clk(read_clk),
        .read_reset_n(read_reset_n),
        .read_increment(read_increment) ,
        .read_address(read_address),
        .read_pointer(read_pointer),
        .read_empty(read_empty),
        .read_to_write_pointer(read_to_write_pointer)
    );

    write_pointer_full #(address_size) write_pointer_full
    (
        .write_clk(write_clk),
        .write_reset_n(write_reset_n),
        .write_increment(write_increment),
        .write_address(write_address),
        .write_pointer(write_pointer),
        .write_full(write_full),
        .write_to_read_pointer(write_to_read_pointer)
    );

    sync_read_to_write sync_read_to_write
    (
        .write_clk(write_clk),
        .write_reset_n(write_reset_n),
        .read_pointer(read_pointer),
        .write_to_read_pointer(write_to_read_pointer)
    );

    sync_write_to_read sync_write_to_read
    (
        .read_clk(read_clk),
        .read_reset_n(read_reset_n),
        .write_pointer(write_pointer),
        .read_to_write_pointer(read_to_write_pointer)
    );

    apb apb_slave
    (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSELx(PSELx),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .APB_RX(read_data),
        .WRITE_FULL(write_full),
        .READ_EMPTY(read_empty),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .R_ENA(R_ENA),
        .W_ENA(W_ENA),
        .APB_TX(APB_TX)
    );
endmodule