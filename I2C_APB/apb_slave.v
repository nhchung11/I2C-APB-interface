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
    reg empty;
    reg full;
    reg ack;        // 1: NACK
                    // 0: ACK
    reg busy_bus;   // 1: after START condition
                    // 0: after STOP condition

    // Input status
    always @* begin
        ack         = status_reg[7];
        busy_bus    = status_reg[6];
        empty       = status_reg[5];
        full        = status_reg[4];
    end
    
    // READY
    assign PREADY = ((PENABLE == 1'b1) & (PSELx == 1'b1)) ? 1'b1 : 1'b0;
    
    // DATA READ FROM FIFO
    assign PRDATA = ((empty == 0) & (PENABLE == 1'b1) & (PWRITE == 1'b0)) ? receive_reg : 8'b0;

    always @(posedge PCLK, negedge PRESETn) begin
        if (!PRESETn) begin
            transmit_reg    <= 8'b0;
            command_reg     <= 8'b01000000;
            address_reg     <= 8'b0;
            prescale_reg    <= 8'b0;
        end
        else begin 
            command_reg     <= 8'b11000000;
            prescale_reg    <= 8'b00000100;
            // WRITE
            if (PCLK && PENABLE && PWRITE && (full == 0)) begin
                transmit_reg <= PWDATA;
                address_reg <= {PADDR, 1'b1};
            end
            // READ
            else if (PCLK && PENABLE && (PWRITE == 0) && (empty == 0)) begin
                address_reg <= {PADDR, 1'b0};
            end
        end
    end
endmodule
