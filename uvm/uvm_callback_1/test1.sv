//`include "uvm.svh"
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "driver.sv"

module test;

Driver drvr;

initial begin
  drvr = new("drvr");
  run_test();
end 

endmodule 
