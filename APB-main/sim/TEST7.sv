// Transmit slave address correctly
// Continuously transmit data and receive ACK

`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    int i = 0;
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
                repeat(6) begin
                    #15000;
                    env.drvr.WRITE_REGISTER(2, 8'b00000000, 1);    // Apply reset           
                    env.drvr.WRITE_REGISTER(6, 8'b0010_0000, 1);   // Address register

                    env.drvr.WRITE_REGISTER(4, i, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, i+1, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, i+2, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(4, i+3, 1);              // Transmit data = 1
                    env.drvr.WRITE_REGISTER(2, 8'b11111100, 1);    // Enable I2C on command register
                    i = i + 4;
                end
                #650000;
                env.drvr.WRITE_REGISTER(2, 8'b11111000, 1);    // Stop transmitting
                #1000;
                env.mntr.SUMMARY();
                $finish;
            end   
        join_any
    end
endprogram