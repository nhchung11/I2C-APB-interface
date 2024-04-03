`ifndef ASSERT
`define ASSERT

module assertion_cov(intf_i2c intf);
    // PREADY CHECK
    PREADY_CHECK: cover property (@(posedge intf.pclk) (intf.pselx && !intf.penable) |=> (intf.penable) |-> (intf.pready));

    WRITE_REGISTER_CHECK: cover property(@(posedge intf.pclk) ((intf.paddr == 1) || (intf.paddr == 2) || (intf.paddr == 4) || (intf.paddr == 6)) |-> (intf.pwrite));

    READ_REGISTER_CHECK: cover property (@(posedge intf.pclk) ((intf.paddr == 3) || (intf.paddr == 5)) |-> (!intf.pwrite));
endmodule
`endif 