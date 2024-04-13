module FIFO_memory 
#(parameter data_size = 8, parameter address_size = 3)
    (
        input   [data_size-1:0]     write_data,
        input   [address_size-1:0]  write_address,
        input   [address_size-1:0]  read_address,
        input                       write_enable,
        input                       write_full,
        input                       write_clk,
        output  [data_size-1:0]     read_data
    );
    
    localparam  FIFO_depth = 1<<address_size;
    reg [data_size-1:0] mem [0:FIFO_depth-1];
    
    // read the data at the output of memory
    assign read_data = mem[read_address];
    //Write a data on rising edge of write clock at specific address location 
    
    always @(posedge write_clk) begin
        if (write_enable && !write_full)
            mem[write_address] <= write_data;
    end
endmodule

module write_pointer_full #(parameter address_size = 4)
    (
        input                           write_reset_n,
        input                           write_clk,
        input                           write_enable,
        input       [address_size :0]   write_to_read_pointer,
        output reg  [address_size-1:0]  write_address,
        output reg  [address_size :0]   write_pointer,
        output reg                      write_full
    );
    reg [address_size:0] write_gray_next;
    reg [address_size:0] write_binary_next;
    reg [address_size:0] write_binary;

    // Binary pointers to the memory buffer
    always@* begin
        write_address = write_binary[address_size-1:0];
        write_binary_next = write_binary + (write_enable & ~write_full); 
        write_gray_next = (write_binary_next>>1) ^ write_binary_next;
    end
    // let us use the gray pointers
    always @(posedge write_clk , negedge write_reset_n) begin
        if (~write_reset_n)
            {write_binary, write_pointer} <= 0;
        else
            {write_binary, write_pointer} <= {write_binary_next, write_gray_next};
    end
    always @(posedge write_clk , negedge write_reset_n) begin
        if (!write_reset_n) 
            write_full <= 1'b0;
        else
            write_full <= (write_gray_next=={~write_to_read_pointer[address_size:address_size-1], write_to_read_pointer[address_size-2:0]});
    end
endmodule

module read_pointer_empty #(parameter address_size = 3)
    (
        input                           read_reset_n,
        input                           read_enable,
        input                           read_clk,
        input       [address_size :0]   read_to_write_pointer,
        output reg  [address_size-1:0]  read_address,
        output reg  [address_size :0]   read_pointer,
        output reg                      read_empty 
    );

    reg [address_size:0] read_binary;
    reg [address_size:0] read_gray_next;
    reg [address_size:0] read_binary_next;
    

    always@*
        begin
            read_address = read_binary[address_size-1:0];
            read_binary_next = read_binary + (read_enable & ~read_empty); 
            read_gray_next = (read_binary_next>>1) ^ read_binary_next;
            
    end

    always @(posedge read_clk , negedge read_reset_n) begin
        if (~read_reset_n)
            {read_binary, read_pointer} <= 0;
        else
            {read_binary, read_pointer} <= {read_binary_next, read_gray_next};
    end

    // FIFO empty logic
    always @(posedge read_clk , negedge read_reset_n) begin
        if (~read_reset_n)
            read_empty <= 1'b1;
        else
            read_empty <= (read_gray_next == read_to_write_pointer);
    end
endmodule

module sync_read_to_write #(parameter address_size = 3)
    (
    input                           write_reset_n,
    input                           write_clk,
    input       [address_size:0]    read_pointer,
    output reg  [address_size:0]    write_to_read_pointer
    );

    reg [address_size:0] tmp1_read_pointer;
    //Multi-flop synchronizer logic for passing the control signals and pointers
    always @(posedge write_clk , negedge write_reset_n) begin
        if (~write_reset_n)
            {write_to_read_pointer,tmp1_read_pointer} <= 0;
        else
            {write_to_read_pointer,tmp1_read_pointer} <= {tmp1_read_pointer,read_pointer};
    end
endmodule

module sync_write_to_read #(parameter address_size = 3)
    (
        input       [address_size:0]    write_pointer,
        input                           read_reset_n,
        input                           read_clk,
        output reg  [address_size:0]    read_to_write_pointer
    );

    reg [address_size:0] tmp1_write_pointer;
    
    always @(posedge read_clk , negedge read_reset_n) begin
        if (~read_reset_n)
            {read_to_write_pointer,tmp1_write_pointer} <= 0;
        else
            {read_to_write_pointer,tmp1_write_pointer} <= {tmp1_write_pointer,write_pointer};
    end
endmodule

module FIFO_top 
#(parameter data_size = 8,parameter address_size = 3)
(
    input [data_size-1:0]   write_data,
    input                   write_enable,
    input                   write_clk,
    input                   write_reset_n,

    input                   read_enable,
    input                   read_clk,
    input                   read_reset_n,

    output [data_size-1:0]  read_data,
    output                  write_full,
    output                  read_empty
);

wire [address_size-1:0]     write_address;
wire [address_size-1:0]     read_address;
wire [address_size:0]       write_pointer;
wire [address_size:0]       read_pointer;
wire [address_size:0]       write_to_read_pointer;
wire [address_size:0]       read_to_write_pointer;

FIFO_memory #(data_size, address_size) fifomem
(
    .write_clk              (write_clk),
    .write_enable           (write_enable),
    .write_data             (write_data),
    .write_address          (write_address),
    .read_data              (read_data),
    .read_address           (read_address),
    .write_full             (write_full)
);

read_pointer_empty #(address_size) read_pointer_empty
(
    .read_clk               (read_clk),
    .read_reset_n           (read_reset_n),
    .read_enable            (read_enable) ,
    .read_address           (read_address),
    .read_pointer           (read_pointer),
    .read_empty             (read_empty),
    .read_to_write_pointer  (read_to_write_pointer)
);

write_pointer_full #(address_size) write_pointer_full
(
    .write_clk              (write_clk),
    .write_reset_n          (write_reset_n),
    .write_enable           (write_enable),
    .write_address          (write_address),
    .write_pointer          (write_pointer),
    .write_full             (write_full),
    .write_to_read_pointer  (write_to_read_pointer)
);

sync_read_to_write sync_read_to_write
(
    .write_clk              (write_clk),
    .write_reset_n          (write_reset_n),
    .read_pointer           (read_pointer),
    .write_to_read_pointer  (write_to_read_pointer)
);

sync_write_to_read sync_write_to_read
(
    .read_clk               (read_clk),
    .read_reset_n           (read_reset_n),
    .write_pointer          (write_pointer),
    .read_to_write_pointer  (read_to_write_pointer)
);
endmodule