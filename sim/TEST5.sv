// Transmit slave address correctly
// Write 2 byte and receive ACK
// APB reset then continue to write 2 byte

`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
            env.drvr.RESET();
            env.drvr.WRITE_REGISTER(1, 4, 1);               // Prescale register
            env.drvr.WRITE_REGISTER(2, 8'b0010_0000, 1);    // Address register
            env.drvr.WRITE_REGISTER(4, 1, 1);               // Transmit data = 1
            env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);     // Command register
            env.drvr.WRITE_REGISTER(4, 2, 1);               // Transmit data = 2
            #10000;
            env.drvr.RESET();                               // Apply reset 
            env.drvr.WRITE_REGISTER(4, 1, 1);               // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 2, 1);               // Transmit data = 2
            #10000;
            env.drvr.WRITE_REGISTER(6, 8'b0010000, 1);     // Command register
            #500;
            $finish;
        end
endprogram