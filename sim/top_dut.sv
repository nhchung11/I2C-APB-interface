`include "stimulus.sv"
`include "interface.sv"
`include "driver.sv"
`include "env.sv"
`include "assertion.sv"

`include "TEST2.sv"
module top();
    reg PCLK = 1;
    reg core_clk = 1;

    always #20 core_clk= ~core_clk;
	always #5 PCLK= ~PCLK;
    

    // DUT/assertion monitor/testcase instances
    intf_i2c intf(PCLK, core_clk);
    
    top_level DUT
    (
        .PCLK       (intf.pclk),
        .PRESETn    (intf.preset_n),
        .PSELx      (intf.pselx),
        .PWRITE     (intf.pwrite),
        .PENABLE    (intf.penable),
        .PADDR      (intf.paddr),
        .PWDATA     (intf.pwdata),
        .core_clk   (intf.core_clk),

        .PREADY     (intf.pready),
        .PRDATA     (intf.prdata),
        .sda        (intf.sda),
        .scl        (intf.scl)
    );
    testcase test(intf);
    assertion_cov acov(intf);
    
endmodule