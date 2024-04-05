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
                env.drvr.WRITE_REGISTER(1, 4, 1);              // Prescale register
                env.drvr.WRITE_REGISTER(2, 8'b1111_0000, 1);   // Address register
                env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit reigster
                env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);    // Command register
                #10000;
                env.mntr.SUMMARY();
                $finish;
            end
        join_any
    end
endprogram     


// PASSED //












