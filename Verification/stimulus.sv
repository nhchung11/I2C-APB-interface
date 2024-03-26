`ifndef STI
`define STI

class stimulus;
    rand bit [7:0]  PADDR;
    rand bit [7:0]  PWDATA;

    // Constraint registor address
    constraint address_constraint{
        PADDR >= 8'b00000000;
        PADDR <= 8'b00001000;
    }
endclass
`endif 