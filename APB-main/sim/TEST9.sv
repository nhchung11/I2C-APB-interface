// Transmit slave address 
// Tramsmit 1 byte data
// Read 1 byte data
`timescale 1ns/1ns
`include "env.sv"

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
                    env.drvr.WRITE_REGISTER(6, 8'b0010_0000, 1);   // Address register
                    env.drvr.WRITE_REGISTER(4, 0, 1);              // Transmit data = 0
                    env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 2, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 3, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 4, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 5, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 6, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, 7, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(2, 8'b11111100, 1);    // Enable I2C on command register

                    #25000;
                    env.drvr.WRITE_REGISTER(6, 8'b0010_0001, 1);   // Address register
                    env.drvr.WRITE_REGISTER(2, 8'b11111100, 1);    // Enable I2C on command register
                    #21000; 
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    env.drvr.READ_REGISTER(5, 0);
                    #5000 
                    env.mntr.SUMMARY();
                    $finish;
                end
            join_any
        end
endprogram