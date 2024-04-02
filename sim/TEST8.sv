// Transmit slave address 
// Tramsmit 4 byte data
// Read 4 byte data
`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
        initial begin
            env.drvr.RESET();
            env.drvr.WRITE_REGISTER(1, 4, 1);              // Prescale register
            env.drvr.WRITE_REGISTER(2, 8'b0010_0000, 1);   // Address register
            env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);    // Command register
            env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 2, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 3, 1);              // Transmit data = 1

            #20000;
            env.drvr.WRITE_REGISTER(6, 8'b00010000, 1);    // Command register
            #5000;
            env.drvr.WRITE_REGISTER(2, 8'b0010_0001, 1);   // Address register
            env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);    // Command register
            env.drvr.READ_REGISTER(5, 0);
            env.drvr.READ_REGISTER(5, 0);
            env.drvr.READ_REGISTER(5, 0);
            env.drvr.WRITE_REGISTER(6, 8'b00010000, 1);    // Command register
            #1000 
            $finish;
        end
endprogram