module tb;
  reg clk, rst_n, enable, sda_i, scl_i;
  reg [6:0] slave_address;
  reg [7:0] data_in;
  reg rw;
  wire sda_o, scl_o;

  // Instantiate the i2c_core module
  i2c_core uut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .slave_address(slave_address),
    .data_in(data_in),
    .rw(rw),
    .sda_i(sda_i),
    .scl_i(scl_i),
    .sda_o(sda_o),
    .scl_o(scl_o)
  );

  // Clock generation
  initial begin
    clk = 1;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    enable = 0;
    slave_address = 7'b1101011;
    data_in = 8'b10101010;
    rw = 1;
    sda_i = 1;
    scl_i = 1;

    #10 rst_n = 1;
    enable = 1;
  end
endmodule