`ifndef STI
`define STI

class stimuslus
    rand bit [7:0]  PADDR;
    rand bit [7:0]  PWDATA;
    rand bit        PRESETn;
    rand bit        PSELx;
    rand bit        PWRITE;
    rand bit [7:0]  PWDATA;
    constraint address_constraint{
        PADDR >= 8'b00000000;
        PADDR <= 8'b00000111;
    }  
endclass
`endif 