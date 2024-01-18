module i2c_core
(
	input wire          clk,
	input wire          rst_n,
    input wire          enable,
	input wire [6:0]    slave_address,
    input wire [7:0]    data_in,
    input wire          rw,
    input               sda_i, scl_i,
    output              sda_o, scl_o
	// inout               sda,        // tristate
	// inout               scl         // tristate
);

// FSM
parameter IDLE =           3'b000;
parameter START =          3'b001;
parameter WRITE_ADDRESS =  3'b010; 
parameter ADDRESS_ACK =    3'b011;
parameter WRITE_DATA =     3'b100;
parameter DATA_ACK =       3'b101;
parameter STOP =           3'b110;

reg         sda_out;
reg         scl_out;
reg [2:0]   counter;
reg [6:0]   saved_addr;
reg [7:0]   saved_data;
reg         write;

reg [2:0]   current_state;
reg [2:0]   next_state;

assign sda_o = (enable == 1) ? sda_out : 1;
assign scl_o = (write == 1) ? clk : 1;

// State register logic
always @(posedge clk, negedge rst_n) begin
    if (~rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Next state combinational logic
always @(current_state, enable, counter) begin
    case (current_state)
        IDLE: begin
            if (enable) next_state = START;
            else        next_state = IDLE;
        end
        START:          next_state = WRITE_ADDRESS;
        WRITE_ADDRESS: begin
            if (counter == 0) begin
                        next_state = ADDRESS_ACK;
            end
        end
        ADDRESS_ACK:    next_state = WRITE_DATA;
        WRITE_DATA: begin
            if (counter == 0) begin
                        next_state = DATA_ACK;
            end
        end
        DATA_ACK:       next_state = STOP;
        default:        next_state = IDLE;
    endcase
end

// Output logic
always @(current_state) begin
    case (current_state)
        IDLE: begin
            write       = 0;
            sda_out     = 1;
            scl_out     = 1;
        end
        START: begin
            counter     = 7;
            sda_out     = 0;
            saved_addr  = {slave_address, rw};
        end
        WRITE_ADDRESS: begin
            write       = 1;
            sda_out     = saved_addr[counter];
        end
        ADDRESS_ACK: begin
            write       = 0;
            sda_out     = 1;
            saved_data  = data_in;
            counter     = 7;
        end
        WRITE_DATA: begin
            write       = 1;
            sda_out     = saved_data[counter];
        end
        DATA_ACK: begin
            write       = 0;
            sda_out     = 1;
        end
        STOP: begin
            sda_out     = 1;
        end
    endcase
end

// Counter logic
always @(posedge clk) begin
    if (write)
        counter <= counter - 1;
end
endmodule
