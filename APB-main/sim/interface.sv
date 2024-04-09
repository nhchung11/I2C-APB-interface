`ifndef INTF 
`define INTF
interface intf_i2c(input pclk, clk);
    logic [7:0]     pwdata;         
    logic [7:0]     prdata;
    logic [7:0]     paddr;
    logic [7:0]     data_write;
    logic           preset_n;
    logic           penable;
    logic           pselx;
    logic           pwrite;
    logic           pready;
    logic           rw;
    logic           check_data;
    logic           read_data;
    wire            sda;
    wire            scl;    
endinterface 
`endif 