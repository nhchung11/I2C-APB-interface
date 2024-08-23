`ifndef BASE_SEQ
`define BASE_SEQ
`include "uvm_macros.svh"
`include "../uvm/register_model.sv"

class base_sequence extends uvm_sequence;
    `uvm_object_utils(base_sequence)
    register_model my_regmodel;
    rand bit [7:0] random_data;

    constraint random_data_c {random_data > 0;}

    function new(string name = "base_sequence");
        super.new(name);
    endfunction
endclass

class WRITE_TO_ALL_REG extends base_sequence;
    `uvm_object_utils(WRITE_TO_ALL_REG)

    function new(string name = "WRITE_TO_ALL_REG");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "================ WRITE TO ALL REGISTER ================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 1);
        this.my_regmodel.reg_transmit.write(status, 2);
        this.my_regmodel.reg_address.write(status, 3);
        this.my_regmodel.reg_receive.write(status, 4);
        this.my_regmodel.reg_status.write(status, 5);
        `uvm_delay(1000ns)

    endtask
endclass

class READ_DEFAULT_VALUE extends base_sequence;
    `uvm_object_utils(READ_DEFAULT_VALUE)

    function new(string name = "READ_DEFAULT_VALUE");
        super.new(name);
    endfunction

    virtual task body();
        uvm_reg_data_t data;
        uvm_status_e status;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "================== READ DEFAULT VALUE =================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.read(status, data);
        this.my_regmodel.reg_status.read(status, data);
        this.my_regmodel.reg_transmit.read(status, data);
        this.my_regmodel.reg_receive.read(status, data);
        this.my_regmodel.reg_address.read(status, data);
        `uvm_delay(500ns)

    endtask
endclass

class ADDRESS_NACK extends base_sequence;
    `uvm_object_utils(ADDRESS_NACK)

    function new(string name = "ADDRESS_NACK");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "================= RECEIVE ADDRESS NACK ================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b1110_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(5000ns)

    endtask
endclass

class TRANSMIT_1_DATA extends base_sequence;
    `uvm_object_utils(TRANSMIT_1_DATA)

    function new(string name = "TRANSMIT_1_DATA");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "==================== TRANSMIT 1 DATA ==================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        my_regmodel.reg_command.write(status, 8'b11110110);
        my_regmodel.reg_address.write(status, 8'b0010_0000);
        my_regmodel.reg_transmit.write(status, 0);
        my_regmodel.reg_transmit.write(status, 1);
        my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(10000ns)

    endtask
endclass

class WRITE_FULL_TX_FIFO extends base_sequence;
    `uvm_object_utils(WRITE_FULL_TX_FIFO)

    function new(string name = "WRITE_FULL_TX_FIFO");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "=================== WRITE FULL TX FIFO ================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_transmit.write(status, 2);
        this.my_regmodel.reg_transmit.write(status, 3);
        this.my_regmodel.reg_transmit.write(status, 4);
        this.my_regmodel.reg_transmit.write(status, 5);
        this.my_regmodel.reg_transmit.write(status, 6);
        this.my_regmodel.reg_transmit.write(status, 7);
        this.my_regmodel.reg_transmit.write(status, 8);
        this.my_regmodel.reg_transmit.write(status, 9);
        this.my_regmodel.reg_transmit.write(status, 10);
        this.my_regmodel.reg_transmit.write(status, 11);
        this.my_regmodel.reg_transmit.write(status, 12);
        this.my_regmodel.reg_transmit.write(status, 13);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(20000ns)
    endtask
endclass

class DATA_NACK extends base_sequence;
    `uvm_object_utils(DATA_NACK)

    function new(string name = "DATA_NACK");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "=================== RECEIVE DATA NACK =================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_transmit.write(status, 2);
        this.my_regmodel.reg_transmit.write(status, 3);
        this.my_regmodel.reg_transmit.write(status, 4);
        this.my_regmodel.reg_transmit.write(status, 5);
        this.my_regmodel.reg_transmit.write(status, 6);
        this.my_regmodel.reg_transmit.write(status, 7);
        this.my_regmodel.reg_transmit.write(status, 8);
        this.my_regmodel.reg_transmit.write(status, 9);
        this.my_regmodel.reg_transmit.write(status, 10);
        this.my_regmodel.reg_transmit.write(status, 11);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(20000ns)
    endtask
endclass

class WRITE_THEN_RESET extends base_sequence;
    `uvm_object_utils(WRITE_THEN_RESET)

    function new(string name = "WRTE_THEN_RESET");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;  
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "==================== WRITE THEN RESET =================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)  
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_command.write(status, 8'b11111110);

        // Applying reset on adress
        `uvm_delay(1000)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        `uvm_delay(1000)

        // Retry to write
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_command.write(status, 8'b11111110);

        // Applying reset on data
        `uvm_delay(2000)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        `uvm_delay(1000)
    endtask
endclass

class WRITE_WITH_SR extends base_sequence;
    `uvm_object_utils(WRITE_WITH_SR)

    function new(string name = "WRITE_WITH_SR");    
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "=============== WRITE WITH REPEATED START =============", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        for (int i = 0; i < 3; i++) begin
            if (!std::randomize(this.random_data)) begin
                `uvm_error("MY_TEST", "Randomization failed")
            end
            this.my_regmodel.reg_transmit.write(status, this.random_data);
        end
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(10000ns)
    endtask
endclass

class WRITE_MANY_DATA extends base_sequence;
    `uvm_object_utils(WRITE_MANY_DATA)

    function new(string name = "WRITE_MANY_DATA");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "==================== WRITE MANY DATA ==================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        for (int i = 0; i < 7; i++) begin
            if (!std::randomize(this.random_data)) begin
                `uvm_error("TEST7", "Randomization failed")
            end
            this.my_regmodel.reg_transmit.write(status, this.random_data);
        end
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(16000ns)

        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        for (int i = 0; i < 7; i++) begin
            if (!std::randomize(this.random_data)) begin
                `uvm_error("TEST7", "Randomization failed")
            end
            this.my_regmodel.reg_transmit.write(status, this.random_data);
        end
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(16000ns)

        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        for (int i = 0; i < 7; i++) begin
            if (!std::randomize(this.random_data)) begin
                `uvm_error("TEST7", "Randomization failed")
            end
            this.my_regmodel.reg_transmit.write(status, this.random_data);
        end
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(16000ns)
    endtask
endclass

class READ_1_DATA extends base_sequence;
    `uvm_object_utils(READ_1_DATA)

    function new(string name = "READ_1_DATA");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        uvm_reg_data_t data;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "====================== READ 1 DATA ====================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        my_regmodel.reg_command.write(status, 8'b11110110);
        my_regmodel.reg_address.write(status, 8'b0010_0000);
        my_regmodel.reg_transmit.write(status, 0);
        my_regmodel.reg_transmit.write(status, 1);
        my_regmodel.reg_command.write(status, 8'b11111100);
        `uvm_delay(5000ns)

        my_regmodel.reg_address.write(status, 8'b0010_0001);
        my_regmodel.reg_command.write(status, 8'b11111100);
        `uvm_delay(5000ns)
        my_regmodel.reg_receive.read(status, data);
        `uvm_delay(1000ns)

        // PASS //
    endtask
endclass

class READ_TO_FIFORX_EMPTY extends base_sequence;
    `uvm_object_utils(READ_TO_FIFORX_EMPTY)

    function new(string name = "READ_TO_FIFORX_EMPTY");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        uvm_reg_data_t data;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "=============== READ FROM FIFO RX TO EMPTY ============", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        my_regmodel.reg_command.write(status, 8'b11110110);
        my_regmodel.reg_address.write(status, 8'b0010_0000);
        my_regmodel.reg_transmit.write(status, 0);
        for (int i = 0; i < 6; i++) begin
            if (!std::randomize(this.random_data)) begin
                `uvm_error("TEST9", "Randomization failed")
            end
            this.my_regmodel.reg_transmit.write(status, this.random_data);
        end
        my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(16000ns)

        
        my_regmodel.reg_command.write(status, 8'b11110110);
        my_regmodel.reg_address.write(status, 8'b0010_0001);
        my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(16000ns)
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data);
        my_regmodel.reg_receive.read(status, data); 
        `uvm_delay(2000ns)
    endtask
endclass

class WRITE_READ_COMB extends base_sequence;
    `uvm_object_utils(WRITE_READ_COMB)

    function new(string name = "WRITE_READ_COMB");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "=============== WRITE AND READ COMBINATION ============", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)    
        this.my_regmodel.reg_command.write(status, 8'b11110110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
    endtask
endclass

class READ_RESET_VALUE extends base_sequence;
    `uvm_object_utils(READ_RESET_VALUE)

    function new(string name = "READ_RESET_VALUE");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        uvm_reg_data_t data;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "==================== READ RESET VALUE =================", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b00000000);
        `uvm_delay(500ns)
        this.my_regmodel.reg_command.read(status, data);
        this.my_regmodel.reg_status.read(status, data);
        this.my_regmodel.reg_transmit.read(status, data);
        this.my_regmodel.reg_receive.read(status, data);
        this.my_regmodel.reg_address.read(status, data);
        `uvm_delay(500ns)
    endtask
endclass

class RESET_STATE extends base_sequence;
    `uvm_object_utils(RESET_STATE)

    function new(string name = "RESET_STATE");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;    
        uvm_reg_data_t data;
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        `uvm_info(get_name(), "============ RESET TO COMPLETE FSM TRANSACTION ========", UVM_MEDIUM)
        `uvm_info(get_name(), "=======================================================", UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(200ns)

        // reset in start state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(300ns)

        // Reset in write address state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(1540ns)

        // Reset in address ack state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        `uvm_delay(100ns)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(1800ns)

        // Reset in write data state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(3080ns)

        // Reset in data ack state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        this.my_regmodel.reg_address.write(status, 8'b0010_0000);
        this.my_regmodel.reg_transmit.write(status, 0);
        this.my_regmodel.reg_transmit.write(status, 1);
        this.my_regmodel.reg_command.write(status, 8'b11111110);
        `uvm_delay(7000ns)

        // Start reading data
        `uvm_delay(1880ns)

        // Reset in read data state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        my_regmodel.reg_address.write(status, 8'b0010_0001);
        my_regmodel.reg_command.write(status, 8'b11111100);
        `uvm_delay(3070ns)

        // Reset in data ack state
        `uvm_info(get_name(), $sformatf("Reset at: %t", $time), UVM_MEDIUM)
        this.my_regmodel.reg_command.write(status, 8'b0000_0110);
        my_regmodel.reg_address.write(status, 8'b0010_0001);
        my_regmodel.reg_command.write(status, 8'b11111100);
        `uvm_delay(10000ns)
    endtask
endclass

`endif 

