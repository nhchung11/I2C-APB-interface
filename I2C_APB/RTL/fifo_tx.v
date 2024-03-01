// MEMORY
module fifo_memory_tx 
    #(parameter data_size = 8, parameter address_size = 3)
    //let us define the data and address size to get 8 location X 8 bit memory
    (
        input [data_size-1:0]       write_data_tx,
        input [address_size-1:0]    write_address_input_tx,
        input [address_size-1:0]    read_address_input_tx,
        input                       write_clk_en_tx,
        input                       write_full_check_tx,
        input                       write_clk_tx,
        output [data_size-1:0]      read_data_tx
    );

    localparam  FIFO_depth = 1<<address_size;
    reg         [data_size-1:0] mem_tx [0:FIFO_depth-1];
    assign      read_data_tx = mem_tx[read_address_input_tx];

    always @(posedge write_clk_tx)
        if (write_clk_en_tx && !write_full_check_tx)
            mem_tx[write_address_input_tx] <= write_data_tx;
endmodule


// FULL 
module write_pointer_full_tx
    #(parameter address_size = 4)
    (
        input                           write_reset_n_tx, 
        input                           write_clk_tx, 
        input                           write_increment_tx,
        input [address_size :0]         write_to_read_pointer_tx,
        output reg [address_size-1:0]   write_address_output_tx,
        output reg [address_size :0]    write_pointer_tx,
        output reg                      write_full_output_tx
    );

    reg [address_size:0] write_gray_next_tx;
    reg [address_size:0] write_binary_next_tx;
    reg [address_size:0] write_binary_tx;

    // Binary pointers to the memory buffer
    always@*
        begin
            write_address_output_tx = write_binary_tx[address_size-1:0];
            write_binary_next_tx = write_binary_tx + (write_increment_tx & ~write_full_output_tx); 
            write_gray_next_tx = (write_binary_next_tx >> 1) ^ write_binary_next_tx;
        end

    // let us use the gray pointers
    always @(posedge write_clk_tx , negedge write_reset_n_tx)
        if (~write_reset_n_tx)
            {write_binary_tx, write_pointer_tx} <= 0;
        else
            {write_binary_tx, write_pointer_tx} <= {write_binary_next_tx, write_gray_next_tx};

    //Let us create FIFO_Full logic using the pointer 
    always @(posedge write_clk_tx , negedge write_reset_n_tx)
        if (!write_reset_n_tx) 
            write_full_output_tx <= 1'b0;
        else
            write_full_output_tx <= (write_gray_next_tx == {~write_to_read_pointer_tx[address_size:address_size-1], write_to_read_pointer_tx[address_size-2:0]});
endmodule


// EMPTY
module read_pointer_empty_tx #(parameter address_size = 3)
    (
        input                           read_reset_n_tx,
        input                           read_increment_tx,
        input                           read_clk_tx,
        input [address_size :0]         read_to_write_pointer_tx,
        output reg [address_size-1:0]   read_address_output_tx,
        output reg [address_size :0]    read_pointer_tx,
        output reg                      read_empty_output_tx 
    );

    reg [address_size:0] read_binary_tx;
    reg [address_size:0] read_gray_next_tx;
    reg [address_size:0] read_binary_next_tx;

    always@*
        begin
        read_address_output_tx = read_binary_tx[address_size-1:0];
        read_binary_next_tx = read_binary_tx + (read_increment_tx & ~read_empty_output_tx); 
        read_gray_next_tx = (read_binary_next_tx >> 1) ^ read_binary_next_tx;
    end

    always @(posedge read_clk_tx , negedge read_reset_n_tx)
        if (~read_reset_n_tx)
            {read_binary_tx, read_pointer_tx} <= 0;
        else
            {read_binary_tx, read_pointer_tx} <= {read_binary_next_tx, read_gray_next_tx};

    // FIFO empty logic
    always @(posedge read_clk_tx , negedge read_reset_n_tx)
        if (~read_reset_n_tx)
            read_empty_output_tx <= 1'b1;
        else
            read_empty_output_tx <= (read_gray_next_tx == read_to_write_pointer_tx);
endmodule

// SYNC READ TO WRITE
module sync_read_to_write_tx #(parameter address_size = 3)
    (
        input                           write_reset_n_tx,
        input                           write_clk_tx,
        input [address_size:0]          read_pointer_tx,
        output reg [address_size:0]     write_to_read_pointer_tx
    );

    reg [address_size:0] tmp1_read_pointer_tx;
    always @(posedge write_clk_tx , negedge write_reset_n_tx)
        if (~write_reset_n_tx)
            {write_to_read_pointer_tx,tmp1_read_pointer_tx} <= 0;
        else
            {write_to_read_pointer_tx,tmp1_read_pointer_tx} <= {tmp1_read_pointer_tx,read_pointer_tx};
endmodule


// SYNC WRITE TO READ
module sync_write_to_read_tx
    #(parameter address_size = 3)
    (
        input [address_size:0]          write_pointer_tx,
        input                           read_reset_n_tx,
        input                           read_clk_tx,
        output reg [address_size:0]     read_to_write_pointer_tx
    );

    reg [address_size:0] tmp1_write_pointer_tx;
    always @(posedge read_clk_tx , negedge read_reset_n_tx)
        if (~read_reset_n_tx)
            {read_to_write_pointer_tx,tmp1_write_pointer_tx} <= 0;
        else
            {read_to_write_pointer_tx,tmp1_write_pointer_tx} <= {tmp1_write_pointer_tx,write_pointer_tx};
endmodule