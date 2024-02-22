module Counter (
  input clk,
  input [7:0] a,
  output reg [7:0] a_plus_one,
  
);

always @(posedge clk) begin
  a_plus_one <= a + 1;
end

endmodule
