module i2c_controller
    (
        input               core_clk,
        input               i2c_clk,
        input               rst_n,
        input               enable,
        input  [7:0]        slave_address,
        input  [7:0]        data_in,
        input               repeated_start_cond,
        // input               scl_in,
        // input               sda_in,
        // output              sda_out,
        // output              scl_out,

        inout               sda,
        inout               scl,

        // fifo enable
        output reg          fifo_tx_enable,
        output reg          fifo_rx_enable,

        // converter enable
        output reg          converter_enable
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
    reg [2:0]   ack_counter1;
    reg [2:0]   ack_counter2;
    reg [7:0]   saved_addr;
    reg [7:0]   saved_data;
    reg [3:0]   current_state;
    reg [3:0]   next_state;
    reg         scl_enable;
    reg         sda_enable;
    reg         sda_o;
    wire        rw;
    reg         tx_check;
    reg         rx_check;

    assign scl = (scl_enable == 1) ? i2c_clk : 1;
    assign sda = (sda_enable == 1) ? sda_o   : 'bz;
    // assign sda = (sda_o == 0) ? sda_o   : 'bz;
    assign rw = slave_address[0]; 

    pullup(sda);
    // State register logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n) 
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Counter logic
    always @(posedge i2c_clk, negedge rst_n) begin
        if (~rst_n) begin
            counter             <= 7;
        end
        else begin
            if ((current_state == START) || (current_state == ADDRESS_ACK) || (current_state == WRITE_ACK) || (current_state == READ_ACK))
                counter         <= 7;
            if ((current_state == WRITE_ADDRESS) || (current_state == WRITE_DATA) || (current_state == READ_DATA))
                counter         <= counter - 1;
        end
    end 

    // ACK counter logci
    always @(posedge core_clk, negedge rst_n) begin
        if(~rst_n) begin
            ack_counter1        <= 0;
            ack_counter2        <= 0;
        end
        else begin
            if ((current_state == WRITE_ACK) || (current_state == READ_ACK)) begin
                ack_counter1        <= ack_counter1 + 1;
                if (ack_counter1 == 5)
                    ack_counter1 <= 0;
            end
            else
                ack_counter1    <= 0;
            if ((current_state == WRITE_DATA) || (current_state == READ_DATA)) begin
                ack_counter2        <= ack_counter2 + 1;
                if (ack_counter2 == 5)
                    ack_counter2 <= 0;
            end
            else    
                ack_counter2    <= 0;
        end
    end

    // Next state combinational logic
    always @(posedge core_clk, negedge rst_n) begin
        if (!rst_n)
            next_state <= IDLE;
        else begin
            case (current_state)
                IDLE: begin
                    if (enable) begin 
                        next_state <= START;
                    end
                    else        next_state  <= IDLE;
                end
                //-----------------------------------------------------
                
                START:          next_state  <= WRITE_ADDRESS;
                //-----------------------------------------------------

                WRITE_ADDRESS: begin
                    if (counter == 0) begin
                                next_state  <= ADDRESS_ACK;
                    end
                end
                //-----------------------------------------------------
            
                ADDRESS_ACK: begin
                    if (sda == 0) begin
                        // Sda_in <= 0 -> ack
                        if (rw == 0) 
                                next_state  <= WRITE_DATA;
                        else    next_state  <= READ_DATA;
                    end
                    else
                        // sda_in <= 1 -> nack
                        next_state <= STOP;
                end
                //-----------------------------------------------------

                WRITE_DATA: begin
                    if (counter == 0) begin
                                next_state  <= WRITE_ACK;
                    end
                end
                //-----------------------------------------------------

                WRITE_ACK: begin
                    if (sda == 0) begin
                        if (enable == 0) begin
                                    next_state <= STOP;
                        end
                        else if (enable == 1) begin
                            if (repeated_start_cond == 0)   
                                    next_state <= WRITE_DATA;
                            else
                                    next_state <= START;
                        end
                    end
                    else begin
                        next_state <= STOP;
                    end
                end
                
                //-----------------------------------------------------

                READ_DATA: begin
                    if (counter == 0) begin
                            next_state <= READ_ACK;
                    end
                end
                //-----------------------------------------------------

                READ_ACK: begin
                    if (enable == 0) begin
                                next_state  <= STOP;
                    end
                    else if (enable <= 1) begin
                        if (repeated_start_cond == 0)   
                                next_state  <= READ_DATA;
                        else
                                next_state  <= START;
                    end
                end
                //-----------------------------------------------------
                default:        next_state  <= IDLE;
            endcase
        end
    end
    always @(posedge core_clk, negedge rst_n) begin
        if (!rst_n) begin
            scl_enable                  <= 0;
            sda_enable                  <= 0;
            sda_o                       <= 1;
            fifo_rx_enable              <= 0;
            fifo_tx_enable              <= 0;
            converter_enable            <= 0;
            rx_check                    <= 0;
            tx_check                    <= 0;
        end
        else begin
            if (fifo_tx_enable == 1) begin
                fifo_tx_enable          <= 0;   
            end
            case(current_state)
                IDLE: begin
                    saved_addr          <= {slave_address}; 
                    scl_enable          <= 0;
                    sda_o               <= 1;
                    sda_enable          <= 1;
                end
                //-----------------------------------------------------
                START: begin
                    sda_o               <= 0;
                    scl_enable          <= 0;
                    sda_enable          <= 1;
                end
                //-----------------------------------------------------
                WRITE_ADDRESS: begin
                    scl_enable          <= 1;
                    sda_enable          <= 1;
                    if (i2c_clk == 0) 
                        sda_o           <= saved_addr[counter];
                end
                //-----------------------------------------------------
                ADDRESS_ACK: begin
                    scl_enable          <= 1;  
                    saved_data          <= {data_in}; 
                    if (i2c_clk == 0) begin
                        sda_o           <= 1;      
                        sda_enable      <= 0;   
                    end
                end
                //-----------------------------------------------------
                WRITE_DATA: begin
                    scl_enable          <= 1;
                    tx_check            <= 0;
                    if (ack_counter2 == 3)
                        sda_enable      <= 1;

                    if (i2c_clk == 0) begin
                        sda_o           <= saved_data[counter];
                    end
                end
                //-----------------------------------------------------

                WRITE_ACK: begin
                    scl_enable          <= 1;
                    saved_data          <= {data_in};
                    if (ack_counter1 == 3)
                        sda_enable      <= 0;  
                    if(sda == 0) begin
                        fifo_tx_enable  <= 1;
                        tx_check        <= 1;
                    end
                    if (tx_check == 1) begin
                        fifo_tx_enable  <= 0;
                    end
                    if (i2c_clk == 0) begin
                        sda_o           <= 0;
                    end
                end
                //-----------------------------------------------------

                READ_DATA: begin
                    // sda_o               <= 1;
                    scl_enable          <= 1;
                    converter_enable    <= 1;
                    rx_check            <= 0;
                    if (ack_counter2 == 3)
                        sda_enable      <= 0;
                end
                //-----------------------------------------------------

                READ_ACK: begin
                    scl_enable          <= 1;
                    converter_enable    <= 0;
                    fifo_rx_enable      <= 1;
                    rx_check            <= 1;
                    if (rx_check == 1)
                        fifo_rx_enable  <= 0;
                    if (i2c_clk == 0)
                        sda_o           <= 0;
                    if (ack_counter1 == 3)
                        sda_enable      <= 1;  
                end
                //-----------------------------------------------------

                STOP: begin
                    sda_enable          <= 1;
                    sda_o               <= 0;
                    scl_enable          <= 1;
                end
                //-----------------------------------------------------
                default: begin
                    sda_o               <= 1;
                    scl_enable          <= 0;
                    sda_enable          <= 1;
                end
            endcase
        end
    end
endmodule

