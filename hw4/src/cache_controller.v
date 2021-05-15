`include "cache_sram_dm.v"
`include "cache_sram_2way.v"

module cache_controller(
    input             clk,

    // processor interface
    input             proc_reset_i,
    input             proc_read_i,
    input             proc_write_i,
    input      [29:0] proc_addr_i,
    output reg [31:0] proc_rdata_o,
    input      [31:0] proc_wdata_i,
    output            proc_stall_o,

    // memory interface
    output reg         mem_read_o,
    output reg         mem_write_o,
    output reg [27:0]  mem_addr_o,
    input      [127:0] mem_rdata_i,
    output     [127:0] mem_wdata_o,
    input              mem_ready_i
);


//// Parameters ////

//// Constants ////
localparam STATE_IDLE        = 3'd0;
localparam STATE_WRITEBACK   = 3'd1;
localparam STATE_ALLOCATE    = 3'd2;
localparam STATE_READY       = 3'd3;


//// Wire/Reg Declaration ////
wire proc_access;

`ifndef TWO_WAY
    // direct-mapped
    wire [154:0] sram_rdata;
    reg [154:0] sram_wdata;
    wire [24:0] sram_tag;
    wire [24:0] proc_addr_tag;
    wire [2:0] proc_addr_index;
`else
    // 2-way
    wire [155:0] sram_rdata;
    reg [155:0] sram_wdata;
    wire [25:0] sram_tag;
    wire [25:0] proc_addr_tag;
    wire [1:0] proc_addr_index;
`endif

wire [127:0] sram_data;
wire sram_hit;
wire sram_dirty;
reg sram_write;

wire [1:0] proc_addr_offset;

reg [2:0] state;
reg [2:0] state_nxt;

integer i;


//// Submodule Instantiation ////
`ifndef TWO_WAY
    cache_sram_dm cache_sram_dm_U(
        .clk(clk),
        .rst(proc_reset_i),

        .addr_i(proc_addr_i),
        .wdata_i(sram_wdata),
        .write_i(sram_write),

        .rdata_o(sram_rdata),
        .hit_o(sram_hit)
    );
`else
    cache_sram_2way cache_sram_2way_U(
        .clk(clk),
        .rst(proc_reset_i),

        .addr_i(proc_addr_i),
        .wdata_i(sram_wdata),
        .write_i(sram_write),

        .rdata_o(sram_rdata),
        .hit_o(sram_hit)
    );
`endif


//// Finite-State Machine ////
// Next State Logic
always @* begin
    state_nxt = state;

    case (state)
        STATE_IDLE: begin
            if (proc_access && !sram_hit) begin
                if (sram_dirty) begin
                    state_nxt = STATE_WRITEBACK;
                end
                else begin
                    state_nxt = STATE_ALLOCATE;
                end
            end
        end

        STATE_WRITEBACK: begin
            if (mem_ready_i) begin
                state_nxt = STATE_ALLOCATE;
            end
        end

        STATE_ALLOCATE: begin
            if (mem_ready_i) begin
                state_nxt = STATE_READY;
            end
        end

        STATE_READY: begin
            state_nxt = STATE_IDLE;
        end
    endcase
end

// State Register
always @(posedge clk) begin
    if (proc_reset_i) begin
        state <= STATE_IDLE;
    end
    else begin
        state <= state_nxt;
    end
end

// Output Logic
always @* begin
    mem_read_o  = 0;
    mem_write_o = 0;
    mem_addr_o  = proc_addr_i[29:2];
    sram_write  = 0;

    case (state)
        STATE_IDLE: begin
            sram_write  = proc_write_i && sram_hit;
        end

        STATE_WRITEBACK: begin
            mem_write_o = 1;
            mem_addr_o  = { sram_tag, proc_addr_index };
        end

        STATE_ALLOCATE: begin
            mem_read_o  = 1;
            mem_addr_o  = proc_addr_i[29:2];
        end

        STATE_READY: begin
            sram_write  = 1;
        end
    endcase
end


//// Combinational Logic ////
assign proc_access      = proc_read_i || proc_write_i;
assign proc_stall_o     = proc_access && !sram_hit;

assign mem_wdata_o      = sram_data;

always @* begin
    for (i = 0; i < 32; i = i + 1) begin
        proc_rdata_o[i] = sram_data[(proc_addr_offset<<5) + i];
    end
end

`ifndef TWO_WAY
    // direct-mapped
    assign sram_dirty       = sram_rdata[153];
    assign sram_tag         = sram_rdata[152:128];
    assign sram_data        = sram_rdata[127:0];

    assign proc_addr_tag    = proc_addr_i[29:5];
    assign proc_addr_index  = proc_addr_i[4:2];
    assign proc_addr_offset = proc_addr_i[1:0];

    always @* begin
        // valid(1), dirty(1), tag(25), word0(32), word1(32), word2(32), word3(32)
        sram_wdata = { 2'b11, proc_addr_tag, sram_data };

        if (state == STATE_READY) begin
            // allocate
            sram_wdata[153] = 0; // not dirty
            sram_wdata[127:0] = mem_rdata_i;
        end
        else begin
            // write hit
            sram_wdata[153] = 1; // dirty
            for (i = 0; i < 32; i = i + 1) begin
                sram_wdata[(proc_addr_offset<<5) + i] = proc_wdata_i[i];
            end
        end
    end
`else
    // 2-way
    assign sram_dirty       = sram_rdata[154];
    assign sram_tag         = sram_rdata[153:128];
    assign sram_data        = sram_rdata[127:0];

    assign proc_addr_tag    = proc_addr_i[29:4];
    assign proc_addr_index  = proc_addr_i[3:2];
    assign proc_addr_offset = proc_addr_i[1:0];

    always @* begin
        // valid(1), dirty(1), tag(26), word0(32), word1(32), word2(32), word3(32)
        sram_wdata = { 2'b11, proc_addr_tag, sram_data };

        if (state == STATE_READY) begin
            // allocate
            sram_wdata[154] = 0; // not dirty
            sram_wdata[127:0] = mem_rdata_i;
        end
        else begin
            // write hit
            sram_wdata[154] = 1; // dirty
            for (i = 0; i < 32; i = i + 1) begin
                sram_wdata[(proc_addr_offset<<5) + i] = proc_wdata_i[i];
            end
        end
    end
`endif


//// Sequential Logic ////


endmodule
