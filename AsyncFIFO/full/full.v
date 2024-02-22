module write_pointer_full 
#(parameter address_size = 4)
(
    input                           write_reset_n, 
    input                           write_clk, 
    input                           write_increment,
    input [address_size :0]         write_to_read_pointer,
    output reg [address_size-1:0]   write_address,
    output reg [address_size :0]    write_pointer,
    output reg                      write_full
);

reg [address_size:0] write_gray_next;
reg [address_size:0] write_binary_next;
reg [address_size:0] write_binary;

// Binary pointers to the memory buffer
always@*
    begin
        write_address = write_binary[address_size-1:0];
        write_binary_next = write_binary + (write_increment & ~write_full); 
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
        write_full <= 1'b0;
    else
        write_full <= (write_gray_next=={~write_to_read_pointer[address_size:address_size-1], write_to_read_pointer[address_size-2:0]});
endmodule