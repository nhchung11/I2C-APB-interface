module BitToByteConverter_TB;

  reg clk;
  reg rst_n;
  reg in;
  reg enable;
  wire [7:0] out;

  BitToByteConverter uut (
    .clk(clk),
    .rst_n(rst_n),
    .in(in),
    .enable(enable),
    .out(out)
  );

  initial begin
    enable = 0;
    clk = 1;
    rst_n = 0; // Initialize with reset asserted
    in = 0;

    // Apply reset for a few cycles
    #10 rst_n = 0;

    #10 rst_n = 1;
    enable = 1;
    in = 1;     // Input bit 1
    #10 in = 0; // Input bit 0
    #10 in = 1; // Input bit 1
    #10 in = 0; // Input bit 0
    #10 in = 1; // Input bit 1
    #10 in = 1; // Input bit 1
    #10 in = 0; // Input bit 0
    #10 in = 0; // Input bit 0
    #10 enable = 0;

    // AC
    #10 enable = 1;
    in = 1;     // Input bit 0
    #10 in = 0; // Input bit 0
    #10 in = 1; // Input bit 0
    #10 in = 0; // Input bit 0
    #10 in = 1; // Input bit 0
    #10 in = 1; // Input bit 0
    #10 in = 1; // Input bit 0
    #10 in = 1; // Input bit 0
    #10 enable = 0;

    // AC
    #10 enable = 1;
    // Add more test cases as needed

    #200 $finish; // Finish the simulation after some time
  end

  always #5 clk =~clk; // Toggle the clock every 2 time units

endmodule
