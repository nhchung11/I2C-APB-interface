module FIFO_memory 
#(parameter data_size = 8, parameter address_size = 3)
//let us define the data and address size to get 8 location X 8 bit memory
(
    input [data_size-1:0]       write_data,
    input [address_size-1:0]    write_address,
    input [address_size-1:0]    read_address,
    input                       write_clk_en,
    input                       write_full,
    input                       write_clk,
    output [data_size-1:0]      read_data
);

localparam FIFO_depth = 1<<address_size;
reg [data_size-1:0] mem [0:FIFO_depth-1];
assign read_data = mem[read_address];

always @(posedge write_clk)
    if (write_clk_en && !write_full)
        mem[write_address] <= write_data;
endmodule