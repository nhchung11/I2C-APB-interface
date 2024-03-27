`ifndef STI
`define STI

class stimulus;
    rand bit [7:0]      PADDR;
    rand bit [7:0]      PWDATA;
    bit                 PSELx;
    bit                 PENABLE;
    bit                 PWRITE;
    bit                 PRESETn;

    // Constraint registor address
    constraint address_constraint{
        PADDR >= 8'b00000000;
        PADDR <= 8'b00001000;
    }
    task clock_1();
        PSELx = 1;
        PENABLE = 0;
    endtask

    task clock_2();
        PENABLE = 1;
    endtask
endclass
`endif 