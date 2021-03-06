module PC
(
    input               Clk_i,
    input               Rst_i,
    input      [31:0]   PC_i,
    output reg [31:0]   PC_o
);


always @(posedge Clk_i) begin
    if (Rst_i) begin
        PC_o <= 32'b0;
    end
    else begin
        PC_o <= {PC_i[31:1], 1'b0};
    end
end

endmodule
