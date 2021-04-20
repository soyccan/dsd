`include "Const.v"

module Branch(
    input Branch_i,          // whether the instruction is a branch
    input ALUZero_i,         // ALU result
    input ALUOverflow_i,     // ALU result
    input [2:0] Funct3_i,    // type of branch
    output reg BranchTaken_o // whether branch should be taken
);

always @* begin
    BranchTaken_o = 1'b0;

    if (~Branch_i) begin
        BranchTaken_o = 1'b0;
    end
    else begin
        // beq
        BranchTaken_o = ALUZero_i;
    end
end

endmodule
