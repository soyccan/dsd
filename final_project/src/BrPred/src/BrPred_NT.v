module BrPred(
    input                  clk,
    input                  rst,

    input                  branchTaken_i,
    input         [31:0]   WriteAddr_i,
    input         [31:0]   WriteTarget_i,

    input                  beq_i,
    input                  bne_i,
    input         [31:0]   ReadAddr_i,
    output reg    [31:0]   ReadTarget_o,
    output reg             hit_o
);

always @(*) begin
    ReadTarget_o = WriteAddr_i;
    hit_o = 0;
end


parameter NUM_INDEX_BIT = 3;
parameter NUM_ENTRY = 8;

localparam S_NONTAKEN = 0;
localparam S_NEAR_NONTAKEN = 1;
localparam S_NEAR_TAKEN = 2;
localparam S_TAKEN = 3;

/*
reg [1:0] predict [0:NUM_ENTRY-1];
reg [1:0] nxt_predict [0:NUM_ENTRY-1];
//
wire [NUM_INDEX_BIT-1:0] index;
//
integer i;
//
//
assign index = Addr_i[NUM_INDEX_BIT-1:0];
//
assign Hit_o =
always @* begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        nxt_predict[i] = predict[i];
    end

    nxt_predict[index] = Target_i;
end

always @(posedge clk) begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        predict[i] <= nxt_predict[i];
    end
end
*/
endmodule