module tb;
  reg clk, rst_n, enable;
  reg [6:0] slave_address;
  reg [7:0] data_in;
  reg rw;
  reg repeated_start_cond;
  wire sda, scl;

  // Instantiate the i2c_core module
  i2c_controller uut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .slave_address(slave_address),
    .data_in(data_in),
    .rw(rw),
    .repeated_start_cond(repeated_start_cond),
    .sda(sda),
    .scl(scl)
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
    repeated_start_cond = 0;
    rw = 1;

    #10 rst_n = 1;
    enable = 1;

    #10 enable = 0;

    // Read test case
    #350;
    slave_address = 7'b0001101;
    rw = 0;

    #10;
    enable = 1;

    #10;
    enable = 0;
  end
endmodule
