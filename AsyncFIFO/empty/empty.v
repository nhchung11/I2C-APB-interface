module read_pointer_empty #(parameter address_size = 3)
    (
        input                           read_reset_n,
        input                           read_enable,
        input                           read_clk,
        input       [address_size :0]   read_to_write_pointer,
        output reg  [address_size-1:0]  read_address,
        output reg  [address_size :0]   read_pointer,
        output reg                      read_empty 
    );

    reg [address_size:0] read_binary;
    reg [address_size:0] read_gray_next;
    reg [address_size:0] read_binary_next;
    reg [7:0] counter;
    always @(posedge read_clk, negedge read_reset_n) begin
        if (!read_reset_n)
            counter <= 8'b0;
        else begin
            counter <= counter + 1;
            if (counter == 8'd50)
                counter <= 8'b0;
        end
    end

    always@*
        begin
            if (counter == 8'd50) begin
                read_address = read_binary[address_size-1:0];
                read_binary_next = read_binary + (read_enable & ~read_empty); 
                read_gray_next = (read_binary_next>>1) ^ read_binary_next;
            end
    end

    always @(posedge read_clk , negedge read_reset_n) begin
        if (~read_reset_n)
            {read_binary, read_pointer} <= 0;
        else
            if (counter == 8'd50)
                {read_binary, read_pointer} <= {read_binary_next, read_gray_next};
    end

    // FIFO empty logic
    always @(posedge read_clk , negedge read_reset_n) begin
        if (~read_reset_n)
            read_empty <= 1'b1;
        else
            if (counter == 8'd50)
                read_empty <= (read_gray_next == read_to_write_pointer);
    end
endmodule