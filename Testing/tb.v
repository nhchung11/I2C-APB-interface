`include "main.v"
module tb;

  reg clk;
  reg [7:0] a;
  // Instantiate the Counter module
  Counter uut (
    .clk(clk),
    .a(a)
  );

  // Clock generation
  always begin
    #5 clk = ~clk; // Toggle the clock every 5 time units
  end

  // Initializations
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    clk = 1;
    a = 4;
    #5 a = 6;
    #5 a = 8;
    #5 $finish;
  end

endmodule
