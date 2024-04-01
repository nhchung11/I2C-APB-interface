// Transmit slave address correctly
// Transmit 1 byte data and receive ACK

`include "env.sv"
`timescale 1ns/1ns

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        env.drvr.RESET();
        env.drvr.WRITE_REGISTER(1, 4, 1);              // Prescale register
        env.drvr.WRITE_REGISTER(2, 8'b0010_0000, 1);   // Address register
        env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit data = 1
        env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);    // Command register
        // env.drvr.WRITE_REGISTER(4, 2);              // Transmit data = 2
        #10000;
        $finish;
    end
endprogram