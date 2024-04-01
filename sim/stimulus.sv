`ifndef STI
`define STI

class stimulus;
    bit [7:0]           PADDR;
    rand bit [7:0]      PWDATA;
    bit                 PSELx;
    bit                 PENABLE;
    bit                 PWRITE;
    bit                 PRESETn;
    task clock_1();
        PSELx = 1;
        PENABLE = 0;
    endtask

    task clock_2();
        PENABLE = 1;
    endtask
endclass
`endif 