module tb;
  reg i2c_core_clk, rst_n, enable;
  reg [7:0] slave_address;
  reg [7:0] data_in;
  reg repeated_start_cond;
  reg sda_in;
  wire sda_out, scl_out;

  // Instantiate the i2c_core module
  i2c_controller uut (
    .i2c_core_clk(i2c_core_clk),
    .rst_n(rst_n),
    .enable(enable),
    .slave_address(slave_address),
    .data_in(data_in),
    .repeated_start_cond(repeated_start_cond),
    .sda_in(sda_in),
    .sda_out(sda_out),
    .scl_out(scl_out)
  );

  // Clock generation
  initial begin
    i2c_core_clk = 1;
    forever #5 i2c_core_clk = ~i2c_core_clk;
  end
  initial begin
    rst_n = 0;
    enable = 1;
    slave_address = 8'b11010111;     //1101011.1
    data_in = 8'b10101010;
    repeated_start_cond = 1;
    sda_in = 1;
    #20 rst_n = 1;

    #350 sda_in = 0;
    #40 sda_in = 1;
    #320 sda_in = 0;
    #40 sda_in = 1;
    
    slave_address = 8'b00001111;     //1101011.1
    data_in = 8'b11110000;
    repeated_start_cond = 1;
    enable = 1;

    #350 sda_in = 0;
    #40 sda_in = 1;
    #320 sda_in = 0;
    #40 sda_in = 1;

    #1000
    $finish;
  end
endmodule
