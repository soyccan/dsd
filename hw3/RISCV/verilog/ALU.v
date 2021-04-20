`include "Const.v"

module ALU(input [3:0] ALUCtl_i,
           input [31:0] Op1_i,
           input [31:0] Op2_i,
           output reg [31:0] Res_o,
           output Zero_o,
           output reg Overflow_o);

assign Zero_o = ~|Res_o;

always @* begin
    Overflow_o = 1'b0;
    Res_o = 32'b0;

    case (ALUCtl_i)
        `ALU_CTL_ADD:  {Overflow_o, Res_o} = $signed(Op1_i) + $signed(Op2_i);
        `ALU_CTL_SUB:  {Overflow_o, Res_o} = $signed(Op1_i) - $signed(Op2_i);
        // `ALU_CTL_SUBU: {Overflow_o, Res_o} = Op1_i - Op2_i; // for bltu, bgeu
        `ALU_CTL_SLT:  Res_o = $signed(Op1_i) < $signed(Op2_i);
        // `ALU_CTL_SLTU: Res_o = Op1_i < Op2_i;
        `ALU_CTL_XOR:  Res_o = Op1_i ^ Op2_i;
        `ALU_CTL_OR:   Res_o = Op1_i | Op2_i;
        `ALU_CTL_AND:  Res_o = Op1_i & Op2_i;
        // `ALU_CTL_SLL:  Res_o = Op1_i << shft_amt;
        // `ALU_CTL_SRL:  Res_o = Op1_i >> shft_amt;
        // `ALU_CTL_SRA:  Res_o = $signed(Op1_i) >>> shft_amt;
    endcase
end

endmodule
