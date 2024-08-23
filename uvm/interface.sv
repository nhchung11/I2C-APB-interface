`ifndef INTERF
`define INTERF

interface intf(input logic PCLK, clk);
    // Inputs
    logic           PRESETn;
    logic           PSELx;
    logic           PENABLE;
    logic           PWRITE;
    logic [7:0]     PADDR;
    logic [7:0]     PWDATA;

    // Outputs
    logic           PREADY;
    logic [7:0]     PRDATA;

    // Wires
    wire            sda;
    wire            scl;
    logic           check_data;
    logic           read_data;
    logic           right_address;
    logic [7:0]     saved_data;
endinterface
`endif 

