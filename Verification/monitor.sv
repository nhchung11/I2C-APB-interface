`ifndef MONITOR
`define MONITOR

class monitor;
    scoreboard sb;
    virtual intf_i2c intf;

    function new(virtual intf_i2c intf, scoreboard sb);
        this.intf = intf;
        this.sb = sb;
    endfunction

    task check();
        forever begin
            @(posedge intf.pclk)
                if (sb.rw != intf.pwrite)
                    $display("*  ERROR  * wrong slave address: expect %b, received %b", sb.rw, intf.pwrite);
                else if (sb.data_out != intf.prdata)
                    $display("*  ERROR  * wrong data out: expect %b, received %b", sb.data_out, intf.prdata);          
        end
    endtask
endclass
`endif MONITOR