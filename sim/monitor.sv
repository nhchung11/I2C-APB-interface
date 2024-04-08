`ifndef MONITOR
`define MONITOR
`include "scoreboard.sv"

class monitor;
    virtual intf_i2c    intf;
    scoreboard          sb;
    byte                tmp;
    int                 number_wrong_data_transmitted;
    // int                 number_data_transmitted;

    function new(virtual intf_i2c intf, scoreboard sb);
        this.intf   = intf;
        this.sb     = sb;
        // this.number_data_transmitted = 1;
        this.number_wrong_data_transmitted = 0;
    endfunction
    
    task REGISTER_CHECK();
        forever
        @ (negedge intf.pclk)
        if (((intf.paddr == 1) || (intf.paddr == 2) || (intf.paddr == 4) || (intf.paddr == 6)) && (!intf.pwrite) && (intf.penable))
            $display("*  ERROR  * Read from only write register");
        else if (((intf.paddr == 3) || (intf.paddr == 5)) && (intf.pwrite) && (intf.penable))
            $display("*  ERROR  * Write to only read register");
    endtask

    task DATA_CHECK();
        forever
        // @(posedge intf.clk)
        @(posedge intf.check_data) begin
            // $display("Checking");
            // number_data_transmitted = number_data_transmitted + 1;
            tmp = sb.data_transmitted.pop_front();
            if (intf.check_data) begin
                $display("%t: check_data = %b, data_write = %b, scoreboard_data = %b", $time ,intf.check_data, intf.data_write, tmp);
                if (intf.data_write != tmp) begin
                    number_wrong_data_transmitted = number_wrong_data_transmitted + 1;
                    $display("*  ERROR  * Wrong data transmitted");
                end
            end
        end
    endtask

    task SUMMARY();
        $display("=============SUMMARY=============");
        // $display("Transmit total %d byte", number_data_transmitted);
        $display("Number of wrong data: %d", number_wrong_data_transmitted);
    endtask
endclass
`endif
