// MEMORY
module FIFO_memory 
    #(parameter data_size = 8, parameter address_size = 3)
    //let us define the data and address size to get 8 location X 8 bit memory
    (
        input [data_size-1:0]       write_data,
        input [address_size-1:0]    write_address_input,
        input [address_size-1:0]    read_address_input,
        input                       write_clk_en,
        input                       write_full_check,
        input                       write_clk,
        output [data_size-1:0]      read_data
    );

    localparam  FIFO_depth = 1<<address_size;
    reg         [data_size-1:0] mem [0:FIFO_depth-1];
    assign      read_data = mem[read_address_input];

    always @(posedge write_clk)
        if (write_clk_en && !write_full_check)
            mem[write_address_input] <= write_data;
endmodule


// FULL 
module write_pointer_full 
    #(parameter address_size = 4)
    (
        input                           write_reset_n, 
        input                           write_clk, 
        input                           write_increment,
        input [address_size :0]         write_to_read_pointer,
        output reg [address_size-1:0]   write_address_output,
        output reg [address_size :0]    write_pointer,
        output reg                      write_full_output
    );

    reg [address_size:0] write_gray_next;
    reg [address_size:0] write_binary_next;
    reg [address_size:0] write_binary;

    // Binary pointers to the memory buffer
    always@*
        begin
            write_address_output = write_binary[address_size-1:0];
            write_binary_next = write_binary + (write_increment & ~write_full_output); 
            write_gray_next = (write_binary_next>>1) ^ write_binary_next;
        end

    // let us use the gray pointers
    always @(posedge write_clk , negedge write_reset_n)
        if (~write_reset_n)
            {write_binary, write_pointer} <= 0;
        else
            {write_binary, write_pointer} <= {write_binary_next, write_gray_next};

    //Let us create FIFO_Full logic using the pointer 
    always @(posedge write_clk , negedge write_reset_n)
        if (!write_reset_n) 
            write_full_output <= 1'b0;
        else
            write_full_output <= (write_gray_next=={~write_to_read_pointer[address_size:address_size-1], write_to_read_pointer[address_size-2:0]});
endmodule


// EMPTY
module read_pointer_empty #(parameter address_size = 3)
    (
        input                           read_reset_n,
        input                           read_increment,
        input                           read_clk,
        input [address_size :0]         read_to_write_pointer,
        output reg [address_size-1:0]   read_address_output,
        output reg [address_size :0]    read_pointer,
        output reg                      read_empty_output 
    );

    reg [address_size:0] read_binary;
    reg [address_size:0] read_gray_next;
    reg [address_size:0] read_binary_next;

    always@*
        begin
        read_address_output = read_binary[address_size-1:0];
        read_binary_next = read_binary + (read_increment & ~read_empty_output); 
        read_gray_next = (read_binary_next>>1) ^ read_binary_next;
    end

    always @(posedge read_clk , negedge read_reset_n)
        if (~read_reset_n)
            {read_binary, read_pointer} <= 0;
        else
            {read_binary, read_pointer} <= {read_binary_next, read_gray_next};

    // FIFO empty logic
    always @(posedge read_clk , negedge read_reset_n)
        if (~read_reset_n)
            read_empty_output <= 1'b1;
        else
            read_empty_output <= (read_gray_next == read_to_write_pointer);
endmodule

// SYNC READ TO WRITE
module sync_read_to_write #(parameter address_size = 3)
    (
        input                           write_reset_n,
        input                           write_clk,
        input [address_size:0]          read_pointer,
        output reg [address_size:0]     write_to_read_pointer
    );

    reg [address_size:0] tmp1_read_pointer;
    always @(posedge write_clk , negedge write_reset_n)
        if (~write_reset_n)
            {write_to_read_pointer,tmp1_read_pointer} <= 0;
        else
    {       write_to_read_pointer,tmp1_read_pointer} <= {tmp1_read_pointer,read_pointer};
endmodule


// SYNC WRITE TO READ
module sync_write_to_read #(parameter address_size = 3)
    (
        input [address_size:0]          write_pointer,
        input                           read_reset_n,
        input                           read_clk,
        output reg [address_size:0]     read_to_write_pointer
    );

    reg [address_size:0] tmp1_write_pointer;
    always @(posedge read_clk , negedge read_reset_n)
        if (~read_reset_n)
            {read_to_write_pointer,tmp1_write_pointer} <= 0;
        else
            {read_to_write_pointer,tmp1_write_pointer} <= {tmp1_write_pointer,write_pointer};
endmodule