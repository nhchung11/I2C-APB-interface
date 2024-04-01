`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
            env.drvr.RESET();
            env.drvr.WRITE(18, 8, 7'b001_0000, 1);
        end
endprogram