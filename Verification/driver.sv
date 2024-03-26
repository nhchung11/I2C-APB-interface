`ifndef DRIVER
`define DRIVER
`include "stimulus.sv"
`include "scoreboard.sv"

class driver;
    stimulus sti;
    scoreboard sb;

    covergroup cov @(posedge intf.pclk);
        REG_ADDRESS: coverpoint sb.reg_address{
            bins b1 = {8'b00100000};
            bins b2 = {8'b01000000};
            bins b3 = {8'b01100000};
            bins b4 = {8'b10000000};
            bins b5 = {8'b10100000};
            bins b6 = {8'b11000000};
        }
        SLAVE_ADDRESS: coverpoint sb.slave_address;
        RW: coverpoint sb.rw;
        SLAVE_ADDRESS_CROSS_RW: cross SLAVE_ADDRESS, RW;
    endgroup

    virtual intf_i2c intf;
    function new (virtual intf_i2c intf, scoreboard sb);
        this.intf   = intf;
        this.sb     = sb;
        cov         = new();
    endfunction

    // Reset task
    task RESET();
        intf.pwdata = 0;
        intf.prdata = 0;
        intf.paddr = 0;
        intf.penable = 0;
        intf.pselx = 0;
        intf.pwrite = 0;
        intf.pready     = 0;
        @(posedge intf.pclk); 
        intf.preset_n = 1;
        @(posedge intf.pclk); 
        intf.preset_n = 0;
        @(posedge intf.pclk); 
        intf.preset_n = 1;
    endtask

    // Write to address register 
    task WRITE_TO_ADDRESS_REG();
        sti = new();
        intf.pready     = 0;
        intf.paddr      = 8'b01000000;
        intf.pwdata     = 8'b10101010;
        intf.pselx      = 1;
        intf.penable    = 0;
        intf.pwrite     = 1;
        @(posedge intf.pclk);
        intf.penable    = 1;
        sb.reg_address  = intf.paddr;
        sb.apb_ready    = 1;
    endtask

    // Write to prescale register
    task WRITE_TO_PRESCALE_REG();
        @(posedge intf.pclk);
        intf.pready     = 0;
        intf.paddr      = 8'b00100000;
        intf.pwdata     = 8'd4;
        intf.penable    = 0;
        intf.pwrite     = 1;
        @(posedge intf.pclk);
        intf.penable    = 1;
        sb.apb_ready    = 1;
        sb.reg_address  = intf.paddr;
    endtask

    // Write to command register
    task WRITE_TO_COMMAND_REG();
        @(posedge intf.pclk);
        sti             = new();
        intf.pready     = 0;
        intf.paddr      = 8'b11000000;
        intf.pwrite     = 1;
        if (sti.randomize()) begin
            intf.pwdata     = sti.PWDATA;
            intf.penable    = 0;
            @(posedge intf.pclk);
            intf.penable    = 1;
            sb.apb_ready    = 1;
            sb.reg_address  = intf.paddr;
        end
    endtask

    // Write to transmit register
    task WRITE_TO_TRANSMIT_REG(input integer iteration, mem_depth);
        int i = 0;
        repeat(iteration)
        begin
            sti = new();
            intf.paddr      = 8'b10000000;
            intf.pready     = 0;
            intf.pwrite     = 1;
            if(sti.randomize()) begin
                intf.pwdata     = sti.PWDATA;    
                intf.penable    = 0;
                @(posedge intf.pclk);
                intf.penable    = 1;
                sb.apb_ready    = 1;

                // Save data out to scoreboard
                sb.data_write[i]= intf.pwdata;
                i               = i + 1;
                if (i == mem_depth - 1)
                    i = 0;
            end
        end
    endtask

    // Write task
    task WRITE(input integer iteration, mem_depth);
        if (intf.paddr == 8'b00100000)
            WRITE_TO_PRESCALE_REG();
        else if (intf.paddr == 8'b01000000)
            WRITE_TO_ADDRESS_REG();
        else if (intf.paddr == 8'b10000000)
            WRITE_TO_TRANSMIT_REG(iteration, mem_depth);
        if (sti.PWDATA)
            cov.sample();
    endtask

    // Read task
    task READ(input integer iteration);

    endtask
endclass
`endif 