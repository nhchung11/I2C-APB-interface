module slave_tb;
    reg rst_n, repeated_start_cond;
    reg sda_in, scl_in;
    reg data_out;
    wire sda_out, scl_out;

    i2c_slave slave_uut
    (
        .rst_n(rst_n),
        .repeated_start_cond(repeated_start_cond),
        .data_out(data_out),
        .scl_in(scl_in),
        .sda_in(sda_in),
        .sda_out(sda_out)
    );

    initial begin
        rst_n = 1;
        sda_in = 1;          // Start condition
        data_out = 8'b01010101;     // Slave writes data
        scl_in = 1;
        repeated_start_cond = 0;
        //Start condition
        #5 sda_in = 0;
        scl_in = 1;
        //Slave address
        #5 sda_in = 0;
        scl_in = 1;
        #5 sda_in = 1;
        #5 sda_in = 0;
        #5 sda_in = 1;
        #5 sda_in = 0;
        #5 sda_in = 1;
        #5 sda_in = 0;
        #5 sda_in = 1;
        #500
        $finish;
    end
endmodule