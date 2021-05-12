// Direct-Mapped Cache SRAM
module cache_sram_dm(
    input              clk,
    input              rst,
    input      [29:0]  addr_i,
    input      [154:0] wdata_i,
    input              write_i,
    output     [154:0] rdata_o,
    output             hit_o
);

integer i;

//// Wire/Reg Declaration ////
// valid(1), dirty(1), tag(25), word0(32), word1(32), word2(32), word3(32)
reg [154:0] sram [0:7];

wire [24:0] tag_i;
wire [2:0] index;

wire valid;
wire [24:0] tag;

//// Combinational Logic ////
// word address: tag(25), index(3), offset(2)
assign tag_i   = addr_i[29:5];
assign index   = addr_i[4:2];

assign rdata_o = sram[index];
assign valid   = rdata_o[154];
assign tag     = rdata_o[152:128];

assign hit_o   = valid && tag == tag_i;

//// Sequential Logic ////
always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            sram[i] <= 0;
        end
    end
    else if (write_i) begin
        sram[index] <= wdata_i;
    end
end

endmodule
