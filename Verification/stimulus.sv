`ifndef STI
`define STI

class stimulus
    rand bit [7:0]  PADDR;
    rand bit [7:0]  PWDATA;
    bit             PRESETn;
    bit             PSELx;
    bit             PWRITE;

    // Constraint registor address
    constraint address_constraint{
        soft PADDR >= 8'b00000000;
        soft PADDR <= 8'b00001000;
    }  

    // Constraint pwdata
    constraint pwdata_constraint{
        // Constraint command reg
        if (PADDR == 8'b11000000) begin
           PWDATA[7].rand_mode(0);
           PWDATA[4].rand_mode(0);
           PWDATA[3].rand_mode(0);
        end

        // Constraint address reg
        if (PADDR == 8'b01000000) begin
            PWDATA[0].rand_mode(0);
        end
    }
endclass
`endif 