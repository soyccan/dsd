`define TWO_WAY

module cache_I(
    input             clk,

    // processor interface
    input             proc_reset,
    input             proc_read,
    input             proc_write,
    input      [29:0] proc_addr,
    output reg [31:0] proc_rdata,
    input      [31:0] proc_wdata,
    output            proc_stall,

    // memory interface
    output reg         mem_read,
    output reg         mem_write,
    output reg [27:0]  mem_addr,
    input      [127:0] mem_rdata,
    output     [127:0] mem_wdata,
    input              mem_ready
);


//// Parameters ////

//// Constants ////
localparam STATE_IDLE        = 3'd0;
localparam STATE_ALLOCATE    = 3'd2;


//// Wire/Reg Declaration ////
wire proc_access;

`ifndef TWO_WAY
    // direct-mapped
    wire [154:0] sram_rdata;
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
        .rst(proc_reset),

        .addr_i(proc_addr),
        .wdata_i(),
        .write_i(0),

        .rdata_o(sram_rdata),
        .hit_o(sram_hit)
    );
`else
    cache_sram_2way cache_sram_2way_U(
        .clk(clk),
        .rst(proc_reset),

        .addr_i(proc_addr),
        .wdata_i(),
        .write_i(0),

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
                state_nxt = STATE_ALLOCATE;
            end
        end

        STATE_ALLOCATE: begin
            if (mem_ready) begin
                state_nxt = STATE_IDLE;
            end
        end
    endcase
end

// State Register
always @(posedge clk) begin
    if (proc_reset) begin
        state <= STATE_IDLE;
    end
    else begin
        state <= state_nxt;
    end
end

// Output Logic
always @* begin
    mem_read  = 0;
    mem_write = 0;
    mem_addr  = proc_addr[29:2];

    case (state)
        STATE_IDLE: begin
        end

        STATE_ALLOCATE: begin
            mem_read  = 1;
            mem_addr  = proc_addr[29:2];
        end
    endcase
end


//// Combinational Logic ////
assign proc_access    = 1;
assign proc_stall     = proc_access && !sram_hit;

assign mem_wdata      = sram_data;

always @* begin
    for (i = 0; i < 32; i=i+1) begin
        proc_rdata[i] = sram_data[(proc_addr_offset<<5) + i];
    end
end

`ifndef TWO_WAY
    // direct-mapped
    assign sram_tag         = sram_rdata[152:128];
    assign sram_data        = sram_rdata[127:0];

    assign proc_addr_tag    = proc_addr[29:5];
    assign proc_addr_index  = proc_addr[4:2];
    assign proc_addr_offset = proc_addr[1:0];

`else
    // 2-way
    assign sram_tag         = sram_rdata[153:128];
    assign sram_data        = sram_rdata[127:0];

    assign proc_addr_tag    = proc_addr[29:4];
    assign proc_addr_index  = proc_addr[3:2];
    assign proc_addr_offset = proc_addr[1:0];

`endif


//// Sequential Logic ////


endmodule
