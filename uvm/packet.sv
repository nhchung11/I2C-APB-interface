`ifndef PKT
`define PKT
`include "uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_sequence_item;
    bit PRESETn;
    bit PSELx;
    bit PENABLE;
    bit PWRITE;
    bit [7:0] PADDR;
    bit [7:0] PWDATA;
    bit [7:0] PRDATA;

    `uvm_object_utils_begin(packet)
        `uvm_field_int(PADDR, UVM_ALL_ON)
        `uvm_field_int(PWDATA, UVM_ALL_ON)  
        `uvm_field_int(PWRITE, UVM_ALL_ON)
    `uvm_object_utils_end

    // CONSTRUCTOR
    function new(string name = "packet");
        super.new(name);
    endfunction
endclass
`endif 