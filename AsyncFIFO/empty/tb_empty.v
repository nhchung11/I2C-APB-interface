`include "empty.v"

module tb_empty;
  // Parameters
  parameter address_size = 3;

  // Inputs
  reg read_reset_n;
  reg read_increment;
  reg read_clk;
  reg [address_size :0] read_to_write_pointer;

  // Outputs
  reg [address_size-1:0] read_address;
  reg [address_size :0] read_pointer;
  reg read_empty;

  // Instantiate the module under test
  read_pointer_empty #(address_size) uut (
    .read_reset_n(read_reset_n),
    .read_increment(read_increment),
    .read_clk(read_clk),
    .read_to_write_pointer(read_to_write_pointer),
    .read_address(read_address),
    .read_pointer(read_pointer),
    .read_empty(read_empty)
  );

  // Clock generation
  initial begin
    read_clk = 1;
    forever #5 read_clk = ~read_clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb_empty.vcd");
    $dumpvars(0, tb_empty);
    // Initialize inputs
    read_reset_n = 1;
    read_increment = 1;
    read_to_write_pointer = 3'b000;

    // Perform read operations
    $display("\nPerforming read operations:");
    #10 read_increment = 1;
    #10 read_increment = 0;
    #10 read_increment = 1;
    #10 read_increment = 0;

    // Finish simulation
    #10 $finish;
  end

endmodule
