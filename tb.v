`include "controller.v"

module tb;

  reg clk, rst;
  reg [6:0] slave_address;
  reg [7:0] data_in;
  reg rw;
  wire sda, scl;

  // Instantiate the i2c_controller module
  i2c_controller uut (
    .clk(clk),
    .rst(rst),
    .slave_address(slave_address),
    .data_in(data_in),
    .rw(rw),
    .sda(sda),
    .scl(scl)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    // Apply reset
    rst           = 1;
    #10 rst       = 0;
    slave_address = 7'b1010101;
    data_in       = 8'b11001100;
    rw            = 0; 
    #10; 
    $finish;
  end

endmodule
