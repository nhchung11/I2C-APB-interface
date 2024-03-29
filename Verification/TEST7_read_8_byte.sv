`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        
            env.drvr.RESET();
            env.drvr.READ(8, 7'b001_0000, 0);      
        end
endprogram