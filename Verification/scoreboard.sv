`ifndef SCOREBOARD
`define SCOREBOARD
class scoreboard
    bit [7:0]   reg_address;
    bit [7:0]   slave_address;
    bit [7:0]   data_out;
    bit [7:0]   data_in;
    bit         rw;
    bit         ack;
    bit         start;
    bit         stop;
endclass

`endif 