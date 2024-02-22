`include "sync_w2r.v"
`timescale 1ns/1ps

module tb_sync_w2r;

  // Parameters
  parameter address_size = 3;

  // Inputs
  reg [address_size:0] write_pointer;
  reg read_reset_n;
  reg read_clk;

  // Outputs
  wire [address_size:0] read_to_write_pointer;

  // Instantiate the module under test
  sync_write_to_read #(address_size) uut (
    .write_pointer(write_pointer),
    .read_reset_n(read_reset_n),
    .read_clk(read_clk),
    .read_to_write_pointer(read_to_write_pointer)
  );

  // Clock generation
  initial begin
    read_clk = 1;
    forever #5 read_clk = ~read_clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb_sync_w2r.vcd");
    $dumpvars(0, tb_sync_w2r);
    // Initialize inputs
    write_pointer = 3'b000;
    read_reset_n = 0;

    // Apply some inputs and observe outputs
    #10 write_pointer = 3'b001;
    #10 write_pointer = 3'b010;
    #10 write_pointer = 3'b011;
    #10 write_pointer = 3'b100;

    // Reset and observe outputs
    #10 read_reset_n = 0;
    #10 read_reset_n = 1;
    #10 write_pointer = 3'b101;
    #10 write_pointer = 3'b110;
    #10 write_pointer = 3'b111;

    // Finish simulation
    #10 $finish;
  end

endmodule
