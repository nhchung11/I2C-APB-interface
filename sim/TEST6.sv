// Transmit slave address correctly
// Transmit 2 byte 
// Receive SR command from APB
// Transmit to other slave
// Transmit 2 byte data

`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        
            env.drvr.RESET();
            // env.drvr.READ(1, 7'b001_0000, 0);      
        end
endprogram