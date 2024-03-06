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
    
    localparam FIFO_depth = 1<<address_size;
    reg [data_size-1:0] mem [0:FIFO_depth-1];
    
    // read the data at the output of memory
    assign read_data = mem[read_address];
    //Write a data on rising edge of write clock at specific address location 
    
    always @(posedge write_clk) begin
        if (write_enable && !write_full)
            mem[write_address] <= write_data;
    end
endmodule