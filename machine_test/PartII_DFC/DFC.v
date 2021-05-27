module DFC(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [1:0]   cmd;
input           cmd_valid;
output  [8:0]   dataout;
output          output_valid;
output          busy;

localparam IDLE          = 5'd0;
localparam READ_A1       = 5'd1;
localparam READ_A2       = 5'd2;
localparam READ_A3       = 5'd3;
localparam READ_A4       = 5'd4;
localparam READ_B1       = 5'd5;
localparam READ_B2       = 5'd6;
localparam READ_B3       = 5'd7;
localparam READ_B4       = 5'd8;
localparam WRITE_Y1_FIFO = 5'd9;
localparam WRITE_Y2_FIFO = 5'd10;
localparam WRITE_Y3_FIFO = 5'd11;
localparam WRITE_Y4_FIFO = 5'd12;
localparam WRITE_Y1_LIFO = 5'd13;
localparam WRITE_Y2_LIFO = 5'd14;
localparam WRITE_Y3_LIFO = 5'd15;
localparam WRITE_Y4_LIFO = 5'd16;

reg busy,output_valid;
reg [8:0] dataout;
reg [7:0] a[0:3];
reg [7:0] b[0:3];
wire [8:0] y[0:3];
reg [7:0] a_nxt[0:3];
reg [7:0] b_nxt[0:3];
reg [4:0] state, state_nxt;

integer i;


ALU A0	(.out(y[0]), .mode(1'b1), .in_a(a[0]), .in_b(b[0]));
ALU A1	(.out(y[1]), .mode(1'b1), .in_a(a[1]), .in_b(b[1]));
ALU A2	(.out(y[2]), .mode(1'b1), .in_a(a[2]), .in_b(b[2]));
ALU A3	(.out(y[3]), .mode(1'b1), .in_a(a[3]), .in_b(b[3]));


//========= FSM =================
always @(posedge clk or posedge reset) begin
	if (reset) state <= IDLE;
	else state <= state_nxt;
end

// next state logic
always@(*) begin
    state_nxt = state;

	case (state)
        IDLE: begin
            if (cmd_valid) begin
                case (cmd)
                    2'b00: state_nxt = READ_A1;
                    2'b01: state_nxt = WRITE_Y1_FIFO;
                    2'b10: state_nxt = WRITE_Y4_LIFO;
                endcase
            end
        end

        READ_A1: state_nxt = READ_A2;
        READ_A2: state_nxt = READ_A3;
        READ_A3: state_nxt = READ_A4;
        READ_A4: state_nxt = READ_B1;
        READ_B1: state_nxt = READ_B2;
        READ_B2: state_nxt = READ_B3;
        READ_B3: state_nxt = READ_B4;
        READ_B4: state_nxt = IDLE;

        WRITE_Y1_FIFO: state_nxt = WRITE_Y2_FIFO;
        WRITE_Y2_FIFO: state_nxt = WRITE_Y3_FIFO;
        WRITE_Y3_FIFO: state_nxt = WRITE_Y4_FIFO;
        WRITE_Y4_FIFO: state_nxt = IDLE;

        WRITE_Y4_LIFO: state_nxt = WRITE_Y3_LIFO;
        WRITE_Y3_LIFO: state_nxt = WRITE_Y2_LIFO;
        WRITE_Y2_LIFO: state_nxt = WRITE_Y1_LIFO;
        WRITE_Y1_LIFO: state_nxt = IDLE;
	endcase
end

// output logic
always@(*) begin
    for (i=0; i<4; i=i+1) begin
        a_nxt[i] = a[i];
        b_nxt[i] = b[i];
    end
    output_valid = 0;
    dataout = 0;
    busy = 1;

	case (state)
        IDLE: begin busy = 0; end

        READ_A1: begin a_nxt[0] = datain; end
        READ_A2: begin a_nxt[1] = datain; end
        READ_A3: begin a_nxt[2] = datain; end
        READ_A4: begin a_nxt[3] = datain; end
        READ_B1: begin b_nxt[0] = datain; end
        READ_B2: begin b_nxt[1] = datain; end
        READ_B3: begin b_nxt[2] = datain; end
        READ_B4: begin b_nxt[3] = datain; end

        WRITE_Y1_FIFO: begin output_valid = 1; dataout = y[0]; end
        WRITE_Y2_FIFO: begin output_valid = 1; dataout = y[1]; end
        WRITE_Y3_FIFO: begin output_valid = 1; dataout = y[2]; end
        WRITE_Y4_FIFO: begin output_valid = 1; dataout = y[3]; end

        WRITE_Y4_LIFO: begin output_valid = 1; dataout = y[3]; end
        WRITE_Y3_LIFO: begin output_valid = 1; dataout = y[2]; end
        WRITE_Y2_LIFO: begin output_valid = 1; dataout = y[1]; end
        WRITE_Y1_LIFO: begin output_valid = 1; dataout = y[0]; end
	endcase
end

//============== Combinational =================

// dataout, output_valid
// always @(*) begin
//     output_valid = 1'b0;
//     dataout = 8'd0;
//
//     if (state == WRITE_Y1_FIFO || state == WRITE_Y1_LIFO) begin
//         output_valid = 1'b1;
//         dataout = y[0];
//     end
//     else if (state == WRITE_Y2_FIFO || state == WRITE_Y2_LIFO) begin
//         output_valid = 1'b1;
//         dataout = y[1];
//     end
//     else if (state == WRITE_Y3_FIFO || state == WRITE_Y3_LIFO) begin
//         output_valid = 1'b1;
//         dataout = y[2];
//     end
//     else if (state == WRITE_Y3_FIFO || state == WRITE_Y4_LIFO) begin
//         output_valid = 1'b1;
//         dataout = y[3];
//     end
// end

//busy
// always @(*) begin
//     if (state==IDLE)
//         busy = 1'b0;
//     else
//         busy = 1'b1;
// end

//=============== Sequential =================
always @(posedge clk or posedge reset) begin
	if (reset) begin
        for(i=0;i<4;i=i+1) begin
			a[i] <= 0;
			b[i] <= 0;
        end
	end
	else begin
        for(i=0;i<4;i=i+1) begin
            a[i] <= a_nxt[i];
            b[i] <= b_nxt[i];
        end
	end
end

endmodule
