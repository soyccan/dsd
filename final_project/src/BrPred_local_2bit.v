module BrPred_local_2bit(
    input                  clk,
    input                  rst,

    input                  BranchTaken_i,
    input         [31:0]   WriteAddr_i,
    input         [31:0]   WriteTarget_i,

    input         [31:0]   ReadAddr_i,
    output        [31:0]   ReadTarget_o,
    output                 Hit_o
);

parameter  NUM_INDEX_BIT   = 3;
localparam NUM_ENTRY       = 1 << NUM_INDEX_BIT;

localparam S_NONTAKEN      = 0;
localparam S_NEAR_NONTAKEN = 1;
localparam S_NEAR_TAKEN    = 2;
localparam S_TAKEN         = 3;

reg [31:0] target      [0:NUM_ENTRY-1];
reg [31:0] target_nxt  [0:NUM_ENTRY-1];

reg [1:0]  predict     [0:NUM_ENTRY-1];
reg [1:0]  predict_nxt [0:NUM_ENTRY-1];

wire [NUM_INDEX_BIT-1:0] read_index;
wire [NUM_INDEX_BIT-1:0] write_index;

integer i;


//// Combinational ////

assign ReadTarget_o = target[read_index];

assign Hit_o =
    predict[read_index] == S_TAKEN
    || predict[read_index] == S_NEAR_TAKEN;

assign read_index = ReadAddr_i[NUM_INDEX_BIT+1:2];
assign write_index = WriteAddr_i[NUM_INDEX_BIT+1:2];

always @* begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        target_nxt[i] = target[i];
    end

    if (BranchTaken_i) begin
        target_nxt[write_index] = { WriteTarget_i[31:2], 2'b00 };
    end
end

always @* begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        predict_nxt[i] = predict[i];
    end

    if (BranchTaken_i) begin
        case (predict[write_index])
            S_NONTAKEN: begin
                predict_nxt[write_index] = S_NEAR_NONTAKEN;
            end
            S_NEAR_NONTAKEN: begin
                predict_nxt[write_index] = S_NEAR_TAKEN;
            end
            S_NEAR_TAKEN: begin
                predict_nxt[write_index] = S_TAKEN;
            end
            S_TAKEN: begin
                predict_nxt[write_index] = S_TAKEN;
            end
        endcase
    end
    else begin
        case (predict[write_index])
            S_NONTAKEN: begin
                predict_nxt[write_index] = S_NONTAKEN;
            end
            S_NEAR_NONTAKEN: begin
                predict_nxt[write_index] = S_NONTAKEN;
            end
            S_NEAR_TAKEN: begin
                predict_nxt[write_index] = S_NEAR_NONTAKEN;
            end
            S_TAKEN: begin
                predict_nxt[write_index] = S_NEAR_TAKEN;
            end
        endcase
    end
end

//// Sequntial ////

always @(posedge clk) begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        if (rst) begin
            predict[i] <= 0;
            target[i] <= 0;
        end
        else begin
            predict[i] <= predict_nxt[i];
            target[i] <= target_nxt[i];
        end
    end
end

endmodule
