// Transmit slave address correctly
// Transmit 1 byte data and receive NACK

`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
            env.drvr.RESET();
            // env.drvr.WRITE(1, 7'b001_1010, 1);
        end
endprogram