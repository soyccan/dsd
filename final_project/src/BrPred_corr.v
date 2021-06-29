module BrPred_corr(
    input                  clk,
    input                  rst,

    input                  BranchTaken_i,
    input         [31:0]   WriteAddr_i,
    input         [31:0]   WriteTarget_i,

    input         [31:0]   ReadAddr_i,
    output        [31:0]   ReadTarget_o,
    output                 Hit_o
);


parameter  NUM_HISTORY     = 3;
parameter  NUM_INDEX_BIT   = 3;
localparam NUM_HIST_REG    = 1 << NUM_HISTORY;
localparam NUM_ENTRY       = 1 << NUM_INDEX_BIT;

localparam S_NONTAKEN      = 0;
localparam S_NEAR_NONTAKEN = 1;
localparam S_NEAR_TAKEN    = 2;
localparam S_TAKEN         = 3;


function next_state;
    input state;

    if (BranchTaken_i) begin
        case (state)
            S_NONTAKEN: begin
                next_state = S_NEAR_NONTAKEN;
            end
            S_NEAR_NONTAKEN: begin
                next_state = S_NEAR_TAKEN;
            end
            S_NEAR_TAKEN: begin
                next_state = S_TAKEN;
            end
            S_TAKEN: begin
                next_state = S_TAKEN;
            end
        endcase
    end
    else begin
        case (state)
            S_NONTAKEN: begin
                next_state = S_NONTAKEN;
            end
            S_NEAR_NONTAKEN: begin
                next_state = S_NONTAKEN;
            end
            S_NEAR_TAKEN: begin
                next_state = S_NEAR_NONTAKEN;
            end
            S_TAKEN: begin
                next_state = S_NEAR_TAKEN;
            end
        endcase
    end
endfunction


reg [NUM_HISTORY-1:0] history;
reg [NUM_HISTORY-1:0] history_nxt;

reg [1:0]  predict      [0:NUM_HIST_REG-1][0:NUM_ENTRY-1];
reg [1:0]  predict_nxt  [0:NUM_HIST_REG-1][0:NUM_ENTRY-1];

wire [NUM_INDEX_BIT-1:0] read_index;
wire [NUM_INDEX_BIT-1:0] write_index;

integer i, j;


//// Combinational ////

assign ReadTarget_o = 0;

assign Hit_o =
    predict[history][read_index] == S_TAKEN
    || predict[history][read_index] == S_NEAR_TAKEN;

assign read_index = ReadAddr_i[NUM_INDEX_BIT+1:2];
assign write_index = WriteAddr_i[NUM_INDEX_BIT+1:2];

always @* begin
    history_nxt[0] = BranchTaken_i;

    for (i = 1; i < NUM_HISTORY; i = i + 1) begin
        history_nxt[i] = history[i-1];
    end
end

always @* begin
    for (i = 0; i < NUM_HIST_REG; i = i + 1) begin
        for (j = 0; j < NUM_ENTRY; j = j + 1) begin
            predict_nxt[i][j] = predict[i][j];
        end
    end

    predict_nxt[history][write_index] =
        next_state(predict[history][write_index]);
end

//// Sequntial ////

always @(posedge clk) begin
    if (rst) begin
        history <= 0;
    end
    else begin
        history <= history_nxt;
    end

    for (i = 0; i < NUM_HIST_REG; i = i + 1) begin
        for (j = 0; j < NUM_ENTRY; j = j + 1) begin
            if (rst) begin
                predict[i][j] <= 0;
            end
            else begin
                predict[i][j] <= predict_nxt[i][j];
            end
        end
    end
end

endmodule
