`ifndef MONITOR
`define MONITOR

class monitor;
        virtual intf_i2c intf;
        
        function new(virtual intf_i2c intf);
            this.intf = intf;
        endfunction
        
        task REGISTER_CHECK();
            forever
            @ (negedge intf.pclk)
            if (((intf.paddr == 1) || (intf.paddr == 2) || (intf.paddr == 4) || (intf.paddr == 6)) && (!intf.pwrite) && (intf.penable))
                $display("*  ERROR  * Read from only write register");
            else if (((intf.paddr == 3) || (intf.paddr == 5)) && (intf.pwrite) && (intf.penable))
                $display("*  ERROR  * Write to only read register");
        endtask
endclass
`endif
