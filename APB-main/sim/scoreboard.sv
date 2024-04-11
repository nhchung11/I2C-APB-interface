`ifndef SCOREBOARD
`define SCOREBOARD

class scoreboard;
    byte data_transmitted [$];
    static int data_num = 0;

    task display();
        $display("%t  Transmitted data: %b", $time, data_transmitted[data_num]);
        data_num = data_num + 1;
    endtask


endclass
`endif



