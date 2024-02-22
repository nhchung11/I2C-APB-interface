module i2c_slave
    (
        input wire              clk,
        input wire              rst_n,
        input wire              repeated_start_cond,
        input wire [7:0]        data_out,
        input                   scl_in,
        input                   sda_in,
        output                  sda_out
    );

    localparam ADDRESS          = 8'b01010101;     // write mode

    localparam IDLE             = 0;
    localparam READ_ADDR        = 1;
    localparam SEND_ADDR_ACK    = 2;
    localparam WRITE_DATA       = 3;
    localparam READ_DATA        = 4;
    localparam WRITE_ACK        = 5;
    localparam READ_ACK         = 6;

    reg [3:0]   counter         = 7;
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg         sda_enable      = 0;
    reg         ack;
    reg         wrong_data;
    reg         sda_o;
    reg         rw;

    assign sda_out = (sda_enable == 1) ? sda_o : 1'bz;
    assign scl_out = 1;

    // State register logic
    always @(posedge clk, negedge rst_n)begin
        if (~rst_n) begin
            current_state <= IDLE;
            counter <= 7;
        end
        else
            current_state <= next_state;
    end

    // Detect controller START condition
    always @(negedge sda_in) begin
        if (scl_in) begin 
            current_state <= READ_ADDR;
        end
    end
    
    // Detect controller STOP condition
    always @(posedge sda_in) begin
        if (scl_in) begin
            current_state <= IDLE;
        end
    end

    // Counter logic
    always @(posedge clk, negedge rst_n) begin
        if ((current_state == READ_ADDR) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
            counter <= counter - 1;
    end

    // FSM
    always @* begin
        case (current_state)
            READ_ADDR: begin
                if (counter == 0) begin
                    next_state = SEND_ADDR_ACK;
                end
                else begin
                    next_state = READ_ACK;
                end
            end
            //-----------------------------------------------------

            SEND_ADDR_ACK: begin
                counter = 7;
                if (rw == 1)
                    next_state = WRITE_DATA;
                else
                    next_state = READ_DATA;
            end
            //-----------------------------------------------------

            WRITE_DATA:begin
                if (counter == 0)
                    next_state = WRITE_ACK;
            end
            //-----------------------------------------------------

            READ_DATA: begin
                if (counter == 0) begin 
                    ack = 1;     // ACK
                end
                else if (wrong_data) begin
                    ack = 0;    // NACK
                end
                next_state = READ_ACK;
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                if (repeated_start_cond)
                    next_state = WRITE_ACK;
                else
                    next_state = IDLE;
            end
            //-----------------------------------------------------

            READ_ACK: begin
                if (repeated_start_cond)
                    next_state = READ_DATA;
                else
                    next_state = IDLE;
            end
            //-----------------------------------------------------
        endcase
    end

    // Output logic
    always @(current_state, counter) begin
        case (current_state)    
            IDLE: begin
                sda_o = 1;
                sda_enable = 0;
                counter = 7;
            end
            //-----------------------------------------------------

            READ_ADDR: begin
                sda_o = 1;
                sda_enable = 0;
            end
            //-----------------------------------------------------

            SEND_ADDR_ACK: begin
                sda_o = 0;
                sda_enable = 1;
            end
            //-----------------------------------------------------

            WRITE_DATA: begin
                sda_o = data_out[counter];
                sda_enable = 1;
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                sda_enable = 0;
                if (ack)
                    sda_o = 0;
                else
                    sda_o = 1;
            end
            //-----------------------------------------------------
            READ_DATA: begin
                sda_o = 1;
                sda_enable = 0;
            end
            //-----------------------------------------------------

            READ_ACK: begin
                sda_enable = 1;
                if (ack == 1) begin
                    sda_o = 1;
                end
                else
                    sda_o = 0;
            end
            //-----------------------------------------------------
        endcase
    end
endmodule