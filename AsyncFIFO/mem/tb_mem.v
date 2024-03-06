`include "fifo_mem.v"

module tb_mem;

  // Parameters
  parameter data_size = 8;
  parameter address_size = 3;

  // Inputs
  reg [data_size-1:0] write_data;
  reg [address_size-1:0] write_address;
  reg [address_size-1:0] read_address;
  reg write_clk_en;
  reg write_full;
  reg write_clk;

  // Outputs
  wire [data_size-1:0] read_data;

  // Instantiate the module under test
  FIFO_memory #(data_size, address_size) uut (
    .write_data(write_data),
    .write_address(write_address),
    .read_address(read_address),
    .write_clk_en(write_clk_en),
    .write_full(write_full),
    .write_clk(write_clk),
    .read_data(read_data)
  );

  // Clock generation
  initial begin
    write_clk = 1;
    forever #5 write_clk = ~write_clk;
  end

  // Test scenario
  initial begin
    $dumpfile("tb_mem.vcd");
    $dumpvars(0, tb_mem);
    // Initialize inputs
    write_data = 8'b00000000;
    write_address = 2'b00;
    read_address = 3'b000;
    write_clk_en = 0;
    write_full = 0;

    // Perform write operations
    $display("\nPerforming write operations:");
    #10 write_data = 8'b11111111;
    #10 write_address = 3'b001;
    #10 write_clk_en = 1;
    #10 write_full = 0;

    // Perform read operations
    $display("\nPerforming read operations:");
    #10 read_address = 3'b001;

    // Finish simulation
    #10 $finish;
  end

endmodule
