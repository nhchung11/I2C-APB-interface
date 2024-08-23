`ifndef SUBS
`define SUBS

// `timescale 1ns/1ns
`include "uvm_macros.svh"
`include "packet.sv"
import uvm_pkg::*;

class subscriber extends uvm_subscriber #(packet);
    `uvm_component_utils(subscriber)
    uvm_analysis_imp #(packet, subscriber) subscriber_analysis_imp;
    byte PADDR;
    bit PWRITE;

    covergroup cov;
        reg_addr: coverpoint PADDR 
        {
            bins bin2   = {2};              // Command
            bins bin4   = {4};              // Transmit
            bins bin6   = {6};              // Address
            bins bin3   = {3};              // Status
            bins bin5   = {5};              // Receive
        }

        rw: coverpoint PWRITE
        {
            bins write  = {1};              // Write
            bins read   = {0};              // Read
        }

        rw_reg: cross reg_addr, rw
        {
            bins read_status = rw_reg with (reg_addr == 3 && rw == 1);
            bins read_receive = rw_reg with (reg_addr == 5 && rw == 1); 
            bins write_command = rw_reg with (reg_addr == 2 && rw == 0);
            bins write_address = rw_reg with (reg_addr == 6 && rw == 0); 
            bins write_transmit = rw_reg with (reg_addr == 4 && rw == 0);  
        }
    endgroup

    // CONSTRUCTOR
    function new (string name = "subscriber", uvm_component parent);
        super.new(name, parent);
        cov = new();
        subscriber_analysis_imp = new("subscriber_analysis_imp", this);
    endfunction

    // BUILD PHASE
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "SUBSCRIBER BUILD PHASE", UVM_LOW)
    endfunction : build_phase

    // SAMPLE
    virtual function void write(packet t);
        `uvm_info(get_name(), "sample", UVM_LOW)
        PADDR = t.PADDR;
        PWRITE = t.PWRITE;
        cov.sample();
    endfunction 
endclass : subscriber
`endif                                  

