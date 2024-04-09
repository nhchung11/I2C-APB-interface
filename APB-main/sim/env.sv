`ifndef ENV
`define ENV

`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
    driver drvr;
    virtual intf_i2c intf;
    monitor mntr;
    scoreboard sb;

    function new(virtual intf_i2c intf);
        this.intf   = intf;
        sb          = new();
        drvr        = new(intf, sb);
        mntr        = new(intf, sb);
    endfunction
endclass
`endif 