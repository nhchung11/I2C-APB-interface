`include "top.v"
module tb_top;
// Inputs
reg [7:0] write_data;
reg write_increment;
reg write_clk;
reg write_reset_n;
reg read_increment;
reg read_clk;
reg read_reset_n;

// Outputs
wire [7:0] read_data;
wire write_full;
wire read_empty;
FIFO_top uut 
(
    .write_data(write_data),
    .write_increment(write_increment),
    .write_clk(write_clk),
    .write_reset_n(write_reset_n),
    .read_increment(read_increment),
    .read_clk(read_clk),
    .read_reset_n(read_reset_n),
    .read_data(read_data),
    .write_full(write_full),
    .read_empty(read_empty)
);

always #5 write_clk= ~write_clk;
always #10 read_clk= ~read_clk;
always #80 write_increment= ~write_increment;
always #80 read_increment = ~ read_increment;
always #200 write_reset_n = ~write_reset_n;
always #200 read_reset_n = ~ read_reset_n;
initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
    // Initial inputs
    write_data = 0;
    write_increment = 0;
    write_clk = 0;
    write_reset_n = 0;
    read_increment = 0;
    read_clk = 0;
    read_reset_n = 0;
    #100
    // Wait 100 ns for global reset to finish
    #10 write_data = 1;
    #10 write_data = 2;
    #10 write_data = 3;
    #10 write_data = 4;
    #10 write_data = 5;
    #10 write_data = 6;
    #10 write_data = 7;
    #10 write_data = 8;
end
endmodule