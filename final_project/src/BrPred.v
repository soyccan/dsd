module BrPred(
    input                  clk,
    input                  rst,

    input                  BranchTaken_i,
    input         [31:0]   WriteAddr_i,
    input         [31:0]   WriteTarget_i,

    input         [31:0]   ReadAddr_i,
    output        [31:0]   ReadTarget_o,
    output                 Hit_o
);

assign ReadTarget_o = 0;
assign Hit_o = 1;

// parameter NUM_INDEX_BIT = 3;
// parameter NUM_ENTRY = 8;
//
// localparam S_NONTAKEN = 0;
// localparam S_NEAR_NONTAKEN = 1;
// localparam S_NEAR_TAKEN = 2;
// localparam S_TAKEN = 3;
//
// reg [1:0] predict [0:NUM_ENTRY-1];
// reg [1:0] nxt_predict [0:NUM_ENTRY-1];
//
// wire [NUM_INDEX_BIT-1:0] index;
//
// integer i;
//
//
// assign index = Addr_i[NUM_INDEX_BIT-1:0];
//
// assign Hit_o =
//
// always @* begin
//     for (i = 0; i < NUM_ENTRY; i = i + 1) begin
//         nxt_predict[i] = predict[i];
//     end
//
//     nxt_predict[index] = Target_i;
// end
//
// always @(posedge clk) begin
//     for (i = 0; i < NUM_ENTRY; i = i + 1) begin
//         predict[i] <= nxt_predict[i];
//     end
// end

endmodule
