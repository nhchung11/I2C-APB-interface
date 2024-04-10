class monitor extends uvm_monitor;
    uvm_analysis_port #(instruction) anls_port;

    function new(string name, uvm_component p = null);
        super.new(name,p);
        anls_port = new("anls_port", this);
    endfunction

    task run;
       instruction inst;
       inst = new();
       #10ns;
       inst.inst = instruction::MUL;
       anls_port.write(inst);
       #10ns;
       inst.inst = instruction::ADD;
       anls_port.write(inst);
       #10ns;
       inst.inst = instruction::SUB;
       anls_port.write(inst);
    endtask

endclass