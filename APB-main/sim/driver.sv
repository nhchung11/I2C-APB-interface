`ifndef DRIVER
`define DRIVER
`include "stimulus.sv"
`include "scoreboard.sv"

class driver;
    stimulus    sti;
    scoreboard  sb; 
    
    virtual intf_i2c intf;
    

    covergroup cov @(posedge intf.pclk);
        reg_addr: coverpoint intf.paddr {
            bins bin2   = {2};              // Command
            bins bin4   = {4};              // Transmit
            bins bin6   = {6};              // Address
            bins bin3   = {3};              // Status
            bins bin5   = {5};              // Receive
        }
        
        rw: coverpoint intf.pwrite{
            bins write  = {1};              // Write
            bins read   = {0};              // Read
        }

        rw_reg: cross reg_addr, rw
        {
            bins read_status = rw_reg with (reg_addr == 3 && rw == 1);
            bins read_receive = rw_reg with (reg_addr == 5 && rw == 1); 
            bins write_command = rw_reg with (reg_addr == 2 && rw == 0);
            bins write_address = rw_reg with (reg_addr == 6 && rw == 0); 
            bins write_transmit = rw_reg with (reg_addr == 4 && rw == 0);  
        }
    endgroup

    

    function new (virtual intf_i2c intf, scoreboard sb);
        this.intf   = intf;
        this.sb     = sb;
        cov         = new();
    endfunction

    task assign_intf(stimulus sti);
        intf.penable    = sti.PENABLE;
        intf.paddr      = sti.PADDR;
        intf.pselx      = sti.PSELx;
        intf.pwdata     = sti.PWDATA;
        intf.pwrite     = sti.PWRITE;
    endtask

    // Reset task
    task RESET();
        intf.pwdata     = 0;
        intf.prdata     = 0;
        intf.paddr      = 0;
        intf.penable    = 0;
        intf.pselx      = 0;
        intf.pwrite     = 0;
        intf.pready     = 0;
        intf.preset_n   = 0;
        repeat(5)
            @(posedge intf.pclk); 
        intf.preset_n = 1;
    endtask

    // Write to address register 
    task WRITE_REGISTER(input bit [7:0] paddr, bit [7:0] pwdata, bit rw);
        sti = new();

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = paddr;
        sti.PWDATA = pwdata;
        sti.PWRITE = rw;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable = sti.PENABLE;
        if (intf.paddr == 4) begin
            sb.data_transmitted.push_back(intf.pwdata);
            sb.display();
        end
        @(posedge intf.pclk)
        intf.penable = 0;
        intf.pselx = 0;
    endtask

    

    // Read receive task
    task READ_REGISTER(input bit [7:0] paddr, bit rw);
        sti = new();

        @(posedge intf.pclk);
        sti.clock_1();
        sti.PADDR = paddr;
        sti.PWRITE = rw;
        assign_intf(sti);

        @(posedge intf.pclk);
        sti.clock_2();
        intf.penable = sti.PENABLE;
        @(posedge intf.pclk)
        intf.penable = 0;
        if (paddr == 3)
            $display("APB read data = %b from status register", intf.prdata);
        else if (paddr == 5)
            $display("APB read data = %b from receive register", intf.prdata);
    endtask
endclass
`endif 