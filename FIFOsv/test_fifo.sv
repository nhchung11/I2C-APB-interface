// Code your testbench here
// or browse Examples
module async_fifo_tb;

  parameter DSIZE = 32;
  parameter ASIZE = 2;

  wire [DSIZE-1:0] read_data;
  wire write_full;
  wire read_empty;
  reg [DSIZE-1:0] write_data;
  reg write_enable, write_clk, write_reset_n;
  reg read_enable, read_clk, read_reset_n;

  // Model a queue for checking data
  reg [DSIZE-1:0] verif_data_q[$];
  reg [DSIZE-1:0] verif_write_data;


  // Instantiate the FIFO
  async_fifo #(DSIZE, ASIZE) dut (.*);

  initial begin
    write_clk = 1'b0;
    read_clk = 1'b0;
    fork
      forever #10ns write_clk = ~write_clk;
      forever #35ns read_clk = ~read_clk;
    join
  end

  initial begin
    write_enable = 1'b0;
    write_data = '0;
    write_reset_n = 1'b0;
    repeat(5) @(posedge write_clk);
    write_reset_n = 1'b1;

    for (int iter=0; iter<2; iter++) begin
      for (int i=0; i<32; i++) begin
        @(posedge write_clk iff !write_full);
        write_enable = (i%2 == 0)? 1'b1 : 1'b0;
        if (write_enable) begin
          write_data = $urandom;
          verif_data_q.push_front(write_data);
        end
      end
      #1us;
    end
  end

  initial begin
    read_enable = 1'b0;

    read_reset_n = 1'b0;
    repeat(8) @(posedge read_clk);
    read_reset_n = 1'b1;

    for (int iter=0; iter<2; iter++) begin
      for (int i=0; i<32; i++) begin
        @(posedge read_clk iff !read_empty)
        read_enable = (i%2 == 0)? 1'b1 : 1'b0;
        if (read_enable) begin
          verif_write_data = verif_data_q.pop_back();
          // Check the read_data against modeled write_data
          $display("Checking read_data: expected write_data = %h, read_data = %h", verif_write_data, read_data);
          assert(read_data === verif_write_data) else $error("Checking failed: expected write_data = %h, read_data = %h", verif_write_data, read_data);
        end
      end
      #1us;
    end
    $finish;
  end

endmodule