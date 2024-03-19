////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`include "env.sv"
program testcase(intf_cnt intf);
  environment env = new(intf);
  
  initial
  begin
    env.drvr.reset();
    env.drvr.drive(100);
    env.drvr.reset();
    env.drvr.drive(100);
  end
endprogram
