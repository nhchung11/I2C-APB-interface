`ifndef DRIVER
`define DRIVER

`include "uvm_macros.svh"
`include "packet.sv"
// `include "interface.sv"
import uvm_pkg::*;

class driver extends uvm_driver #(packet);
    `uvm_component_utils(driver)
    packet my_packet;
    virtual intf my_intf;
    
    // CONSTRUCTOR
    function new (string name = "driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // BUILD PHASE
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "DRIVER BUILD PHASE", UVM_MEDIUM)
        my_packet = packet::type_id::create("my_packet");
        if(!uvm_config_db #(virtual intf)::get(this, "*", "my_intf", my_intf))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction
    
    // // CONNECT PHASE
    // function void connect_phase (uvm_phase phase);
       
    // endfunction

    // RUN PHASE
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_name(), "DRIVER RUN PHASE", UVM_MEDIUM)
        my_intf.PSELx <= 0;
        my_intf.PENABLE <= 0;
        my_intf.PWRITE <= 0;
        my_intf.PADDR <= 0;
        my_intf.PWDATA <= 0;
        my_intf.PRESETn <= 0;
        reset();
        `uvm_delay(100)
        forever begin
            bit [7:0] prdata;
            // `uvm_info(get_name(), $sformatf("Write %0d to register %0d", my_packet.PWDATA, my_packet.PADDR), UVM_LOW) 
            @(posedge my_intf.PCLK)
            seq_item_port.get_next_item(my_packet);
            if (my_packet.PWRITE) begin
                write(my_packet.PADDR, my_packet.PWDATA);
            end
            else begin
                read(my_packet.PADDR, prdata);
                my_packet.PRDATA = prdata;
            end
            seq_item_port.item_done();
        end
    endtask

    virtual task write(input bit [7:0] paddr, input bit [7:0] pwdata);
        my_intf.PSELx <= 1;
        my_intf.PENABLE <= 0;
        my_intf.PWRITE <= 1;
        my_intf.PADDR <= paddr;
        my_intf.PWDATA <= pwdata;
        @(posedge my_intf.PCLK);
        my_intf.PENABLE <= 1;
        @(posedge my_intf.PCLK);
        my_intf.PENABLE <= 0;
        my_intf.PSELx <= 0;
    endtask

    virtual task read(input bit [7:0] paddr, output bit [7:0] prdata);
        my_intf.PSELx <= 1;
        my_intf.PENABLE <= 0;
        my_intf.PWRITE <= 0;
        my_intf.PADDR <= paddr;
        @(posedge my_intf.PCLK);
        my_intf.PENABLE <= 1;
        @(posedge my_intf.PCLK);
        my_intf.PENABLE <= 0;
        my_intf.PSELx <= 0;
        prdata = my_intf.PRDATA;
    endtask

    virtual task reset();
        my_intf.PRESETn <= 0;
        @(posedge my_intf.PCLK);
        my_intf.PRESETn <= 1;
        `uvm_delay(100ns)
    endtask
endclass
`endif 
