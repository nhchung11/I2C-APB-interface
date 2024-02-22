module i2c_controller
    (
        input wire          clk,
        input wire          rst_n,
        input wire          enable,
        input wire [6:0]    slave_address,
        input wire [7:0]    data_in,
        input wire          rw,
        input wire          repeated_start_cond,
        input               sda_in, scl_in,
        output              sda_out, scl_out
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
    reg         scl_enable;
    reg         sda_enable;
    reg         i2c_clk = 1;
    reg [7:0]   counter2 = 0;
    reg         sda_in_check = 0;
    reg         sda_o;


    // assign sda_out = (sda_enable == 1) ? sda_o : 1'bz;
    assign scl_out = (scl_enable == 1) ? i2c_clk : 1;
    assign sda_out = sda_o;

	always @(posedge clk) begin
		if (counter2 == 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 

    // State register logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Counter logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n)
            counter <= 7;
        else begin
            if ((current_state == WRITE_ADDRESS) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
                counter <= counter - 1;
        end
    end

    always @(posedge i2c_clk) begin
        if ((next_state == ADDRESS_ACK) || (next_state == WRITE_ACK) || (next_state == READ_ACK)) begin
            sda_in_check <= 1;
        end
        else
            sda_in_check <= 0;
    end

    // Next state combinational logic
    always @* begin
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
                if (sda_in_check == 1) begin
                    // Sda_in = 0 -> ack
                    if (rw == 1) 
                            next_state = WRITE_DATA;
                    else    next_state = READ_DATA;
                end
                else
                    // sda_in = 1 -> nack
                    next_state = STOP;
            end
            //-----------------------------------------------------

            WRITE_DATA: begin
                if (counter == 0) begin
                            next_state = WRITE_ACK;
                end
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                if (sda_in_check == 1) begin
                    next_state = STOP;
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
                if (enable == 0) begin
                            next_state = STOP;
                end
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
                sda_o     = 1;
                saved_addr  = {slave_address, rw};  // 1101.011.1
                saved_data  = {data_in};            // 1010.1010
                scl_enable  = 0;
            end
            //-----------------------------------------------------

            START: begin
                sda_o       = 0;
                counter     = 7;
                scl_enable  = 0;
            end
            //-----------------------------------------------------

            WRITE_ADDRESS: begin
                sda_o       = saved_addr[counter];
                sda_enable  = 1;
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            ADDRESS_ACK: begin
                sda_enable  = 0;
                sda_o     = 1;
                counter     = 7;
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            WRITE_DATA: begin
                sda_enable  = 1;
                sda_o       = saved_data[counter];
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                sda_enable  = 0;
                sda_o       = 1;
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            READ_DATA: begin
                sda_o       = 1;
                sda_enable  = 0;
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            READ_ACK: begin
                sda_o       = 1;
                sda_enable  = 0;
                scl_enable  = 1;
            end
            //-----------------------------------------------------

            STOP: begin
                sda_o     = 1;
                scl_enable  = 0;
            end
            //-----------------------------------------------------
        endcase
    end
endmodule
