class stimuslus
    rand bit [7:0] PADDR;
    rand bit [7:0] PWDATA;
    constraint address_constraint{
        PADDR >= 8'b00000000;
        PADDR <= 8'b00000111;
    }
endclass