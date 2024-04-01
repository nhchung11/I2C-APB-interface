// Transmit slave address correctly
// APB write 10 byte data. Only 8 byte data (FIFO TX depth) got transmitted
`timescale 1ns/1ns
`include "env.sv"

program testcase(intf_i2c intf);
    environment env = new(intf);
    int i = 2;
    initial begin
            env.drvr.RESET();
            env.drvr.WRITE_REGISTER(1, 4);              // Prescale register
            env.drvr.WRITE_REGISTER(2, 8'b0010_0000);   // Address register
            env.drvr.WRITE_REGISTER(4, 1);              // Transmit data = 1
            env.drvr.WRITE_REGISTER(6, 8'b10010000);    // Command register
            repeat(10) begin
                env.drvr.WRITE_REGISTER(4, i);              // Transmit data = 2
                i = i + 1;
            end
            #40000;
            $finish;
        end
endprogram