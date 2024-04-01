module apb
    (
	    input               PCLK,           // Clock
		input               PRESETn,        // Active-low reset
		input               PSELx,          // Select
		input               PWRITE,         // Direction: 
                                                // 1 -> write
                                                // 0 -> read
		input               PENABLE,        // Enable
		input       [7:0]   PADDR,          // APB address bus, 8 bits
		input       [7:0]   PWDATA,         // Write data
        input       [7:0]   status_reg,      
        input       [7:0]   receive_reg,

		output              PREADY,         // Ready
                                            // Slave can complete the transfer at next PCLK posedge
        output reg  [7:0]   PRDATA,
        output reg  [7:0]   transmit_reg, 
        output reg  [7:0]   command_reg,
        output reg  [7:0]   prescale_reg,
        output reg  [7:0]   address_reg
	);

    reg                     TX_empty;
    reg                     TX_full;
    reg                     RX_full;
    reg                     RX_empty;
    // reg [2:0]               reg_map;


    // Input status
    always @* begin
        TX_full             = status_reg[7];
        TX_empty            = status_reg[6];
        RX_full             = status_reg[5];
        RX_empty            = status_reg[4];
    end

    // always @(posedge PCLK, negedge PRESETn) begin
    //     if (!PRESETn)
    //         reg_map <= 3'b0;
    //     else
    //         reg_map <= PADDR[7:5];
    // end
    
    // READY
    assign PREADY = ((PENABLE == 1'b1) & (PSELx == 1'b1)) ? 1'b1 : 1'b0;
    
    // DATA READ FROM FIFO
    // assign PRDATA = ((RX_empty == 0) & (PENABLE == 1'b1) & (PWRITE == 1'b0) & (PSELx == 1'b1)) ? receive_reg : 8'b0;

    

    always @(posedge PCLK, negedge PRESETn) begin
        if (!PRESETn) begin
            command_reg                 <= 8'b00000000;
            address_reg                 <= 8'b0;
            prescale_reg                <= 8'b0;
        end
        else begin 
            case (PADDR)
                // Write to Prescale register
                1: begin
                    if ((PWRITE == 1) && (PSELx == 1) && (PENABLE == 1))
                        prescale_reg    <= PWDATA;
                end

                // Write to slave address
                2: begin
                    if ((PWRITE == 1) && (PSELx == 1) && (PENABLE == 1))
                        address_reg     <= PWDATA;
                end

                // Read from status register
                3: begin
                    if ((PWRITE == 0) && (PSELx == 1) && (PENABLE == 1))
                        PRDATA          <= status_reg;
                end

                // Write to transmit register
                4: begin
                    if ((PWRITE == 1) && (PSELx == 1) && (PENABLE == 1)) begin
                        transmit_reg    <= PWDATA;
                        command_reg     <= 11010000;
                    end
                    if (PSELx == 0)
                        command_reg     <= 10010000;
                end

                // Read from receive register
                5: begin
                    if (PSELx == 0)
                        command_reg     <= 10010000;
                    else if ((PWRITE == 0) && (PSELx == 1) && (PENABLE == 1)) begin
                        PRDATA          <= receive_reg;
                        command_reg     <= 10110000;
                    end
                end
                
                // Write to Command regisger
                6: begin
                    if ((PWRITE == 1) && (PSELx == 1) && (PENABLE == 1))
                        command_reg     <= PWDATA;
                end
            endcase            
        end
    end
endmodule
