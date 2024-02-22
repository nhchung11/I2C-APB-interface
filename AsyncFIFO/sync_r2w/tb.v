`include "sync_r2w.v"
module tb;

  // Parameters
  parameter address_size = 3;

  // Inputs
  reg write_reset_n;
  reg write_clk;
  reg [address_size:0] read_pointer;

  // Outputs
  wire [address_size:0] write_to_read_pointer;

  // Instantiate the module under test
  sync_read_to_write #(address_size) uut (
    .write_reset_n(write_reset_n),
    .write_clk(write_clk),
    .read_pointer(read_pointer),
    .write_to_read_pointer(write_to_read_pointer)
  );

  // Clock generation
  initial begin
    write_clk = 1;
    forever #5 write_clk = ~write_clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    // Initialize inputs
    write_reset_n = 1;
    read_pointer = 3'b000;

    // Apply some inputs and observe outputs
    #10 write_reset_n = 0;
    #10 write_reset_n = 1;
    #10 read_pointer = 3'b001;
    #10 read_pointer = 3'b010;
    #10 read_pointer = 3'b011;
    #10 read_pointer = 3'b100;

    // Finish simulation
    #10 $finish;
  end

endmodule
