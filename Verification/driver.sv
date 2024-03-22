`ifndef DRIVER
`define DRIVER
`include "stimulus.sv"
`include "scoreboard.sv"

class driver
    stimuslus sti;
    scoreboard sb;

    covergroup cov;
        REG_ADDRESS: coverpoint sb.reg_address{

        };
        SLAVE_ADDRESS: coverpoint sb.slave_address{
            
        };
        RW: coverpoint sb.rw{

        };
        SLAVE_ADDRESS_CROSS_RW: cross sb.reg_address, sb.rw;
    endgroup

    virtual intf_i2c intf;
    function new (virtual intf_i2c intf, scoreboard sb);
        this.intf   = intf;
        this.sb     = sb;
        cov         = new();
    endfunction

    task reset();
        intf.pwdata = 0;
        intf.prdata = 0;
        intf.paddr = 0;
        intf.penable = 0;
        intf.pselx = 0;
        intf.pwrite = 0;
        @(posedge intf.pclk); 
        intf.preset_n = 1;
        @(posedge intf.pclk); 
        intf.preset_n = 0;
        @(posedge intf.pclk); 
        intf.preset_n = 1;
    endtask

    task drive(input integer iteration;);
        repeat(iteration)
        begin
            sti = new();
            @(posedge intf.pclk);
            if (sti.randomize())
                intf 
        end
    endtask
endclass
`endif 