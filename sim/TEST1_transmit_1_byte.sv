`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        env.drvr.RESET();
        env.drvr.WRITE(1, 8, 7'b001_0000, 1);       // iteration | slave_mem | slave_address| rw 
        #10000;
    end
endprogram                  












