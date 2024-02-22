`include "../mem/fifo_mem.v"
`include "../full/full.v"
`include "../empty/empty.v"
`include "../sync_r2w/sync_r2w.v"
`include "../sync_w2r/sync_w2r.v"

module FIFO_top 
#(parameter data_size = 8,parameter address_size = 3)
(
    input [data_size-1:0] write_data,
    input write_increment, write_clk, write_reset_n,
    input read_increment, read_clk, read_reset_n,
    output [data_size-1:0] read_data,
    output write_full,
    output read_empty
);

wire [address_size-1:0] write_address, read_address;
wire [address_size:0] write_pointer, read_pointer, write_to_read_pointer, read_to_write_pointer;

FIFO_memory #(data_size, address_size) fifomem
(
    .write_clk(write_clk),
    .write_clk_en(write_increment),
    .write_data(write_data),
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
endmodule