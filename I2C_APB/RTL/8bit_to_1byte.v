module BitToByteConverter 
    (
    input wire clk,      // Clock signal
    input wire rst_n,    // Active-low reset signal
    input wire in,       // 1-bit input
    input wire enable,   // Enable signal
    output reg [7:0] out  // 8-bit output
    );

    reg [3:0]   counter;
    reg [7:0]   tmp;
    reg         i2c_clk = 1;
    reg [7:0]   counter2 = 0;
    always @(posedge clk) begin
		if (counter2 == 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
    always @(posedge i2c_clk or negedge rst_n) begin
        if (~rst_n) begin
            counter <= 0;
        end
        else begin
            if(enable)
                counter <= counter + 1;
            if (counter == 7)
                counter <= 0;
        end
    end

    always @(posedge i2c_clk or negedge rst_n) begin
        if (~rst_n) begin
            tmp <= 8'b00000000;  // Reset to 0 when reset is active
        end else if (enable) begin
            tmp <= {tmp[6:0], in};  // Shift the existing bits and append the new input bit
            if ((counter == 7) && (tmp != 0))
              out <= tmp;
        end
    end
endmodule
