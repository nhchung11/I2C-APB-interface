module i2c_controller
    (
        input               core_clk,
        input               i2c_clk,
        input               rst_n,
        input               enable,
        input  [7:0]        slave_address,
        input  [7:0]        data_in,
        input               sda_in,
        input               repeated_start_cond,
        output              sda_out,
        output              scl_out
    );
    
    localparam  IDLE          = 0;
    localparam  START         = 1;
    localparam  WRITE_ADDRESS = 2; 
    localparam  ADDRESS_ACK   = 3;
    localparam  WRITE_DATA    = 4;
    localparam  WRITE_ACK     = 5;
    localparam  READ_DATA     = 6;
    localparam  READ_ACK      = 7;
    localparam  STOP          = 8;

    reg [2:0]   counter;
    reg [2:0]   counter2;
    reg [7:0]   saved_addr;
    reg [7:0]   saved_data;
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg         scl_enable;
    reg         sda_in_check;
    reg         sda_o;
    reg         scl_o;
    wire        rw;


    assign scl_out  = (scl_enable == 1) ? i2c_clk : scl_o;
    assign sda_out  = sda_o;
    assign rw       = slave_address[0];


    // State register logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n) 
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Counter SDA logic
    always @(posedge core_clk, negedge rst_n) begin
        if(!rst_n)
            counter2 <= 0;
        else begin
            if ((current_state == IDLE) || (current_state == WRITE_ACK) || (current_state == READ_ACK) || (current_state == ADDRESS_ACK)) begin
                counter2 <= 0;   
            end
            
            if ((current_state == START) || (current_state == WRITE_ADDRESS) || (current_state == WRITE_DATA) || (current_state == READ_DATA)) begin
                counter2 <= counter2 + 1;
                if (counter2 == 7)
                    counter2 <= 0;
            end
        end
    end

    // Counter FSM logic
    always @(posedge core_clk, negedge rst_n) begin
        if (~rst_n)
            counter <= 7;
        else begin
            if (counter2 == 7) begin
                if ((current_state == START) || (current_state == WRITE_ACK) || (current_state == READ_ACK) || (current_state == ADDRESS_ACK))
                    counter <= 7;
                if ((current_state == WRITE_ADDRESS) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
                    counter <= counter - 1;
            end
        end
    end

    // Check ACK
    always @(posedge core_clk, negedge rst_n) begin
        if(!rst_n)
            sda_in_check <= 0;
        else begin
            if ((next_state == ADDRESS_ACK) || (next_state == WRITE_ACK) || (next_state == READ_ACK)) begin
                sda_in_check <= 1;
            end else
                sda_in_check <= 0;
        end
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
            
            START:          next_state = WRITE_ADDRESS;

            WRITE_ADDRESS: begin
                if ((counter == 0) && (counter2 == 7)) begin
                            next_state = ADDRESS_ACK;
                end
            end
        
            ADDRESS_ACK: begin
                    if (rw == 0) 
                            next_state = WRITE_DATA;
                    else    next_state = READ_DATA;
            end

            WRITE_DATA: begin
                if (counter == 0) begin
                            next_state = WRITE_ACK;
                end
            end

            WRITE_ACK: begin
                if (sda_in_check) begin
                    if (enable == 0)
                        next_state = STOP;
                    else begin
                        if (repeated_start_cond && enable)
                            next_state = START;
                        else if ((repeated_start_cond == 0) && enable)
                            next_state = WRITE_DATA;
                    end
                end
                else
                    next_state = STOP;
            end

            READ_DATA: begin
                if (counter == 0) begin
                        next_state = READ_ACK;
                end
            end

            READ_ACK: begin
                if (sda_in_check) begin
                    if (enable == 0)
                        next_state = STOP;
                    else begin
                        if (repeated_start_cond && enable)
                            next_state = START;
                        else if ((repeated_start_cond == 0) && enable)
                            next_state = READ_DATA;
                    end
                end
                else
                    next_state = STOP;
            end
            
            default:        next_state = IDLE;
        endcase
    end
    always @(posedge core_clk) begin
        case(current_state)
            IDLE: begin
                if ((i2c_clk == 0) && (enable == 1)) begin
                    saved_addr  <= {slave_address};  // 1101.011.1
                end
                scl_enable <= 0;
                sda_o   <= 1;
                scl_o   <= 1;
            end
            //-----------------------------------------------------
            START: begin
                sda_o <= 0;
                if (counter2 == 3)
                    scl_enable <= 1;
                if (counter2 == 6) begin
                    scl_enable <= 0;
                    scl_o <= 0;
                end
                
            end
            //-----------------------------------------------------
            WRITE_ADDRESS: begin
                sda_o <= saved_addr[counter];
                if (counter2 == 2) begin
                    scl_enable <= 1;
                end
            end
            //-----------------------------------------------------
            ADDRESS_ACK: begin
                sda_o <= 1;
                scl_enable <= 1;
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

