module apb
    (
	    input           PCLK,           // Clock
		input           PRESETn,        // Active-low reset
		input           PSELx,          // Select
		input           PWRITE,         // Direction: 
                                        // 1 -> write
                                        // 0 -> read
		input           PENABLE,        // Enable
		input [7:0]     PADDR,          // APB address bus, 8 bits
		input [7:0]     PWDATA,         // Write data
        input [7:0]     APB_RX,
        input           WRITE_FULL,     // FIFO full
        input           READ_EMPTY,     // FIFO empty

		output          PREADY,         // Ready
                                        // Slave can complete the transfer at next PCLK posedge
        output [7:0]    PRDATA,
        output          R_ENA,          // Read enable FIFO
        output          W_ENA,          // Write enable FIFO
                                        // 1 -> Write
                                        // 0 -> Read
        output [7:0]    APB_TX
	);
    reg [7:0] data;
    // ENABLE
    assign PREADY = (PENABLE == 1'b1 & PSELx == 1'b1 & PWRITE == 1'b1) ? 1'b1 : 1'b0;
    
    //ENABLE WRITE ON FIFO
    assign W_ENA = (PWRITE == 1'b1 & PENABLE == 1'b1 & PADDR == 8'd0 & PSELx == 1'b1 & WRITE_FULL == 1'b0)?  1'b1:1'b0;

    //ENABLE READ ON FIFO
    assign R_ENA = (PWRITE == 1'b0 & PENABLE == 1'b1 & PADDR == 8'd4 & PSELx == 1'b1 & READ_EMPTY == 1'b0)?  1'b1:1'b0;

    // WRITE DATA TO FIFO
    assign APB_TX = ((WRITE_FULL == 0) && (W_ENA == 1) && (PADDR == 8'd0)) ? data : 0;
    
    // DATA READ FROM FIFO
    assign PRDATA = ((READ_EMPTY == 0) && (R_ENA == 1) && (PADDR == 8'd4)) ? APB_RX : 0;

    always @(posedge PCLK, negedge PRESETn) begin
        if (!PRESETn)
            data <= 8'b0;
        else begin
            if (PCLK && PENABLE && PWRITE)
                data <= PWDATA;
        end
    end

endmodule
