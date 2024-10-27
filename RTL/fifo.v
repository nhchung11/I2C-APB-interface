// `include "./../define/define.sv"
// TOP
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

// FULL
module fifo_full #(parameter address_size = 3)
    (
        input winc, wclk, wrst_n,
        input [address_size:0] wq2_rptr,
        input [3:0] full_level,

        output logic wfull, 
        output logic almost_full,
        output logic [address_size-1:0] waddr,
        output logic [address_size:0] wptr
    );

    logic a_full;
    logic [address_size:0] bin;
    logic [address_size:0] bnext, gnext, bnext2, gnext2;

    assign bnext = bin + (winc & ~wfull);
    assign bnext2 = (winc & ~almost_full) ?  bnext + full_level : bnext;    

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (~wrst_n)    bin <= 0;
        else            bin <= bnext;
    end

    assign gnext = (bnext>>1) ^ bnext;
    assign gnext2 = (bnext2 >> 1) ^ bnext2;
    assign waddr = bin[address_size-1:0];

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (~wrst_n)    wptr <= 0;
        else            wptr <= gnext[address_size-1:0];
    end

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (~wrst_n)    wfull <= 0;
        else            wfull <= (gnext == {~wq2_rptr[address_size:address_size-1], wq2_rptr[address_size-2:0]});
    end

    always_ff @(posedge wclk or negedge wrst_n) begin
      if (~wrst_n)    a_full <= 0;
      else            a_full <= (~wfull) & (gnext2 == {~wq2_rptr[address_size:address_size-1], wq2_rptr[address_size-2:0]});
    end

    always_comb begin
        if (!wfull) begin
            if (a_full) almost_full = 1;
        end else begin
            almost_full = 0;
        end
    end
endmodule

// EMPTY
module fifo_empty #(parameter address_size = 3)
  (
      input rinc, rclk, rrst_n,
      input [address_size:0] rq2_wptr,
      input [3:0] empty_level,
      output logic rempty, almost_empty,
      output logic [address_size-1:0] raddr,
      output logic [address_size:0] rptr
  );
  logic a_empty;
  logic [address_size:0] bin;
  logic [address_size:0]  bnext, gnext;
  logic [address_size:0] bnext2, gnext2;

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (~rrst_n)    bin <= 0;
    else            bin <= bnext;
  end

  assign bnext = bin + (rinc & ~rempty);
  assign bnext2 = (rinc & ~almost_empty) ? bnext + empty_level : bnext;

  assign gnext = (bnext>>1) ^ bnext;
  assign gnext2 = (bnext2>>1) ^ bnext2;
  assign raddr = bin[address_size-1:0];

  always_ff @(posedge rclk or negedge rrst_n) begin
      if (~rrst_n)    rempty <= 1'b1;
      else            rempty <= (gnext == rq2_wptr);
  end
  always_ff @(posedge rclk or negedge rrst_n) begin
      if (~rrst_n)    rptr <= 0;
      else            rptr <= gnext;
  end
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (~rrst_n)    a_empty <= 1'b0;
    else            a_empty <= (~rempty) & (gnext2 == rq2_wptr);
  end

  always_comb begin
    if (!rempty) begin
      if (a_empty) almost_empty = 1;
    end else begin
      almost_empty = 0;
    end
  end
endmodule

// SYNC_W2R
module sync_w2r #(parameter address_size)
  (
    input rclk, rrst_n,
    input [address_size:0] wptr,

    output logic [address_size:0] rq2_wptr
  );

  logic [address_size:0] rq2_wptr_tmp;

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (~rrst_n) {rq2_wptr, rq2_wptr_tmp} <= 0;
    else {rq2_wptr, rq2_wptr_tmp} <= {rq2_wptr_tmp, wptr};
  end
endmodule

// SYNC_R2W
module sync_r2w #(parameter address_size)
  (
    input wclk, wrst_n,
    input [address_size:0] rptr,

    output logic [address_size:0] wq2_rptr
  );

  logic [address_size:0] wq2_rptr_tmp;

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (~wrst_n) {wq2_rptr, wq2_rptr_tmp} <= 0;
    else {wq2_rptr, wq2_rptr_tmp} <= {wq2_rptr_tmp, rptr};
  end
endmodule

// MEM
module fifo_mem #(parameter data_size, address_size)
    (
        input wire wclk, winc, wfull,
        input wire [data_size-1:0] wdata,
        input wire [address_size-1:0] waddr, raddr,

        output wire [data_size-1:0] rdata
    );
    localparam fifo_depth = 1<<address_size;
    logic [data_size-1:0] mem [0:fifo_depth-1];

    assign rdata = mem[raddr];
    always_ff @(posedge wclk) begin
        if (winc && ~wfull) begin
            mem[waddr] <= wdata;
        end
    end
endmodule
