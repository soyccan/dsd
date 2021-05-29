`include "Def.v"

module Control(
    input [5:0] Opcode_i,
    input [5:0] Funct_i,
    output reg RegDst_o,
    output reg ALUSrc1_o,
    output reg ALUSrc2_o,
    output reg RegWrite_o,
    output reg MemToReg_o,
    output reg MemRead_o,
    output reg MemWrite_o,
    output reg Beq_o,
    output reg Bne_o,
    output reg JumpImm_o,
    output reg JumpReg_o,
    output reg Link_o,
    output reg [3:0] ALUCtl_o,
    output reg Stall_o
);

always @* begin
    RegDst_o   = `REG_DST_RD;
    ALUSrc1_o  = `ALU_SRC_REG;
    ALUSrc2_o  = `ALU_SRC_REG;
    ALUCtl_o   = `ALU_CTL_ADD;
    RegWrite_o = 0;
    MemToReg_o = 0;
    MemRead_o  = 0;
    MemWrite_o = 0;
    Beq_o      = 0;
    Bne_o      = 0;
    JumpImm_o  = 0;
    JumpReg_o  = 0;
    Link_o     = 0;
    Stall_o    = 0;

    case (Opcode_i)
        6'b000000: begin
            RegWrite_o = 1;

            case (Funct_i)
                6'b000000: begin
                    // sll
                    ALUCtl_o   = `ALU_CTL_SLL;
                    ALUSrc2_o  = `ALU_SRC_IMM;
                end

                6'b000010: begin
                    // srl
                    ALUCtl_o   = `ALU_CTL_SRL;
                    ALUSrc2_o  = `ALU_SRC_IMM;
                end

                6'b000011: begin
                    // sra
                    ALUCtl_o   = `ALU_CTL_SRA;
                    ALUSrc2_o  = `ALU_SRC_IMM;
                end

                6'b001000: begin
                    // jr
                    RegWrite_o = 0;
                    JumpReg_o  = 1;
                end

                6'b001001: begin
                    // jalr
                    JumpReg_o  = 1;
                    Link_o     = 1;
                end

                6'b100000: begin
                    // add
                    ALUCtl_o   = `ALU_CTL_ADD;
                end

                6'b100010: begin
                    // sub
                    ALUCtl_o   = `ALU_CTL_SUB;
                end

                6'b100100: begin
                    // and
                    ALUCtl_o   = `ALU_CTL_AND;
                end

                6'b100101: begin
                    // or
                    ALUCtl_o   = `ALU_CTL_OR;
                end

                6'b100110: begin
                    // xor
                    ALUCtl_o   = `ALU_CTL_XOR;
                end

                6'b100111: begin
                    // nor
                    ALUCtl_o   = `ALU_CTL_NOR;
                end

                6'b101010: begin
                    // slt
                    ALUCtl_o   = `ALU_CTL_SLT;
                end
            endcase
        end

        6'b000010: begin
            // j
            JumpImm_o  = 1;
        end

        6'b000011: begin
            // jal
            JumpImm_o  = 1;
            Link_o     = 1;
            MemToReg_o = 1'bx;
        end

        6'b000100: begin
            // beq
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            MemToReg_o = 1'bx;
            Beq_o      = 1;
        end

        6'b000101: begin
            // bne
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            MemToReg_o = 1'bx;
            Bne_o      = 1;
        end

        6'b001000: begin
            // addi
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
        end

        6'b001100: begin
            // andi
            ALUCtl_o   = `ALU_CTL_AND;
            ALUSrc2_o  = `ALU_SRC_IMM;
        end

        6'b001101: begin
            // ori
            ALUCtl_o   = `ALU_CTL_OR;
            ALUSrc2_o  = `ALU_SRC_IMM;
        end

        6'b001110: begin
            // xori
            ALUCtl_o   = `ALU_CTL_XOR;
            ALUSrc2_o  = `ALU_SRC_IMM;
        end

        6'b001010: begin
            // slti
            ALUCtl_o   = `ALU_CTL_SLT;
            ALUSrc2_o  = `ALU_SRC_IMM;
        end

        6'b100011: begin
            // lw
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b1;
            MemRead_o  = 1'b1;
        end

        6'b101011: begin
            // sw
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
            MemToReg_o = 1'bx;
            MemWrite_o = 1'b1;
            RegDst_o   = `REG_DST_RS2;
        end
    endcase
end

endmodule

