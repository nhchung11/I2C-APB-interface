module tb_top;
// Inputs
reg [7:0] write_data;
reg write_enable;
reg write_clk;
reg write_reset_n;
reg read_enable;
reg read_clk;
reg read_reset_n;

// Outputs
wire [7:0] read_data;
wire write_full;
wire read_empty;
FIFO_top uut 
(
    .write_data(write_data),
    .write_enable(write_enable),
    .write_clk(write_clk),
    .write_reset_n(write_reset_n),
    .read_enable(read_enable),
    .read_clk(read_clk),
    .read_reset_n(read_reset_n),
    .read_data(read_data),
    .write_full(write_full),
    .read_empty(read_empty)
);

always #5 write_clk= ~write_clk;
always #20 read_clk= ~read_clk;
initial begin
    write_enable = 0;
    write_clk = 0;
    read_enable = 0;
    read_clk = 0;
    write_reset_n = 0;
    read_reset_n = 0;

    #100
    write_reset_n = 1;
    read_reset_n = 1;
    
    #10 write_enable = 1;
    write_data = 0;
    #10 write_data = 1;
    #10 write_data = 2;
    #10 write_data = 3;
    #10 write_data = 4;
    #10 write_data = 5;
    #10 write_data = 6;
    #10 write_data = 7;
    #10 write_data = 8;
    #10 read_enable = 1;
    write_enable = 0;
    #20000 $finish;
end
endmodule