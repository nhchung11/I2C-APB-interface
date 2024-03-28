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

    task assign_intf(stimulus sti);
        intf.penable = sti.PENABLE;
        intf.paddr = sti.PADDR;
        intf.pselx = sti.PSELx;
        intf.pwdata = sti.PWDATA;
        intf.pwrite = sti.PWRITE;
    endtask

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
    task WRITE_TO_ADDRESS_REG(input bit [6:0] slave_address, input bit rw);
        sti = new();
        sti.rand_mode(0);

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = 8'b01000000;
        sti.PWDATA = {slave_address, rw};
        sti.PWRITE = 1;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable = sti.PENABLE;
        intf.rw = intf.pwdata[0];
        sb.apb_ready    = 1;
        sb.reg_address  = intf.paddr;
    endtask

    // Write to prescale register
    task WRITE_TO_PRESCALE_REG();
        sti = new();
        sti.rand_mode(0);

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR       = 8'b00100000;
        sti.PWDATA      = 8'd4;
        sti.PWRITE      = 1;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable    = sti.PENABLE;
        sb.apb_ready    = 1;
        sb.reg_address  = intf.paddr;
    endtask

    // Write to command register
    task WRITE_TO_COMMAND_REG();
        sti             = new();
        sti.rand_mode(0);
        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR       = 8'b11000000;
        sti.PWDATA      = 8'b10010000;
        sti.PWRITE      = 1;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable    = sti.PENABLE;
        sb.apb_ready    = 1;
        sb.reg_address  = intf.paddr;
    endtask

    // Write to transmit register
    task WRITE_TO_TRANSMIT_REG(input integer iteration, mem_depth);
        int i = 0;
        sti = new();
        sti.PADDR.rand_mode(0);
        sti.PADDR = 8'b10000000;
        sti.PWRITE = 1;
        repeat(iteration)
        begin      
            sti.clock_1();
            assign_intf(sti);
            sti.randomize();

            @(posedge intf.pclk);
            sti.clock_2();
            intf.penable    = sti.PENABLE;
            sb.apb_ready    = 1;

            // Save data out to scoreboard
            sb.data_write[i]= intf.pwdata;
            i               = i + 1;
            if (i == mem_depth - 1)
                i = 0;
            
        end
    endtask

    // Write task
    task WRITE(input integer iteration, mem_depth, input bit rw, input bit [6:0] slave_address);
        @(posedge intf.pclk);
        WRITE_TO_PRESCALE_REG();
        @(posedge intf.pclk);
        WRITE_TO_ADDRESS_REG(slave_address, rw);
        @(posedge intf.pclk);
        WRITE_TO_COMMAND_REG();
        @(posedge intf.pclk);
        WRITE_TO_TRANSMIT_REG(iteration, mem_depth);
        if (sti.PWDATA)
            cov.sample();
    endtask

    // Read status task
    task READ_FROM_STATUS_REG();
        sti = new();
        sti.PADDR.rand_mode(0);
        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = 8'b01100000;
        sti.PWRITE = 0;
        assign_intf(sti);
        @(posedge intf.pclk);
        sti.PENABLE = 1;
        intf.penable = sti.PENABLE;
        sb.apb_ready = 1;
    endtask

    // Read receive task
    task READ_FROM_RECEIVE_REG(input integer iteration);
        sti = new();
        sti.PADDR.rand_mode(0);
        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = 8'b10100000;
        sti.PWRITE = 0;
        assign_intf(sti);
        @(posedge intf.pclk);
        sti.PENABLE = 1;
        intf.penable = sti.PENABLE;
        sb.apb_ready = 1;
    endtask

    // Read task
    task READ(input integer iteration, bit rw, bit [6:0] slave_address);
        @(posedge intf.pclk);
        WRITE_TO_PRESCALE_REG();
        @(posedge intf.pclk);
        WRITE_TO_ADDRESS_REG(slave_address, rw);
        @(posedge intf.pclk);
        WRITE_TO_COMMAND_REG();
        @(posedge intf.pclk);
        READ_FROM_RECEIVE_REG(iteration);
        if (sti.PWDATA)
            cov.sample();
    endtask
endclass
`endif 