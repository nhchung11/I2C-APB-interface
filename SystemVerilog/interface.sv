`ifndef INTF
`define INTF


 interface intf_cnt(input clk);

    //wire clk;
    logic reset;
    logic data;
    logic [0:3] count;

 endinterface
`endif