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
reg [data_size - 1:0] mem [0: 2**address_size - 1];
reg [address_size - 1:0] w_ptr;
reg [address_size - 1:0] r_ptr;

// Write
always @(posedge clk, negedge reset_n) begin
    if (!rst_n) 
        w_ptr <= {(address_size){1'b0}};
    else begin
        if (!WRITE_FULL)
    end
end
endmodule