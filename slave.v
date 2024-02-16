module i2c_slave
    (
        input wire rst_n,
        inout sda,
        inout scl
    );

    parameter ADDRESS       = 6'b000001;
    parameter IDLE          = 0;
    parameter READ_ADDR     = 1;
    parameter SEND_ADDR_ACK = 2;
    parameter WRITE_DATA    = 3;
    parameter READ_DATA     = 4;
    parameter WRITE_ACK     = 5;
    parameter READ_ACK      = 6;

    reg [7:0]   address;
    reg [3:0]   counter;
    reg [7:0]   data_out;
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg         sda_out;
    reg         sda_in;
    reg         sda_enable;
    reg         ack;

    assign sda = (sda_enable == 1) ? sda_out : 1'bz;
    always @(negedge sda)begin
        if (scl == 1) begin
            // Start condition in controller
            current_state <= IDLE;
            counter <= 7;
        end
        else
            current_state <= next_state;
    end

    // FSM
    always @(*) begin
        case (current_state)
            IDLE: begin
                next_state = READ_ADDR;
            end

            READ_ADDR: begin
                if (counter == 0) begin
                    next_state  = SEND_ADDR_ACK;
                    ack = 1;
                end
                else begin
                    address[counter] = sda;
                    if [address[counter] != ADDRESS[counter]] begin
                        next_state = READ_ACK; 
                        ack = 0;
                    end
                    counter = counter - 1;
                end
            end

            SEND_ADDR_ACK: begin
                if (sda_in[0] == 1)
                    next_state = WRITE_DATA;
                else
                    next_state = READ_DATA;
            end

            WRITE_DATA:begin
                next_state = WRITE_ACK;
            end

            READ_DATA: begin
                next_state = READ_ACK;
            end

            WRITE_ACK: begin
                next_state = IDLE;
            end

            READ_ACK: begin
                next_state = IDLE
            end
        endcase
    end

    // Output logic
    always @(current_state, counter) begin
        case (current_state)    
            IDLE: begin
                sda_out = 1'bz;
            end
            READ_ADDR:
            SEND_ADDR_ACK:
            WRITE_DATA:
            WRITE_ACK:
            READ_DATA:
            READ_ACK:
        endcase
    end
endmodule