// Transmit slave address correctly
// Continuously transmit data and receive ACK

`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    initial begin
        
            env.drvr.RESET();
            // env.drvr.READ(8, 7'b001_0000, 0);      
        end
endprogram