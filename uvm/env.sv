`include "uvm.svh"
import uvm_pkg::*;
`include "sequence_item.sv"
`include "monitor.sv"
`include "subscriber.sv"

class env extends uvm_env;
monitor mon;
subscriber sb,cov;

function new(string name = "env");
    super.new(name);
    mon = new("mon", this);
    sb  = new("sb", this);
    cov = new("cov", this);
endfunction

function void connect();
    mon.anls_port.connect(sb.analysis_export);
    mon.anls_port.connect(cov.analysis_export);
endfunction

task run();
    #1000;
    global_stop_request();
endtask

endclass


module test;
env e;

initial begin
e = new();
run_test();
end

endmodule