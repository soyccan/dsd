module BrPred_global_1bit(
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
localparam S_TAKEN         = 1;

reg   predict    ;
reg   predict_nxt;


//// Combinational ////

assign ReadTarget_o = 0;

assign Hit_o = predict == S_TAKEN;


always @* begin
    predict_nxt = predict;

    if (BranchTaken_i) begin
        case (predict)
            S_NONTAKEN: begin
                predict_nxt = S_TAKEN;
            end
            S_TAKEN: begin
                predict_nxt = S_TAKEN;
            end
        endcase
    end
    else begin
        case (predict)
            S_NONTAKEN: begin
                predict_nxt = S_NONTAKEN;
            end
            S_TAKEN: begin
                predict_nxt = S_TAKEN;
            end
        endcase
    end
end

//// Sequntial ////

always @(posedge clk) begin
    if (rst) begin
        predict <= 0;
    end
    else begin
        predict <= predict_nxt;
    end
end

endmodule
