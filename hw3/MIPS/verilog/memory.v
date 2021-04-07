// RISCV course modification, 2019
// Author: Chun-Yen Yao

module memory(clk, wen, a, d, q);
   
    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth
    
    input clk, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a;

    output [BITS-1:0] q;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q = wen ? d : mem[a];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (a == i)) ? d : mem[i];
    end

    always @(posedge clk) begin
        for (i=0; i<word_depth; i=i+1)
            mem[i] <= mem_nxt[i];
    end

endmodule