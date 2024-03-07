module tb;
  reg       core_clk;
  reg       i2c_clk;
  reg       rst_n;
  reg       enable;
  reg [7:0] slave_address;
  reg [7:0] data_in;
  reg       sda_in;
  reg       repeated_start_cond;
  wire      sda_out;
  wire      scl_out;

  // Instantiate the i2c_core module
  i2c_controller uut (
    .core_clk             (core_clk),
    .i2c_clk              (i2c_clk),
    .rst_n                (rst_n),
    .enable               (enable),
    .slave_address        (slave_address),
    .data_in              (data_in),
    .sda_in               (sda_in),
    .repeated_start_cond  (repeated_start_cond),
    .sda_out              (sda_out),
    .scl_out              (scl_out)
  );

  // Clock generation
  initial begin
    core_clk  = 1;
    forever #5 core_clk = ~core_clk;
  end

  initial begin
    i2c_clk  = 1;
    forever #40 i2c_clk = ~i2c_clk;
  end

  initial begin
    rst_n = 0;
    enable = 0;
    slave_address = 8'b0;     //1101011.1
    data_in = 8'b0;
    sda_in = 1;
    repeated_start_cond = 0;

    #80 rst_n = 1;
    enable = 1;
    slave_address = 8'b11110000;     
    data_in = 8'd1;

    #5000;
    $finish;
  end
endmodule
