`include "cache_controller.v"

module cache(
    input          clk,

    // processor interface
    input          proc_reset,
    input          proc_read, proc_write,
    input   [29:0] proc_addr,
    output  [31:0] proc_rdata,
    input   [31:0] proc_wdata,
    output         proc_stall,

    // memory interface
    output         mem_read, mem_write,
    output  [27:0] mem_addr,
    input  [127:0] mem_rdata,
    output [127:0] mem_wdata,
    input          mem_ready
);

cache_controller cache_controller_U(
    .clk(clk),
    .proc_reset_i(proc_reset),
    .proc_read_i(proc_read),
    .proc_write_i(proc_write),
    .proc_addr_i(proc_addr),
    .proc_rdata_o(proc_rdata),
    .proc_wdata_i(proc_wdata),
    .proc_stall_o(proc_stall),
    .mem_read_o(mem_read),
    .mem_write_o(mem_write),
    .mem_addr_o(mem_addr),
    .mem_rdata_i(mem_rdata),
    .mem_wdata_o(mem_wdata),
    .mem_ready_i(mem_ready)
);

endmodule
