// Transmit wrong slave address
// Receive NACK then go to stop state

`include "env.sv"
`timescale 1ns/1ns

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        fork
            begin
                env.mntr.REGISTER_CHECK();
            end
            begin
                env.mntr.DATA_CHECK();
            end
            begin
                env.drvr.RESET();
                env.drvr.WRITE_REGISTER(2, 8'b11110110, 1);    // Apply reset on command register 
                env.drvr.READ_REGISTER(2, 0);              // Transmit data = 0
                env.drvr.READ_REGISTER(3, 0);              // Transmit data = 1
                env.drvr.READ_REGISTER(4, 0);              // Transmit data = 1
                env.drvr.READ_REGISTER(5, 0);              // Transmit data = 1
                env.drvr.READ_REGISTER(6, 0);              // Transmit data = 1
                #800;
                env.mntr.SUMMARY();
                $finish;
            end
        join_any
    end
endprogram     


// PASSED //












