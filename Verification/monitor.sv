`ifndef MONITOR
`define MONITOR
`include "scoreboard.sv"

class monitor;
    scoreboard sb;
    virtual intf_i2c intf;

    function new(virtual intf_i2c intf, scoreboard sb);
        this.intf = intf;
        this.sb = sb;
    endfunction

    // Check slave address
    task ADDRESS_CHECK();
        forever begin
            @(posedge intf.pclk)
                if (sb.slave_address != intf.slave_address)
                    $display("*  ERROR    * WRONG SLAVE ADDRESS: EXPECT %b, RECEIVED %b", sb.rw, intf.pwrite);
                else
                    $display("*  CORRECR  *EXPECT ADDRESS %b, RECEIVE %b", sb.rw, intf.pwrite);
                
        end
    endtask


    // Check read data
    task DATA_READ_CHECK();
        forever begin
            @(posedge intf.pclk)
                if (sb.data_read != intf.prdata)
                    $display("*  ERROR    * WRONG DATA READ: EXPECT %b, RECEIVED %b", sb.data_read, intf.prdata);          
        end
    endtask

    // Check start condition
    task START_CHECK();
        forever begin
            @(posedge intf.core_clk)
                if ((sb.start == 1) && (intf.scl == 1) && (intf.sda == 0))
                    $display("[START CONDITION NOT DETECTED] \t");
        end
    endtask

    // Check stop condition
    task STOP_CHECK();
        forever begin
            @(posedge intf.core_clk)
                if ((sb.start == 1) && (intf.scl == 1) && (intf.sda == 0))
                    $display("[STOP CONDITION NOT DETECTED] \t");
        end
    endtask
endclass
`endif 