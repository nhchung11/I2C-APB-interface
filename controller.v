module i2c_controller
    (
        input wire          clk,
        input wire          rst_n,
        input wire          enable,
        input wire [6:0]    slave_address,
        input wire [7:0]    data_in,
        input wire          rw,
        input wire          repeated_start_cond,
        inout               sda,        // tristate
        inout               scl         // tristate
    );

    localparam IDLE          = 0;
    localparam START         = 1;
    localparam WRITE_ADDRESS = 2; 
    localparam ADDRESS_ACK   = 3;
    localparam WRITE_DATA    = 4;
    localparam WRITE_ACK     = 5;
    localparam READ_DATA     = 6;
    localparam READ_ACK      = 7;
    localparam STOP          = 8;

    reg [2:0]   counter = 0;
    reg [7:0]   saved_addr;
    reg [7:0]   saved_data;
    reg [2:0]   current_state;
    reg [3:0]   next_state;
    reg         sda_out;
    reg         scl_enable;
    reg         sda_enable;
    reg [2:0]   counter2 = 3;

    assign sda = (sda_enable == 1) ? sda_out : 1'bz;
    assign scl = (scl_enable == 1) ? clk : 1;

    // State register logic
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            current_state <= IDLE;
            scl_enable <= 0;
        end
        else begin
            current_state <= next_state;
            if ((current_state == IDLE) || (current_state == START) || (current_state == STOP))
                scl_enable <= 0;
            else 
                scl_enable <= 1;
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)
            counter2 <= 3;
        else begin
            if (counter2 == 0)
                counter2 <= 3;
            else 
                counter2 <= counter2 - 1;
        end
    end

    // Counter logic
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)
            counter <= 7;
        else begin
            if ((current_state == WRITE_ADDRESS) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
                counter <= counter - 1;
        end
    end

    // Next state combinational logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (enable) next_state = START;
                else        next_state = IDLE;
            end
            //-----------------------------------------------------
            
            START:          next_state = WRITE_ADDRESS;
            //-----------------------------------------------------

            WRITE_ADDRESS: begin
                if (counter == 0) begin
                            next_state = ADDRESS_ACK;
                end
            end
            //-----------------------------------------------------
        
            ADDRESS_ACK: begin
                if (rw == 1) 
                            next_state = WRITE_DATA;
                else        next_state = READ_DATA;
            end
            //-----------------------------------------------------

            WRITE_DATA: begin
                if (counter == 0) begin
                            next_state = WRITE_ACK;
                end
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                if (enable == 0)
                            next_state = STOP;
                else if (enable == 1) begin
                    if (repeated_start_cond == 0)   
                            next_state = WRITE_DATA;
                    else
                            next_state = START;
                    end
                end 
            //-----------------------------------------------------

            READ_DATA: begin
                if (counter == 0) begin
                            next_state = READ_ACK;
                end
            end
            //-----------------------------------------------------

            READ_ACK: begin
                if (enable == 0)
                            next_state = STOP;
                else if (enable == 1) begin
                    if (repeated_start_cond == 0)   
                            next_state = READ_DATA;
                    else
                            next_state = START;
                end
            end
            //-----------------------------------------------------
            default:        next_state = IDLE;
        endcase
    end

    // Output logic
    always @(current_state, counter) begin
        case (current_state)
            IDLE: begin
                // enable   = 1;
                // rw       = 1;
                sda_enable  = 1;
                sda_out     = 1;
                saved_addr  = {slave_address, rw};  // 1101.011.1
                saved_data  = {data_in};            // 1010.1010
            end
            //-----------------------------------------------------

            START: begin
                sda_out     = 0;
                counter     = 7;
            end
            //-----------------------------------------------------

            WRITE_ADDRESS: begin
                sda_out     = saved_addr[counter];
                sda_enable  = 1;
            end
            //-----------------------------------------------------

            ADDRESS_ACK: begin
                sda_enable  = 0;
                sda_out     = 1;
                counter     = 7;
            end
            //-----------------------------------------------------

            WRITE_DATA: begin
                sda_enable  = 1;
                sda_out     = saved_data[counter];
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                sda_enable  = 0;
                sda_out     = 1;
            end
            //-----------------------------------------------------

            READ_DATA: begin
                sda_out     = 1;
                sda_enable  = 0;
            end
            //-----------------------------------------------------

            READ_ACK: begin
                sda_out     = 1;
                sda_enable  = 0;
            end
            //-----------------------------------------------------

            STOP: begin
                sda_out     = 1;
            end
            //-----------------------------------------------------
        endcase
    end
endmodule

