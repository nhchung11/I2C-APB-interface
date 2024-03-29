`ifndef DRIVER
`define DRIVER
`include "stimulus.sv"

class driver;
    stimulus sti;

    virtual intf_i2c intf;
    function new (virtual intf_i2c intf);
        this.intf   = intf;
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
        intf.pready = 0;
        intf.preset_n = 0;
        repeat(5)
            @(posedge intf.pclk); 
        intf.preset_n = 1;
    endtask

    // Write to address register 
    task WRITE_TO_ADDRESS_REG(input bit [6:0] slave_address, input bit rw);
        sti = new();

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
    endtask

    // Write to command register
    task WRITE_TO_COMMAND_REG();
        sti             = new();
        
        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR       = 8'b11000000;
        sti.PWDATA      = 8'b10010000;
        sti.PWRITE      = 1;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable    = sti.PENABLE;
    endtask

    // Write to transmit register
    task WRITE_TO_TRANSMIT_REG(input integer iteration, mem_depth);
        sti = new();
        sti.PADDR = 8'b10000000;
        sti.PWRITE = 1;
        repeat(iteration)
        begin      
            sti.clock_1();
            sti.randomize();
            assign_intf(sti);

            @(posedge intf.pclk);
            sti.clock_2();
            intf.penable    = sti.PENABLE;
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
    endtask

    // Read status task
    task READ_FROM_STATUS_REG();
        sti = new();

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = 8'b01100000;
        sti.PWRITE = 0;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable = sti.PENABLE;
    endtask

    // Read receive task
    task READ_FROM_RECEIVE_REG(input integer iteration);
        sti = new();

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = 8'b10100000;
        sti.PWRITE = 0;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable = sti.PENABLE;
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
    endtask
endclass
`endif 