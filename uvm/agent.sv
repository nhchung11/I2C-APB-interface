`ifndef AGENT
`define AGENT

`include "uvm_macros.svh"
`include "driver.sv"
`include "monitor.sv"
`include "packet.sv"
import uvm_pkg::*;

class agent extends uvm_agent;
    `uvm_component_utils(agent)
    // Define Sequencer, Driver, and Monitor
    driver my_driver;
    uvm_sequencer #(packet) my_sequencer;
    monitor my_monitor;
    
    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    // BUILD PHASE
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "AGENT BUILD PHASE", UVM_MEDIUM)
        my_driver = driver::type_id::create("my_driver", this);
        my_sequencer = uvm_sequencer #(packet)::type_id::create("my_sequencer", this);
        my_monitor = monitor::type_id::create("my_monitor", this);
    endfunction

    // CONNECT PHASE
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "AGENT CONNECT PHASE", UVM_MEDIUM)
        my_driver.seq_item_port.connect(my_sequencer.seq_item_export);
        if (!uvm_config_db #(virtual intf)::get(this, "*", "my_intf", my_driver.my_intf))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction: connect_phase

    // virtual task run_phase(uvm_phase phase);
    //     super.run_phase(phase);
    //     `uvm_info(get_name(), "AGENT RUN PHASE", UVM_MEDIUM)
    // endtask: run_phase
endclass
`endif