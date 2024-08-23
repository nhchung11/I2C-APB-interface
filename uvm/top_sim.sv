`ifndef TOP
`define TOP
`include "uvm_macros.svh"
`include "test.sv"
`include "interface.sv"
import uvm_pkg::*;

module top_sim();
    bit PCLK = 1;
    bit core_clk = 1;
    always #5 PCLK = ~PCLK;
    always #20 core_clk = ~core_clk;

    intf my_intf(PCLK, clk);
    top_level DUT
    (
        .PCLK           (PCLK),
        .core_clk       (core_clk),
        .PRESETn        (my_intf.PRESETn),
        .PSELx          (my_intf.PSELx),
        .PENABLE        (my_intf.PENABLE),
        .PWRITE         (my_intf.PWRITE),
        .sda            (my_intf.sda),
        .scl            (my_intf.scl),
        .PADDR          (my_intf.PADDR),
        .PWDATA         (my_intf.PWDATA),
        .PREADY         (my_intf.PREADY),
        .PRDATA         (my_intf.PRDATA)
    );

    i2c_slave_model SLAVE
    (
        .sda            (my_intf.sda),
        .scl            (my_intf.scl),
        .check_data     (my_intf.check_data),
        .read_data      (my_intf.read_data),
        .saved_data     (my_intf.saved_data),
        .right_address  (my_intf.right_address)
    ); 


    initial begin
        uvm_config_db#(virtual intf)::set(null, "*", "my_intf", my_intf);
        run_test("test");
    end
endmodule
`endif 
