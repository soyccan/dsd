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

//// Wire/Reg definition ////

//// Combinational logic ////

//// Sequential logic ////
always @(posedge clk) begin
    if (proc_reset) begin
    end
    else begin
    end
end

endmodule
