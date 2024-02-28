module apb_to_fifo
    #(parameter data_size = 8,parameter address_size = 3)  
    (
        // Inputs
        input                       PCLK,
        input                       PRESETn,
        input                       PENABLE,
        input                       PSELx,
        input                       PWRITE,
        input [6:0]                 PADDR,
        input [data_size - 1:0]     PWDATA,
        input                       write_clk,
        input                       read_clk,
        input [7:0]                 RX,

        // Outputs
        output [data_size - 1:0]    TX,
        output [data_size - 1:0]    PRDATA,
        output                      PREADY
    );
    // Internal register
    wire [data_size - 1:0]          prescale_reg;
    wire [data_size - 1:0]          command_reg;
    wire [data_size - 1:0]          status_reg;
    wire [data_size - 1:0]          transmit_reg;
    wire [data_size - 1:0]          receive_reg;
    wire [data_size - 1:0]          address_reg;

    // Internal FIFO wires
    wire [address_size-1:0]         write_address;
    wire                            read_address;
    wire [address_size:0]           write_pointer;
    wire [address_size:0]           read_pointer;
    wire [address_size:0]           write_to_read_pointer;
    wire [address_size:0]           read_to_write_pointer;

    // Internal FIFO signals
    wire                            write_increment;
    wire                            read_increment;
    wire [data_size - 1:0]          read_data;
    wire                            write_full;
    wire                            read_empty;
    wire [data_size - 1:0]          write_data;
    wire                            read_reset_n;
    wire                            write_reset_n;

    assign status_reg[5:0]          = 0;
    assign TX                       = transmit_reg;
    assign status_reg [7]           = write_full;
    assign status_reg [6]           = read_empty;
    
    FIFO_memory #(data_size, address_size) fifomem
    (
        .write_clk                  (write_clk),
        .write_clk_en               (command_reg[7]),
        .write_data                 (transmit_reg),
        .write_address              (write_address),
        .read_data                  (receive_reg),
        .read_address               (address_reg),
        .write_full                 (write_full)
    );
    read_pointer_empty #(address_size) read_pointer_empty
    (
        .read_clk                   (read_clk),
        .read_reset_n               (command_reg[6]),
        .read_increment             (command_reg[7]),
        .read_address               (address_reg),
        .read_pointer               (read_pointer),
        .read_empty                 (read_empty),
        .read_to_write_pointer      (read_to_write_pointer)
    );
    write_pointer_full #(address_size) write_pointer_full
    (
        .write_clk                  (write_clk),
        .write_reset_n              (command_reg[6]),
        .write_increment            (command_reg[7]),
        .write_address              (write_address),
        .write_pointer              (write_pointer),
        .write_full                 (write_full),
        .write_to_read_pointer      (write_to_read_pointer)
    );
    sync_read_to_write sync_read_to_write
    (
        .write_clk                  (write_clk),
        .write_reset_n              (command_reg[6]),
        .read_pointer               (read_pointer),
        .write_to_read_pointer      (write_to_read_pointer)
    );
    sync_write_to_read sync_write_to_read
    (
        .read_clk                   (read_clk),
        .read_reset_n               (command_reg[6]),
        .write_pointer              (write_pointer),
        .read_to_write_pointer      (read_to_write_pointer)
    );
    apb apb
    (
        .PCLK                       (PCLK),
        .PRESETn                    (PRESETn),
        .PENABLE                    (PENABLE),
        .PSELx                      (PSELx),
        .PWRITE                     (PWRITE),
        .PADDR                      (PADDR),
        .PWDATA                     (PWDATA),
        .PREADY                     (PREADY),
        .PRDATA                     (PRDATA),
        
        .prescale_reg               (prescale_reg),
        .command_reg                (command_reg),
        .status_reg                 (status_reg),
        .transmit_reg               (transmit_reg),
        .receive_reg                (RX),
        .address_reg                (address_reg)
    );
endmodule