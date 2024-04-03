`ifndef ENV
`define ENV

`include "driver.sv"
`include "monitor.sv"

class environment;
    driver drvr;
    monitor mntr;
    virtual intf_i2c intf;

    function new(virtual intf_i2c intf);
        this.intf   = intf;
        drvr        = new(intf);
        mntr        = new(intf);
    endfunction
endclass
`endif 