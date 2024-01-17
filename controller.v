module i2c_controller
(
	input wire          clk,
	input wire          rst,
	input wire [6:0]    slave_address,
    input wire [7:0]    data_in,
    input wire          rw,
	inout               sda,        // tristate
	inout               scl         // tristate
);

// FSM
localparam IDLE =           0;
localparam START =          1;
localparam WRITE_ADDRESS =  2; 
localparam ADDRESS_ACK =    3;
localparam WRITE_DATA =     4;
localparam DATA_ACK =       5;
localparam STOP =           6;

reg [2:0]   state;
reg         sda_out;
reg         scl_out = 0;
reg [2:0]   counter;
reg [6:0]   saved_addr;
reg [7:0]   saved_data;
reg         ack;
reg         write;

assign sda = sda_out;
assign scl = (write == 1) ? clk : 1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ack <= 0;
        state <= IDLE;
        counter <= 7;
        write <= 0;
    end else begin
        case (state)
        IDLE: begin
            ack <= 0;
            sda_out <= 1;
            scl_out <= 1;
            state <= START;
        end
        START: begin
            saved_addr <= {slave_address[counter], rw};
            sda_out <= 0;
            state <= WRITE_ADDRESS;
        end
        WRITE_ADDRESS: begin
            write <= 1;
            sda_out <= saved_addr[8];
        end
        ADDRESS_ACK: begin
            write <= 0;
            ack <= 1;
            saved_data <= {data_in[8]};
            state <= WRITE_DATA;
        end
        WRITE_DATA: begin
            write <= 1;
            ack <= 0;
            sda_out <= saved_data;
            state <= DATA_ACK;
        end
        DATA_ACK: begin
            write <= 0;
            ack <= 1;
            state <= STOP;
        end
        STOP: begin
            ack <= 0;
            state <= IDLE;
        end
        default: begin
            state <= IDLE;
        end
      endcase
    end
end
endmodule