`include "stimulus.sv"
`include "interface.sv"
`include "scoreboard.sv"
`include "driver.sv"
`include "monitor.sv"
`include "env.sv"
`include "assertion.sv"

`include "test1.sv"
module top();
    reg PCLK = 0;
    reg core_clk = 0;

    // Generate clk  
    initial begin
        forever #5 PCLK = ~PCLK;
        forever #20 core_clk = ~core_clk;
    end

    // DUT/assertion monitor/testcase instances
    intf_i2c intf(PCLK, core_clk);
    
    top_level DUT
    (
        .PCLK       (PCLK),
        .PRESETn    (intf.preset_n),
        .PSELx      (intf.pselx),
        .PWRITE     (intf.pwrite),
        .PENABLE    (intf.penable),
        .PADDR      (intf.paddr),
        .PWDATA     (intf.pwdata),
        .core_clk   (core_clk),

        .PREADY     (intf.pready),
        .PRDATA     (intf.prdata),
        .sda        (intf.sda),
        .scl        (intf.scl)
    );
    i2c_slave_model SLAVE(scl, sda);

    testcase test(intf);
    assertion_cov acov(intf);
endmodule