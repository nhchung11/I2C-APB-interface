module fifo 
#(
    parameter data_size = 8,
    parameter address_size = 3
)
(
    input                       clk,
    input                       reset_n,
    input                       W_ENA,
    input                       R_ENA,
    input [data_size - 1:0]     APB_TX,

    output                      WRITE_FULL,
    output                      READ_EMPTY,
    output [data_size - 1:0]    APB_RX
);
reg 
endmodule