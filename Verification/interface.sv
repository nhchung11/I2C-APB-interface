`ifndef INTF 
`define INTF
interface intf_i2c(input pclk, core_clk);
    logic [7:0]     pwdata;
    logic [7:0]     prdata;
    logic [7:0]     paddr;
    logic           preset_n;
    logic           penable;
    logic           pselx;
    logic           pwrite;
    logic           pready;
    wire            sda;
    wire            scl;    
    logic           rw;
endinterface 
`endif 