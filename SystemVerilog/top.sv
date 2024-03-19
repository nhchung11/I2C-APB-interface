`include "stimulus.sv"
`include "interface.sv"
`include "scoreboard.sv"
`include "driver.sv"
`include "monitor.sv"
`include "env.sv"
`include "assertion.sv"

`include "test_1.sv"
  module top();
      reg clk = 0;
      initial  // clock generator
      forever #5 clk = ~clk;
      
      // DUT/assertion monitor/testcase instances
      intf_cnt intf(clk);
      ones_counter DUT(clk,intf.reset,intf.data,intf.count);
      testcase test(intf);
      assertion_cov acov(intf);
   endmodule