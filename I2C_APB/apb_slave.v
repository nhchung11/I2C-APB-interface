module apb
    (
	    input               PCLK,           // Clock
		input               PRESETn,        // Active-low reset
		input               PSELx,          // Select
		input               PWRITE,         // Direction: 
                                                // 1 -> write
                                                // 0 -> read
		input               PENABLE,        // Enable
		input       [6:0]   PADDR,          // APB address bus, 8 bits
		input       [7:0]   PWDATA,         // Write data
        input       [7:0]   status_reg,      
        input       [7:0]   receive_reg,

		output              PREADY,         // Ready
                                            // Slave can complete the transfer at next PCLK posedge
        output      [7:0]   PRDATA,
        output reg  [7:0]   transmit_reg, 
        output reg  [7:0]   command_reg,
        output reg  [7:0]   prescale_reg,
        output reg  [7:0]   address_reg
	);
    reg                     RX_empty;
    reg                     TX_full;
    reg [7:0]               PREV_ADDR;
    reg [3:0]               enable_counter;

    // Input status
    always @* begin
        TX_full             = status_reg[7];
        RX_empty            = status_reg[6];
    end

    always @(posedge PCLK, negedge PRESETn) begin
        PREV_ADDR           <= PADDR;
        if (PADDR != PADDR) begin
            command_reg[3]  <= 0;
        end
        else begin
            command_reg[3]  <= 1;
        end
    end
    
    
    // READY
    assign PREADY = ((PENABLE == 1'b1) & (PSELx == 1'b1)) ? 1'b1 : 1'b0;
    
    // DATA READ FROM FIFO
    assign PRDATA = ((RX_empty == 0) & (PENABLE == 1'b1) & (PWRITE == 1'b0)) ? receive_reg : 8'b0;

    always @(posedge PCLK, negedge PRESETn) begin
        if (!PRESETn) begin
            transmit_reg        <= 8'b0;
            command_reg         <= 8'b00000000;
            address_reg         <= 8'b0;
            prescale_reg        <= 8'b0;
        end
        else begin 
            command_reg[4]      <= 1;
            prescale_reg        <= 8'b00000100;
            // WRITE
            if (PCLK && PENABLE && PWRITE && (TX_full == 0)) begin
                transmit_reg    <= PWDATA;
                address_reg     <= {PADDR, 1'b1};
                command_reg[6]  <= 1;
                command_reg[5]  <= 0;
                command_reg[7]  <= 1;
            end
            // READ
            else if (PCLK && PENABLE && (PWRITE == 0) && (RX_empty == 0)) begin
                address_reg     <= {PADDR, 1'b0};
                command_reg[5]  <= 1;
                command_reg[6]  <= 0;
                command_reg[7]  <= 1;
            end
        end
    end
endmodule
