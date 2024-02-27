module Top_module
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
    
    // Internal wires
    wire [data_size - 1:0]          prescale_reg;
    wire [data_size - 1:0]          command_reg;
    wire [data_size - 1:0]          status_reg;
    wire [data_size - 1:0]          transmit_reg;
    wire [data_size - 1:0]          receive_reg;
    wire [data_size - 1:0]          address_reg;
    wire [address_size - 1:0]       read_address;
    assign TX = fifo.write_data;

    FIFO_top #(data_size, address_size) fifo
    (
        .write_data                 (transmit_reg),
        .write_clk                  (write_clk),
        .read_clk                   (read_clk),
        .write_reset_n              (command_reg[6]),
        .read_reset_n               (command_reg[6]),
        .write_increment            (command_reg[7]),
        .read_increment             (command_reg[7]),
        .write_full                 (status_reg[4]),
        .read_empty                 (status_reg[5])
    );

    apb apb_slave
    (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PENABLE(PENABLE),
        .PSELx(PSELx),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        
        .prescale_reg(prescale_reg),
        .command_reg(command_reg),
        .status_reg(status_reg),
        .transmit_reg(transmit_reg),
        .receive_reg(receive_reg),
        .address_reg(address_reg)
    );
endmodule