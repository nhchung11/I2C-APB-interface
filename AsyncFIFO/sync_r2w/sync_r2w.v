module sync_read_to_write #(parameter address_size = 3)
    (
    input                           write_reset_n,
    input                           write_clk,
    input       [address_size:0]    read_pointer,
    output reg  [address_size:0]    write_to_read_pointer
    );

    reg [address_size:0] tmp1_read_pointer;
    //Multi-flop synchronizer logic for passing the control signals and pointers
    always @(posedge write_clk , negedge write_reset_n) begin
        if (~write_reset_n)
            {write_to_read_pointer,tmp1_read_pointer} <= 0;
        else
            {write_to_read_pointer,tmp1_read_pointer} <= {tmp1_read_pointer,read_pointer};
    end
endmodule