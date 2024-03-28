`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        fork
            env.mntr.START_CHECK();
            env.mntr.ADDRESS_CHECK();
            // env.mntr.DATA_WRITE_CHECK();
            env.mntr.STOP_CHECK();
        begin
            env.drvr.RESET();
            env.drvr.READ(18, 7'b001_0000, 0);      
        end
        join_any
    end
endprogram