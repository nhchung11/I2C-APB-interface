module ClockGenerator (
  input wire        core_clk,       // Input clock
  input             rst_n,
  input wire [7:0]  prescale,
  output reg        i2c_clk       // Output clock
);

  reg [2:0] counter;        // 3-bit counter to divide the clock by 4

  always @(posedge core_clk or negedge rst_n) begin
    if (!rst_n) begin
        // Synchronous reset
        counter <= 0;
        i2c_clk <= core_clk;   // Initialize clk_out with the value of clk_in
    end else begin
        // Increment the counter on each rising edge of the input clock
        counter <= counter + 1;

      // When the counter reaches 3, toggle the output clock and reset the counter
        if (counter == 3) begin
            i2c_clk <= ~i2c_clk;
            counter <= 0;
        end
    end
  end
endmodule