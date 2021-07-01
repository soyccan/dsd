// 2-Way Associative Cache SRAM
module cache_sram_2way(
    input              clk,
    input              rst,
    input      [29:0]  addr_i,
    input      [155:0] wdata_i,
    input              write_i,
    output     [155:0] rdata_o,
    output             hit_o
);

integer i;

//// Wire/Reg Declaration ////
// input address
wire [25:0] tag_i;
wire [1:0] index;

// internal info

// valid(1), dirty(1), tag(26), word0(32), word1(32), word2(32), word3(32)
reg [155:0] sram[0:3][0:1];

reg lru[0:3]; // lru[index]: the next way to be write back
reg way;
wire lru_nxt;

reg [155:0] entry[0:1];
reg valid[0:1];
reg hit[0:1];
reg [25:0] tag[0:1];

//// Combinational Logic ////
// word address: tag(26), index(2), offset(2)
assign tag_i   = addr_i[29:4];
assign index   = addr_i[3:2];

assign rdata_o = entry[way];
assign hit_o   = hit[0] || hit[1];

assign lru_nxt = ~way;

always @* begin
    for (i = 0; i < 2; i = i + 1) begin
        entry[i] = sram[index][i];
        valid[i] = entry[i][155];
        tag[i] = entry[i][153:128];
        hit[i] = valid[i] && tag[i] == tag_i;
    end
end

always @* begin
    if (hit[0]) begin
        way = 0;
    end
    else if (hit[1]) begin
        way = 1;
    end
    else begin
        way = lru[index];
    end
end

//// Sequential Logic ////
always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            sram[i / 2][i % 2] <= 0;
        end
    end
    else if (write_i) begin
        sram[index][way] <= wdata_i;
    end
end

always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 4; i = i + 1) begin
            lru[i] <= 0;
        end
    end
    else if (write_i) begin
        lru[index] <= lru_nxt;
    end
end

endmodule