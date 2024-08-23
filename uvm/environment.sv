`ifndef ENV
`define ENV

`include "uvm_macros.svh"
`include "packet.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "subscriber.sv"
`include "adapter.sv"
`include "register_model.sv"

import uvm_pkg::*;
class env extends uvm_env;
    `uvm_component_utils(env)
    agent                       my_agent;
    scoreboard                  my_scoreboard;
    subscriber                  my_subscriber;
    adapter                     my_adapter;
    register_model              my_regmodel;
    virtual intf                my_intf;
    uvm_reg_predictor #(packet) my_predictor;

    parameter time_to_write_1_byte  = 1280;
    parameter time_to_ack           = 160;

    // CONSTRUCTOR
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // BUILD PHASE
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "ENVIRONMENT BUILD PHASE", UVM_MEDIUM)
        if (!uvm_config_db #(virtual intf)::get(this, "*", "my_intf", my_intf))
            `uvm_fatal("NOVIF", "Virtual interface not set")

        // Basic components
        my_agent        = agent::type_id::create("my_agent", this);
        my_scoreboard   = scoreboard::type_id::create("my_scoreboard", this);
        my_subscriber   = subscriber::type_id::create("my_subscriber", this);

        // Register model components
        my_adapter      = adapter::type_id::create("my_adapter", this);
        my_predictor    = uvm_reg_predictor #(packet)::type_id::create("my_predictor", this);
        my_regmodel     = register_model::type_id::create("my_regmodel", this); 

        // Set up register model
        my_regmodel.build();
        my_regmodel.lock_model();
        uvm_config_db #(register_model)::set(null, "*", "my_regmodel", my_regmodel);
    endfunction

    // CONNECT PHASE
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "ENVIRONMENT CONNECT PHASE", UVM_MEDIUM)
        // Connect monitor to scoreboard and subscriber
        my_agent.my_monitor.monitor_analysis_port.connect(my_scoreboard.scoreboard_analysis_imp);
        my_agent.my_monitor.monitor_analysis_port.connect(my_subscriber.subscriber_analysis_imp);

        // Set base address
        my_regmodel.default_map.set_base_addr(0);
        my_regmodel.default_map.set_sequencer(
            .sequencer(my_agent.my_sequencer),
            .adapter(my_adapter)
        );

        // Map predicter to register map and adapter
        my_predictor.map        = my_regmodel.default_map;
        my_predictor.adapter    = my_adapter;
        my_agent.my_monitor.monitor_analysis_port.connect(my_predictor.bus_in);
    endfunction

    // RUN PHASE
    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_name(), "\n--------------------------------------------------------------------------------------------------------", UVM_MEDIUM)
        `uvm_info(get_name(), "ENVIRONMENT RUN PHASE", UVM_MEDIUM)
        super.run_phase(phase);
        fork
            begin : DATA_TO_DUT
                forever @(posedge my_intf.check_data) begin
                    my_scoreboard.data_DUT_received.push_back(my_intf.saved_data);
                end
            end

            begin: RECEIVE_PRDATA
                forever @(posedge my_intf.PCLK) begin
                    if (my_intf.PADDR == 5 && my_intf.PWRITE == 0 && my_intf.PSELx == 1 && my_intf.PENABLE == 1) begin
                        `uvm_delay(10)
                        my_scoreboard.data_read.push_back(my_intf.PRDATA);
                    end
                end
            end

            begin : READ_FIFO_STATUS
                forever @(posedge my_intf.PCLK) begin
                    if (my_intf.PADDR == 3)
                        my_scoreboard.FIFO_status = my_intf.PRDATA;
                end
            end
        join
    endtask
endclass: env
`endif 

