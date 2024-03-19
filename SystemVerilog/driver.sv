`ifndef DRIVER
`define DRIVER
`include "scoreboard.sv"
`include "stimulus.sv"
  class driver;
        stimulus sti;
        scoreboard sb;
   
        covergroup cov;
             Feature_1: coverpoint sb.store ;
             Feature_2 :  coverpoint  sb.store  {  bins trans = ( 15 => 0) ;} 
        endgroup
        
        virtual intf_cnt intf;
        
        function new(virtual intf_cnt intf,scoreboard sb);
             this.intf = intf;
             this.sb = sb;
             cov = new();
        endfunction
        
        task reset();  // Reset method
             intf.data = 0;
             @ (negedge intf.clk);
             intf.reset = 1;
             @ (negedge intf.clk);
             intf.reset = 0;
             @ (negedge intf.clk);
             intf.reset = 1;
        endtask
        
        task drive(input integer iteration);
             repeat(iteration)
             begin
                  sti = new();
                  @ (negedge intf.clk);
                  if(sti.randomize()) // Generate stimulus
                      intf.data = sti.value; // Drive to DUT
                  sb.store = sb.store + sti.value;// Cal exp value and store in Scoreboard
                  if(sti.value)
                      cov.sample();
             end
        endtask
   endclass
`endif