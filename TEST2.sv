// Transmit slave address 
// Transmit 1 byte data and receive ACK

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
                env.drvr.WRITE_REGISTER(2, 8'b11110100, 1);    // Apply reset on command register             
                env.drvr.WRITE_REGISTER(6, 8'b0010_0000, 1);   // Address register
                env.drvr.WRITE_REGISTER(4, 0, 1);              // Transmit data = 1
                // env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit data = 2
                env.drvr.WRITE_REGISTER(2, 8'b11111100, 1);    // Enable I2C on command register
                #10000;
                env.drvr.WRITE_REGISTER(2, 8'b11111000, 1);    // Stop transmitting
                #500;
                env.mntr.SUMMARY();
                $finish;
            end
        join_any
    end
endprogram




