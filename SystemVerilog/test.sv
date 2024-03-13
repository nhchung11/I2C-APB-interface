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

module test;
    int q;
    function int sum(int x = 0; y = 10, z = 20)
        return x + y + z;
    endfunction

    initial begin
        q = sum( , , 10);
        $display("%0d",q);
    end
endmodule

module passing_byname;
    function void display(int x, string y);
        $display("x = %0d, y = %0s", x, y);
    endfunction
    // ....
endmodule

rand bit [3:0]  value;

randc bit value;
object.randomize();

constraint value_range {value > 5;}

constraint range {value inside {[5:10]};}

constraint range {value inside {1,2,3,4,5};}

constraint range {value inside {1, [2:4], 6, [9:10]};}

constraint range (value !(inside{[5:10]});)

rand bit[3:0] start_val;
rand bit[3:0] end_val;
constraint range (value inside{[start_val: end_val]};)

value := weight
value :/ weight

class packet
    rand bit [7:0] addr;
    constraint addr_range {addr == 5;}
endclass

module test;
    packet pkt1;
    packet pkt2;
    pkt1 = new()
    pkt2 = new()

    pkt1.randomize();

endmodule

object.randomize() with {...}

constraint constraint_name { var = function_call(); };