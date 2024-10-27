module apb #(parameter data_size = 8)
(
        input pclk, pwrite, psel, penable, presetn,
        input [data_size-1:0] pwdata, paddr,
        input [data_size-1:0] rdata,
        input full, empty, almost_full, almost_empty,

        output logic new_data,
        output logic [data_size-1:0] prdata,
        output logic [data_size-1:0] config_reg,        // 0
        output logic [data_size-1:0] control_reg,       // 1
        output [data_size-1:0] wdata,
        output pready
);

logic [data_size-1:0] input_reg;        // 2
logic [data_size-1:0] status_reg;       // 3
logic [data_size-1:0] output_reg;       // 4

assign pready = ~full;
assign wdata = input_reg;

always_comb begin
        if (paddr == 8'd3) prdata = status_reg;
        else prdata = output_reg;
end

always_ff @(posedge pclk or negedge presetn) begin
        if (~presetn) begin
                output_reg <= 0;
                status_reg <= 0;
        end else begin
                output_reg <= rdata;
                status_reg <= {4'b0, empty, full, almost_empty, almost_full};
        end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        input_reg       <= 8'b0;
        control_reg     <= 8'b0;
        config_reg      <= 8'b0;
        new_data        <= 1'b0;
    end
    else begin
        if (psel & penable) begin
                if (pwrite) begin
                        if (paddr == 8'd0)              config_reg      <= pwdata;
                        else if (paddr == 8'd2) begin
                                                        input_reg       <= pwdata;
                                                        new_data        <= 1'b1;
                        end
                        else if (paddr == 8'd1)         control_reg     <= pwdata;
                end
        end
        else begin
                input_reg       <= input_reg;
                control_reg     <= control_reg;
                config_reg      <= config_reg;
                new_data        <= 1'b0;
        end
    end
end
endmodule
