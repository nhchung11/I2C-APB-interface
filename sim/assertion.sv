`ifndef ASSERT
`define ASSERT

module assertion_cov(intf_i2c intf);
    // PREADY CHECK
    PREADY_CHECK: cover property (@(posedge intf.pclk) (intf.pselx && !intf.penable) |=> (intf.penable) |-> (intf.pready));
endmodule
`endif 