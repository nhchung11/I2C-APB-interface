`ifndef MONITOR
`define MONITOR

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
                if (sb.rw != intf.pwrite)
                    $display("*  ERROR  * WRONG SLAVE ADDRESS: EXPECT %b, RECEIVED %b", sb.rw, intf.pwrite);
                
        end
    endtask

    // Check write data
    task DATA_WRITE_CHECK();
        forever begin
            @(posedge intf.pclk)
            // ... 
        end
    endtask

    // Check read data
    task DATA_READ_CHECK();
        forever begin
            @(posedge intf.pclk)
                if (sb.data_read != intf.prdata)
                    $display("*  ERROR  * WRONG DATA OUT: EXPECT %b, RECEIVED %b", sb.data_out, intf.prdata);          
        end
    endtask

    // Check start condition
    task START_CHECK();
        forever begin
            @(posedge intf.core_clk)
                if ((sb.start == 1) && (intf.scl == 1) && (intf.sda == 1))
                    $display("*  ERROR  * START CONDITION NOT DETECTED");
        end
    endtask

    // Check stop condition
    task STOP_CHECK();
        forever begin
            @(posedge int.core_clk)
                if ((sb.start == 1) && (intf.scl == 1) && (intf.sda == 0))
                    $display("*  ERROR  * STOP CONDITION NOT DETECTED");
        end
    endtask
endclass
`endif MONITOR