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