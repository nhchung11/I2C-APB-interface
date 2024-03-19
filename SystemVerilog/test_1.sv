`include "env.sv"
program testcase(intf_cnt intf);
     environment env = new(intf);

     initial begin

          fork
               env.mntr.check();
          begin
               env.drvr.reset();
               env.drvr.drive(100);
               env.drvr.reset();
               env.drvr.drive(100);
          end
          join_any
     end
endprogram