// `include "./../define/define.sv"

module top #(parameter data_size = 8, address_size = 3)
(
        input pclk, core_clk, presetn, psel, penable, pwrite,
        input [data_size-1:0] pwdata, paddr,

        output [data_size-1:0] prdata,
        output pready
);

wire full, empty, almost_full, almost_empty, new_data;
wire [data_size-1:0] cfg, control, wdata;
wire [data_size-1:0] rdata;

apb #(.data_size(data_size)) apb_ins
(
        .pclk(pclk),
        .presetn(presetn),
        .pwdata(pwdata),
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .rdata(rdata),
        .pready(pready),
        .prdata(prdata),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .wdata(wdata),
        .config_reg(cfg),
        .control_reg(control),
        .new_data(new_data)
);

fifo_top_syn #(.data_size(data_size), .address_size(address_size)) fifo_ins
(
        .wclk(pclk),
        .rclk(core_clk),
        .wrst_n(control[0]),
        .rrst_n(control[1]),
        .winc(control[2] & new_data),
        .rinc(control[3]),
        .wdata(wdata),
        .rdata(rdata),
        .wfull(full),
        .rempty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .cfg(cfg)
);
endmodule
