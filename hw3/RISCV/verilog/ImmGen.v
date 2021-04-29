`include "Const.v"

module ImmGen(input  [31:0] Inst_i,
              output reg [31:0] Imm_o);

wire [6:0] opcode = Inst_i[6:0];

always @* begin
    // default overlap with most immediate types to minimize area
    // Imm_o = $signed({Inst_i[31:21], 1'b0});
    Imm_o = 32'bx;

    case (opcode)

        `OPCODE_OP_IMM, `OPCODE_LOAD, `OPCODE_JALR:
            Imm_o = $signed(Inst_i[31:20]);

        `OPCODE_STORE:
            Imm_o = $signed({Inst_i[31:25], Inst_i[11:7]});

        `OPCODE_BRANCH:
            Imm_o = $signed({Inst_i[31], Inst_i[7], Inst_i[30:25],
                             Inst_i[11:8], 1'b0});

        `OPCODE_JAL:
            Imm_o = $signed({Inst_i[31], Inst_i[19:12], Inst_i[20],
                             Inst_i[30:21], 1'b0});

    endcase
end

endmodule
