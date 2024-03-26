`ifndef ENV
`define ENV

`include "monitor.sv"
`include "driver.sv"

class environment;
    driver drvr;
    scoreboard sb;
    monitor mntr;
    virtual intf_i2c intf;

    function new(virtual intf_i2c intf);
        this.intf = intf;
        sb = new();
        drvr = new(intf, sb);
        mntr = new(intf, sb);
    endfunction
endclass
`endif 