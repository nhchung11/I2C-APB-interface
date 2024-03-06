module i2c_controller
    (
        input               i2c_core_clk,
        input               rst_n,
        input               enable,
        input  [7:0]        slave_address,
        input  [7:0]        data_in,
        input               repeated_start_cond,
        input               sda_in,
        output              sda_out,
        output              scl_out,
        output              fifo_rx_enable
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
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg         scl_enable;
    reg         i2c_clk = 1;
    reg [7:0]   counter2 = 0;
    reg         sda_in_check = 0;
    reg         sda_o;
    wire        rw;

    assign fifo_rx_enable = (current_state == READ_DATA) ? 1'b1 : 1'b0;

    // assign sda_out = (sda_enable == 1) ? sda_o : 1'bz;
    assign scl_out = (scl_enable == 1) ? i2c_clk : 1;
    assign sda_out = sda_o;
    assign rw = slave_address[0];

	always @(posedge i2c_core_clk) begin
		if (counter2 == 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 

    // State register logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n) begin
            current_state <= IDLE;
            sda_o <= 1;
            scl_enable <= 0;
        end
        else
            current_state <= next_state;
    end

    // Counter logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n)
            counter <= 7;
        else begin
            if (current_state == START)
                counter <= 7;
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
                if (enable) begin 
                    next_state = START;
                end
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
    always @(posedge i2c_core_clk) begin
        case(current_state)
            IDLE: begin
                if ((i2c_clk == 0) && (enable == 1)) begin
                    saved_addr  <= {slave_address};  // 1101.011.1
                end
                scl_enable <= 0;
                sda_o   <= 1;
            end
            //-----------------------------------------------------
            START: begin
                sda_o <= 0;
                if (i2c_clk == 0)
                    sda_o <= 0;
            end
            //-----------------------------------------------------
            WRITE_ADDRESS: begin
                if (i2c_clk == 0)
                    sda_o <= saved_addr[counter];
                    scl_enable <= 1;
            end
            //-----------------------------------------------------
            ADDRESS_ACK: begin
                sda_o <= 1;
                scl_enable <= 1;
                counter <= 7;
                saved_data  <= {data_in};            // 1010.1010
            end
            //-----------------------------------------------------
            WRITE_DATA: begin
                if (i2c_clk == 0) begin
                    sda_o <= saved_data[counter];
                    scl_enable <= 1;
                end
            end
            //-----------------------------------------------------

            WRITE_ACK: begin
                if (i2c_clk == 0) begin
                    sda_o       <= 1;
                    scl_enable  <= 1;
                end
            end
            //-----------------------------------------------------

            READ_DATA: begin
                sda_o       <= 1;
                scl_enable  <= 1;
            end
            //-----------------------------------------------------

            READ_ACK: begin
                sda_o       <= 1;
                scl_enable  <= 1;
            end
            //-----------------------------------------------------

            STOP: begin
                sda_o     <= 1;
                scl_enable  <= 0;
            end
            //-----------------------------------------------------
            default: begin
                sda_o <= 1;
                scl_enable <= 0;
            end
        endcase
    end
endmodule

