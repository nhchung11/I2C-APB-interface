module ClockGenerator (
  input wire        core_clk,      
  input             rst_n,
  input wire [7:0]  prescale,
  output reg        i2c_clk       
);

  reg [2:0] counter;        

  always @(posedge core_clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        i2c_clk <= core_clk;  
    end else begin
        counter <= counter + 1;
        if (counter == 3) begin
            i2c_clk <= ~i2c_clk;
            counter <= 0;
        end
    end
  end
endmodule