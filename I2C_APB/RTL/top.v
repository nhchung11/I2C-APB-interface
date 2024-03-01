module top_level
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
        input                       sda_in,
        input                       i2c_core_clk_top,

        output [data_size - 1:0]    PRDATA,
        output                      PREADY,
        output                      scl_out,
        output                      sda_out
    );
    // Internal register
    wire [data_size - 1:0]          prescale_reg;
    wire [data_size - 1:0]          command_reg;
    reg  [data_size - 1:0]          status_reg;
    wire [data_size - 1:0]          transmit_reg;
    wire [data_size - 1:0]          receive_reg;
    wire [data_size - 1:0]          address_reg;

    // FIFO TX
    // Internal FIFO TX wires
    wire [address_size - 1:0]       write_address_output_tx;
    wire [address_size - 1:0]       read_address_output_tx;
    wire [address_size:0]           write_pointer_tx;
    wire [address_size:0]           read_pointer_tx;
    wire [address_size:0]           write_to_read_pointer_tx;
    wire [address_size:0]           read_to_write_pointer_tx;
    
    // Internal FIFO TX signals
    wire                            write_increment_tx;
    wire                            read_increment_tx;
    wire [data_size - 1:0]          read_data_output_tx;
    wire                            write_full_output_tx;
    wire                            read_empty_output_tx;
    wire [data_size - 1:0]          write_data_tx;
    wire                            read_reset_n_tx;
    wire                            write_reset_n_tx;

    // FIFO RX
    // Internal FIFO RX wires
    wire [address_size - 1:0]       write_address_output_rx;
    wire [address_size - 1:0]       read_address_output_rx;
    wire [address_size:0]           write_pointer_rx;
    wire [address_size:0]           read_pointer_rx;
    wire [address_size:0]           write_to_read_pointer_rx;
    wire [address_size:0]           read_to_write_pointer_rx;

    // Internal FIFO RX signals
    wire                            write_increment_rx;
    wire                            read_increment_rx;
    wire [data_size - 1:0]          read_data_output_rx;
    wire                            write_full_output_rx;
    wire                            read_empty_output_rx;
    wire [data_size - 1:0]          write_data_rx;
    wire                            read_reset_n_rx;
    wire                            write_reset_n_rx;
    

    // FIFO inputs and outputs
    wire [data_size - 1:0]          TX;
    wire [data_size - 1:0]          RX;
    wire [data_size - 1:0]          APB_TX;
    wire [data_size - 1:0]          APB_RX;
    wire                            fifo_rx_enable;

    assign APB_TX                   = transmit_reg;
    assign APB_RX                   = fifo_memory_rx.read_data_rx;

    always @* begin
        status_reg [5:0]            = 0;
        status_reg [7]              = write_full_output_tx;
        status_reg [6]              = read_empty_output_tx;
    end


    // FIFO TX
    fifo_memory_tx #(data_size, address_size) fifomem_tx
    (
        .write_clk_tx                  (PCLK),
        .write_clk_en_tx               (command_reg[6]),
        .write_data_tx                 (transmit_reg),
        .write_address_input_tx        (write_address_output_tx),
        .read_data_tx                  (TX),
        .read_address_input_tx         (read_address_output_tx),
        .write_full_check_tx           (write_full_output_tx)
    );

    read_pointer_empty_tx #(address_size) read_pointer_empty_tx
    (
        .read_clk_tx                   (i2c_core_clk_top),
        .read_reset_n_tx               (command_reg[4]),
        .read_increment_tx             (command_reg[7]),
        .read_address_output_tx        (read_address_output_tx),
        .read_pointer_tx               (read_pointer_tx),
        .read_empty_output_tx          (read_empty_output_tx),
        .read_to_write_pointer_tx      (read_to_write_pointer_tx)
    );

    write_pointer_full_tx #(address_size) write_pointer_full_tx
    (
        .write_clk_tx                  (PCLK),
        .write_reset_n_tx              (command_reg[4]),
        .write_increment_tx            (command_reg[7]),
        .write_address_output_tx       (write_address_output_tx),
        .write_pointer_tx              (write_pointer_tx),
        .write_full_output_tx          (write_full_output_tx),
        .write_to_read_pointer_tx      (write_to_read_pointer_tx)
    );

    sync_read_to_write_tx sync_read_to_write_tx
    (
        .write_clk_tx                  (PCLK),
        .write_reset_n_tx              (command_reg[4]),
        .read_pointer_tx               (read_pointer_tx),
        .write_to_read_pointer_tx      (write_to_read_pointer_tx)
    );

    sync_write_to_read_tx sync_write_to_read_tx
    (
        .read_clk_tx                   (i2c_core_clk_top),
        .read_reset_n_tx               (command_reg[4]),
        .write_pointer_tx              (write_pointer_tx),
        .read_to_write_pointer_tx      (read_to_write_pointer_tx)
    );


    // FIFO RX
    fifo_memory_rx #(data_size, address_size)   fifo_memory_rx
    (
        .write_clk_rx                (i2c_core_clk_top),
        .write_clk_en_rx             (command_reg[5]),
        .write_data_rx               (RX),
        .write_address_input_rx      (write_address_output_rx),
        .read_data_rx                (receive_reg),
        .read_address_input_rx       (read_address_output_rx),
        .write_full_check_rx         (write_full_output_rx)
    );

    read_pointer_empty_rx #(address_size)       read_pointer_empty_rx
    (
        .read_clk_rx                 (PCLK),
        .read_reset_n_rx             (command_reg[4]),
        .read_increment_rx           (command_reg[7]),
        .read_address_output_rx      (read_address_output_rx),
        .read_pointer_rx             (read_pointer_rx),
        .read_empty_output_rx        (read_empty_output_rx),
        .read_to_write_pointer_rx    (read_to_write_pointer_rx)
    );

    write_pointer_full_rx #(address_size)       write_pointer_full_rx
    (
        .write_clk_rx                (i2c_core_clk_top),
        .write_reset_n_rx            (command_reg[5]),
        .write_increment_rx          (command_reg[7]),
        .write_address_output_rx     (write_address_output_rx),
        .write_pointer_rx            (write_pointer_rx),
        .write_full_output_rx        (write_full_output_rx),
        .write_to_read_pointer_rx    (write_to_read_pointer_rx)
    );

    sync_read_to_write_rx                       sync_read_to_write_rx
    (
        .write_clk_rx                (i2c_core_clk_top),
        .write_reset_n_rx            (command_reg[4]),
        .read_pointer_rx             (read_pointer_rx),
        .write_to_read_pointer_rx    (write_to_read_pointer_rx)
    );

    sync_write_to_read_rx                       sync_write_to_read_rx
    (
        .read_clk_rx                 (PCLK),
        .read_reset_n_rx             (command_reg[4]),
        .write_pointer_rx            (write_pointer_rx),
        .read_to_write_pointer_rx    (read_to_write_pointer_rx)
    );

    // APB INTERFACE
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
        .receive_reg                (APB_RX),
        .address_reg                (address_reg)
    );

    i2c_controller i2c_controller
    (
        .i2c_core_clk               (i2c_core_clk_top),
        .rst_n                      (command_reg[4]),
        .enable                     (command_reg[7]),
        .slave_address              (address_reg),
        .data_in                    (APB_TX),
        .repeated_start_cond        (command_reg[3]),
        .sda_in                     (sda_in),
        .sda_out                    (sda_out),
        .scl_out                    (scl_out),
        .fifo_rx_enable             (fifo_rx_enable)
    );

    BitToByteConverter bit_to_byte_converter
    (
        .clk                        (i2c_core_clk_top),
        .rst_n                      (command_reg[4]),
        .in                         (sda_in),
        .enable                     (fifo_rx_enable),
        .out                        (RX)
    );
endmodule