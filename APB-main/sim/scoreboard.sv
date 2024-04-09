`ifndef SCOREBOARD
`define SCOREBOARD

class scoreboard;
    static int i = 0;
    byte data_transmitted [$];

    task display();
        $display("%t  Transmitted data: %b", $time, data_transmitted[i]);
        i = i + 1;
    endtask
endclass
`endif