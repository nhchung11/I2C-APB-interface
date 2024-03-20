module semaphore_ex;
  semaphore sema; //declaring semaphore sema

  initial begin
    sema=new(4); //creating sema with '4' keys
    fork
      display(1); //process-1
      display(2); //process-2
      display(3); //process-3
    join
  end

  //display method
  task automatic display(int i);
    sema.get(2); //getting '2' keys from sema
    $display($time,"\tCurrent Simulation Time Process %d", i);
    #30;
    sema.put(2); //putting '2' keys to sema
  endtask
endmodule