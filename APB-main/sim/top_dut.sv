`include "stimulus.sv"
`include "interface.sv"
`include "driver.sv"
`include "env.sv"
`include "assertion.sv"
// `include "TEST9.sv"
`timescale 1ns/1ns

`ifdef  TEST0_1
    `include "TEST0_1.sv"
`elsif  TEST0_2
    `include "TEST0_2.sv"
`elsif  TEST1
    `include "TEST1.sv"
`elsif  TEST2
    `include "TEST2.sv"
`elsif  TEST3
    `include "TEST3.sv"
`elsif  TEST4
    `include "TEST4.sv"
`elsif  TEST5
    `include "TEST5.sv"
`elsif  TEST6
    `include "TEST6.sv"
`elsif  TEST7
    `include "TEST7.sv"
`elsif  TEST8
    `include "TEST8.sv"
`elsif  TEST9
    `include "TEST9.sv"
`elsif  TEST10
    `include "TEST10.sv"
`elsif  TEST11
    `include "TEST11.sv"
`elsif  TEST12
    `include "TEST12.sv"
`endif 

module top();
    reg PCLK = 1;
    reg clk = 1;

    always #20 clk= ~clk;
	always #5 PCLK= ~PCLK;
    

    // DUT/assertion monitor/testcase instances
    intf_i2c        intf(PCLK, clk);


    apb_to_i2c_top  DUT
    (
        .PCLK       (intf.pclk),
        .PRESETn    (intf.preset_n),
        .PSELx      (intf.pselx),
        .PWRITE     (intf.pwrite),
        .PENABLE    (intf.penable),
        .PADDR      (intf.paddr),
        .PWDATA     (intf.pwdata),
        .clk        (intf.clk),

        .PREADY     (intf.pready),
        .PRDATA     (intf.prdata),
        .i2c_sda    (intf.sda),
        .i2c_scl    (intf.scl)
    );

    i2c_slave_model MODEL
    (   
        .sda        (intf.sda),
        .scl        (intf.scl),
        .saved_data (intf.data_write),
        .check_data (intf.check_data),
        .read_data  (intf.read_data)
    );
    testcase        test(intf);
    assertion_cov   acov(intf);

    // assign intf.pready = DUT.PREADY;
endmodule