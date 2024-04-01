// Transmit slave address correctly
// APB write 10 byte data. Only 8 byte data (FIFO TX depth) got transmitted
`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    int i = 2;
    initial begin
            env.drvr.RESET();
            env.drvr.WRITE_REGISTER(1, 4, 1);              // Prescale register
            env.drvr.WRITE_REGISTER(2, 8'b0010_0000, 1);   // Address register
            env.drvr.WRITE_REGISTER(4, 1, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(6, 8'b10010000, 1);    // Command register
            env.drvr.WRITE_REGISTER(4, 2, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 3, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 4, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 5, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 6, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 7, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 8, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 9, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 10, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(4, 11, 1);              // Transmit data = 1
            // repeat(10) begin
            //     env.drvr.WRITE_REGISTER(4, i, 1);              // Transmit data = 2
            //     i = i + 1;
            // end
            #40000;
            env.drvr.WRITE_REGISTER(6, 8'b00010000, 1);    // Command register
            #40500;
            $finish;
        end
endprogram