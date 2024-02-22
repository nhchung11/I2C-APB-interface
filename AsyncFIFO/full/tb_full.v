`include "full.v"

module tb_full;

  // Parameters
  parameter address_size = 4;

  // Inputs
  reg write_reset_n;
  reg write_clk;
  reg write_increment;
  reg [address_size:0] write_to_read_pointer;

  // Outputs
  wire [address_size-1:0] write_address;
  wire [address_size:0] write_pointer;
  wire write_full;

  // Instantiate the module under test
  write_pointer_full #(address_size) uut (
    .write_reset_n(write_reset_n),
    .write_clk(write_clk),
    .write_increment(write_increment),
    .write_to_read_pointer(write_to_read_pointer),
    .write_address(write_address),
    .write_pointer(write_pointer),
    .write_full(write_full)
  );

  // Clock generation
  initial begin
    write_clk = 1;
    forever #5 write_clk = ~write_clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb_full.vcd");
    $dumpvars(0, tb_full);
    // Initialize inputs
    write_reset_n = 0;
    write_increment = 1;
    write_to_read_pointer = 5'b0000;

    // Apply some inputs and observe outputs
    #10 write_increment = 1;
    #10 write_to_read_pointer = 5'b0001;
    #10 write_increment = 1;
    #10 write_to_read_pointer = 5'b0010;
    #10 write_increment = 1;
    #10 write_to_read_pointer = 5'b0011;

    // Reset and observe outputs
    #10 write_reset_n = 0;
    #10 write_reset_n = 1;
    #10 write_increment = 1;
    #10 write_to_read_pointer = 5'b0100;

    // Finish simulation
    #10 $finish;
  end

endmodule
