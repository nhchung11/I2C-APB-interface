`ifndef SCOREBOARD
`define SCOREBOARD

class scoreboard;
    bit [7:0]   slave_address;
    bit [7:0]   data_write [0:7];
    bit [7:0]   data_read;
    bit [7:0]   status;
    bit         rw;
    bit         ack;
    bit         start;
    bit         stop;
    bit         apb_ready;
endclass
`endif 