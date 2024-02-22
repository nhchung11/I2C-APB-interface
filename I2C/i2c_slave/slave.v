module i2c_slave
    (
        input wire              rst_n,
        input wire              repeated_start_cond,
        input wire [7:0]        data_out,
        input                   scl_in,
        input                   sda_in,
        output                  sda_out,
        output                  scl_out
    );

    localparam ADDRESS          = 8'b01010101;     // write mode

    localparam IDLE             = 0;
    localparam READ_ADDR        = 1;
    localparam SEND_ADDR_ACK    = 2;
    localparam WRITE_DATA       = 3;
    localparam READ_DATA        = 4;
    localparam WRITE_ACK        = 5;
    localparam READ_ACK         = 6;

    reg [3:0]   counter;
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg [7:0]   data_in;
    reg         sda_enable;
    reg         ack;
    reg         wrong_data;
    reg         sda_o, scl_o;
    reg         rw;
    reg         start = 0;          // = 1: start
                                    // = 0: stop

    // assign sda_out = (sda_enable == 1) ? sda_o : 1'bz;
    // assign scl_out = 1;

    // State register logic
    always @(negedge rst_n)begin
        if (~rst_n) begin
            current_state <= IDLE;
        end
        else
            current_state <= next_state;
    end

    // Detect controller START condition
    always @(negedge sda_in) begin
        if ((scl_in == 1) && (start == 0)) begin 
            start <= 1;
            counter <= 7; 
        end
    end
    
    // Detect controller STOP condition
    always @(posedge sda_in) begin
        if ((scl_in == 1) && (start == 1)) begin
            start <= 0;
            next_state <= IDLE;
        end
    end

    // Counter logic
    always @(negedge rst_n) begin
        if ((current_state == READ_ADDR) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
            counter <= counter - 1;
    end

    // FSM
    always @* begin
        if (start)
            case (current_state)
                IDLE: begin
                    if (start == 1)
                        next_state = READ_ADDR;
                end 
                READ_ADDR: begin
                    sda_o = 1;
                    scl_o = 1;
                    data_in[counter] = sda_in;
                    if (counter == 0)
                        next_state = SEND_ADDR_ACK;
                end
                //-----------------------------------------------------

                SEND_ADDR_ACK: begin
                    sda_o = 0;
                    scl_o = 1;
                    if (data_in[0] == 1)
                        next_state = READ_DATA;
                    else
                        next_state = WRITE_DATA;
                end
                //-----------------------------------------------------

                WRITE_DATA:begin
                    
                end
                //-----------------------------------------------------

                READ_DATA: begin
                    sda_o = 1;
                    scl_o = 1;
                    if (counter == 0)
                        next_state = READ_ACK;
                end
                //-----------------------------------------------------

                WRITE_ACK: begin
                    
                end
                //-----------------------------------------------------

                READ_ACK: begin
                    next_state = IDLE;
                end
                //-----------------------------------------------------
            endcase
    end
endmodule