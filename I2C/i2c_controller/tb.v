module tb;
  reg clk, rst_n, enable;
  reg [6:0] slave_address;
  reg [7:0] data_in;
  reg rw;
  reg repeated_start_cond;
  reg sda_in;
  wire sda_out, scl_out;

  // Instantiate the i2c_core module
  i2c_controller uut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .slave_address(slave_address),
    .data_in(data_in),
    .rw(rw),
    .repeated_start_cond(repeated_start_cond),
    .sda_in(sda_in),
    .sda_out(sda_out),
    .scl_out(scl_out)
  );

  // Clock generation
  initial begin
    clk = 1;
    forever #5 clk = ~clk;
  end
  initial begin
    rst_n = 0;
    enable = 0;
    slave_address = 7'b1101011;     //1101011.1
    data_in = 8'b10101010;
    repeated_start_cond = 1;
    rw = 1;
    enable = 1;
    sda_in = 1;
    #20 rst_n = 1;

    #20 enable = 0;

    #350 sda_in = 0;
    #40 sda_in = 1;
    #320 sda_in = 0;
    #40 sda_in = 1;
    #2000
    $finish;
  end
endmodule
