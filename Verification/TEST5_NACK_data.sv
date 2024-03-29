`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
            env.drvr.RESET();
            env.drvr.WRITE(1, 8, 7'b001_1010, 1);
        end
endprogram