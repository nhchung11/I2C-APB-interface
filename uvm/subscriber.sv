class subscriber extends uvm_subscriber#(instruction);


    function new(string name, uvm_component p = null);
        super.new(name,p);
    endfunction

    function void write(instruction t);
        `uvm_info(get_full_name(), $sformatf("receiving ",t.inst.name()), UVM_MEDIUM)
    endfunction

endclass : subscriber