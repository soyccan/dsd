module BrPred_tournament(
    input                  clk,
    input                  rst,

    input                  BranchTaken_i,
    input         [31:0]   WriteAddr_i,
    input         [31:0]   WriteTarget_i,

    input         [31:0]   ReadAddr_i,
    output        [31:0]   ReadTarget_o,
    output                 Hit_o
);

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


parameter  NUM_HISTORY     = 3;
parameter  NUM_INDEX_BIT   = 3;
localparam NUM_ENTRY       = 1 << NUM_INDEX_BIT;

localparam S_NONTAKEN      = 0;
localparam S_NEAR_NONTAKEN = 1;
localparam S_NEAR_TAKEN    = 2;
localparam S_TAKEN         = 3;


reg [NUM_HISTORY-1:0] history;
reg [NUM_HISTORY-1:0] history_nxt;

reg [1:0]  predict_global     [0:NUM_HISTORY-1];
reg [1:0]  predict_global_nxt [0:NUM_HISTORY-1];

reg [1:0]  predict_local      [0:NUM_ENTRY-1];
reg [1:0]  predict_local_nxt  [0:NUM_ENTRY-1];

reg        selector           [0:NUM_ENTRY-1];
reg        selector_nxt       [0:NUM_ENTRY-1];

wire [NUM_INDEX_BIT-1:0] read_index;
wire [NUM_INDEX_BIT-1:0] write_index;

integer i;


//// Combinational ////

assign ReadTarget_o = 0;

assign use_global =
    selector[read_index] == S_TAKEN || selector[read_index] == S_NEAR_TAKEN;

assign Hit_o =
    predict_local[read_index] == S_TAKEN
    || predict_local[read_index] == S_NEAR_TAKEN;

assign read_index = ReadAddr_i[NUM_INDEX_BIT+1:2];
assign write_index = WriteAddr_i[NUM_INDEX_BIT+1:2];

always @* begin
    history_nxt[0] = BranchTaken_i;

    for (i = 1; i < NUM_HISTORY; i = i + 1) begin
        history_nxt[i] = history[i-1];
    end
end

always @* begin
    for (i = 0; i < NUM_HISTORY; i = i + 1) begin
        predict_global_nxt[i] = predict_global[i];
    end

    predict_global_nxt[history] = next_state(predict_global[history]);
end

always @* begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        predict_local_nxt[i] = predict_local[i];
    end

    predict_local_nxt[write_index] = next_state(predict_local[write_index]);
end

//// Sequntial ////

always @(posedge clk) begin
    if (rst) begin
        history <= 0;
    end
    else begin
        history <= history_nxt;
    end

    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        if (rst) begin
            predict_local[i] <= 0;
            selector[i] <= 0;
        end
        else begin
            predict_local[i] <= predict_local_nxt[i];
            selector[i] <= selector_nxt[i];
        end
    end

    for (i = 0; i < NUM_HISTORY; i = i + 1) begin
        if (rst) begin
            predict_global[i] <= 0;
        end
        else begin
            predict_global[i] <= predict_global_nxt[i];
        end
    end
end

endmodule
