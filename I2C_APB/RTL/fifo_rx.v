// MEMORY
module fifo_memory_rx 
    #(parameter data_size = 8, parameter address_size = 3)
    //let us define the data and address size to get 8 location X 8 bit memory
    (
        input [data_size-1:0]       write_data_rx,
        input [address_size-1:0]    write_address_input_rx,
        input [address_size-1:0]    read_address_input_rx,
        input                       write_clk_en_rx,
        input                       write_full_check_rx,
        input                       write_clk_rx,
        output [data_size-1:0]      read_data_rx
    );

    localparam  FIFO_depth = 1<<address_size;
    reg         [data_size-1:0] mem_rx [0:FIFO_depth-1];
    assign      read_data_rx = mem_rx[read_address_input_rx];

    always @(posedge write_clk_rx)
        if (write_clk_en_rx && !write_full_check_rx)
            mem_rx[write_address_input_rx] <= write_data_rx;
endmodule


// FULL 
module write_pointer_full_rx
    #(parameter address_size = 4)
    (
        input                           write_reset_n_rx, 
        input                           write_clk_rx, 
        input                           write_increment_rx,
        input [address_size :0]         write_to_read_pointer_rx,
        output reg [address_size-1:0]   write_address_output_rx,
        output reg [address_size :0]    write_pointer_rx,
        output reg                      write_full_output_rx
    );

    reg [address_size:0] write_gray_next_rx;
    reg [address_size:0] write_binary_next_rx;
    reg [address_size:0] write_binary_rx;

    // Binary pointers to the memory buffer
    always@*
        begin
            write_address_output_rx = write_binary_rx[address_size-1:0];
            write_binary_next_rx = write_binary_rx + (write_increment_rx & ~write_full_output_rx); 
            write_gray_next_rx = (write_binary_next_rx >> 1) ^ write_binary_next_rx;
        end

    // let us use the gray pointers
    always @(posedge write_clk_rx , negedge write_reset_n_rx)
        if (~write_reset_n_rx)
            {write_binary_rx, write_pointer_rx} <= 0;
        else
            {write_binary_rx, write_pointer_rx} <= {write_binary_next_rx, write_gray_next_rx};

    //Let us create FIFO_Full logic using the pointer 
    always @(posedge write_clk_rx , negedge write_reset_n_rx)
        if (!write_reset_n_rx) 
            write_full_output_rx <= 1'b0;
        else
            write_full_output_rx <= (write_gray_next_rx=={~write_to_read_pointer_rx[address_size:address_size-1], write_to_read_pointer_rx[address_size-2:0]});
endmodule


// EMPTY
module read_pointer_empty_rx #(parameter address_size = 3)
    (
        input                           read_reset_n_rx,
        input                           read_increment_rx,
        input                           read_clk_rx,
        input [address_size :0]         read_to_write_pointer_rx,
        output reg [address_size-1:0]   read_address_output_rx,
        output reg [address_size :0]    read_pointer_rx,
        output reg                      read_empty_output_rx 
    );

    reg [address_size:0] read_binary_rx;
    reg [address_size:0] read_gray_next_rx;
    reg [address_size:0] read_binary_next_rx;

    always@*
        begin
        read_address_output_rx = read_binary_rx[address_size-1:0];
        read_binary_next_rx = read_binary_rx + (read_increment_rx & ~read_empty_output_rx); 
        read_gray_next_rx = (read_binary_next_rx >> 1) ^ read_binary_next_rx;
    end

    always @(posedge read_clk_rx, negedge read_reset_n_rx)
        if (~read_reset_n_rx)
            {read_binary_rx, read_pointer_rx} <= 0;
        else
            {read_binary_rx, read_pointer_rx} <= {read_binary_next_rx, read_gray_next_rx};

    // FIFO empty logic
    always @(posedge read_clk_rx, negedge read_reset_n_rx)
        if (~read_reset_n_rx)
            read_empty_output_rx <= 1'b1;
        else
            read_empty_output_rx <= (read_gray_next_rx == read_to_write_pointer_rx);
endmodule

// SYNC READ TO WRITE
module sync_read_to_write_rx #(parameter address_size = 3)
    (
        input                           write_reset_n_rx,
        input                           write_clk_rx,
        input [address_size:0]          read_pointer_rx,
        output reg [address_size:0]     write_to_read_pointer_rx
    );

    reg [address_size:0] tmp1_read_pointer_rx;
    always @(posedge write_clk_rx, negedge write_reset_n_rx)
        if (~write_reset_n_rx)
            {write_to_read_pointer_rx,tmp1_read_pointer_rx} <= 0;
        else
            {write_to_read_pointer_rx,tmp1_read_pointer_rx} <= {tmp1_read_pointer_rx,read_pointer_rx};
endmodule


// SYNC WRITE TO READ
module sync_write_to_read_rx #(parameter address_size = 3)
    (
        input [address_size:0]          write_pointer_rx,
        input                           read_reset_n_rx,
        input                           read_clk_rx,
        output reg [address_size:0]     read_to_write_pointer_rx
    );

    reg [address_size:0] tmp1_write_pointer_rx;
    always @(posedge read_clk_rx, negedge read_reset_n_rx)
        if (~read_reset_n_rx)
            {read_to_write_pointer_rx,tmp1_write_pointer_rx} <= 0;
        else
            {read_to_write_pointer_rx,tmp1_write_pointer_rx} <= {tmp1_write_pointer_rx,write_pointer_rx};
endmodule