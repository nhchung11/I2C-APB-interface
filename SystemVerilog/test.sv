module sv_task;
  int x;

  //task to add two integer numbers.
  task sum;
    input int a,b;
    output int c;
    c = a+b;   
  endtask

  initial begin
    sum(10,5,x);
    $display("\tValue of x = %0d",x);
  end
endmodule

module sv_function;
  
  function compare(input int a, b);
    if(a>b)
      $display("a>b");
    else if(a<b)
      $display("a<b");
    else 
      $display("a=b");
  endfunction
  
  initial begin
    compare(10,10);
    compare(5, 9);
    compare(9, 5);
  end
endmodule

task task1;
    output  [7:0] x;
    input   [7:0] y, z;
    // code
endtask

task task2 (output [7:0] x, input [7:0] y, z);
    // code
endtask

function automatic void print(const ref int a[]);
    for (int i = 0; i < a.size; i++) begin
        $display(a[i]);
    end
endfunction

interface counter #(parameter WIDTH = 4) (input bit clk);
    logic               rst_n;
    logic               load_end;
    logic [WIDTH - 1:0] load;
    logic [WIDTH - 1:0] count;
    logic               down;
    logic               rollover;
endinterface

module top(input clk, rst_n)
    slave s1
    (
        clk(clk),
        rst_n(rst_n),
        // ...
    );
    slave s2
    (
        clk(clk),
        rst_n(rst_n),
        // ...
    )
    // slave s3, s4,...
endmodule

interface slave_if(input logic clk, rst_n);
    reg clk;
    reg rst_n;
    // .....
endinterface

module interface_top(input clk, rst_n)
    // Create instance for slave interface
    slave instance
    (
        .clk(clk),
        .rst_n(rst_n),
        // ...
    );
    slave s1 (.slave_if(instance));
    slave s2 (.slave_if(instance));
    slave s3 (.slave_if(instance));
    // .....
endmodule

module test;
    fork
        begin
            // Thread 1
        end
        begin
            // Thread 2
        end
        // ...
    join   
endmodule

reg o, a, b;
initial begin
    force o = a & b;
    // ...
    release o; 
end

module test
    bit [3:0] a;
    bit [1:0] b;
    // ...
endmodule

covergroup coverage_model;
    coverpoint a
    {
        // ...
    }
    coverpoint b
    {
        // ...
    }
endgroup

coverage_model instance = new();