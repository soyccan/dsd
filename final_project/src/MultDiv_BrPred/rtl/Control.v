`include "/home/raid7_2/userb07/b07050/DSD/final_project/src/Def.v"
`define BrPred

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
    output reg [5:0] ALUCtl_o,
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
                end

                6'b000010: begin
                    // srl
                    ALUCtl_o   = `ALU_CTL_SRL;
                end

                6'b000011: begin
                    // sra
                    ALUCtl_o   = `ALU_CTL_SRA;
                end

                6'b001000: begin
                    // jr
                    RegWrite_o = 0;
                    JumpReg_o  = 1;

                    // TODO: should jal not stall due to branch delay slot?
                    Stall_o    = 1;
                end

                6'b001001: begin
                    // jalr
                    ALUCtl_o   = `ALU_CTL_ADD;
                    ALUSrc1_o  = `ALU_SRC_PC;
                    JumpReg_o  = 1;
                    Link_o     = 1;
                    RegWrite_o = 1;

                    // TODO: should jal not stall due to branch delay slot?
                    Stall_o    = 1;
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
                //Multdiv extension: add 4 Inst and let stall=1;
                //for syn
                6'b011010: begin
                    // div
                    ALUCtl_o   = `ALU_CTL_DIV;

                    // branch seen: insert bubble into ID stage
                    Stall_o    = 1;
                end

                6'b010000: begin
                    // mfhi
                    ALUCtl_o   = `ALU_CTL_MFHI;
                end

                6'b010010: begin
                    // mflo
                    ALUCtl_o   = `ALU_CTL_MFLO;
                end

                6'b011000: begin
                    // mult
                    ALUCtl_o   = `ALU_CTL_MULT;

                    // branch seen: insert bubble into ID stage
                    Stall_o    = 1;
                end
                //syn ends
                `ifdef MultDiv
                    6'b011010: begin
                        // div
                        ALUCtl_o   = `ALU_CTL_DIV;

                        // branch seen: insert bubble into ID stage
                        Stall_o    = 1;
                    end

                    6'b010000: begin
                        // mfhi
                        ALUCtl_o   = `ALU_CTL_MFHI;
                    end

                    6'b010010: begin
                        // mflo
                        ALUCtl_o   = `ALU_CTL_MFLO;
                    end

                    6'b011000: begin
                        // mult
                        ALUCtl_o   = `ALU_CTL_MULT;

                        // branch seen: insert bubble into ID stage
                        Stall_o    = 1;
                    end
                `endif
                //extension ends
            endcase
        end

        6'b000010: begin
            // j
            JumpImm_o  = 1;
            // RegDst_o   = 1'bx;

            // TODO: should jal not stall due to branch delay slot?
            Stall_o    = 1;
        end

        6'b000011: begin
            // jal
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc1_o  = `ALU_SRC_PC;
            JumpImm_o  = 1;
            Link_o     = 1;
            // MemToReg_o = 1'bx;
            // RegDst_o   = 1'bx;
            RegWrite_o = 1;

            // TODO: should jal not stall due to branch delay slot?
            Stall_o    = 1;
        end

        6'b000100: begin
            // beq
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            // MemToReg_o = 1'bx;
            Beq_o      = 1;

            // branch seen: insert bubble into ID stage
            `ifndef BrPred 
                Stall_o    = 1;
            `else 
                Stall_o    = 0;
            `endif 
        end

        6'b000101: begin
            // bne
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            // MemToReg_o = 1'bx;
            Bne_o      = 1;

            // branch seen: insert bubble into ID stage
            `ifndef BrPred 
                Stall_o    = 1;
            `else 
                Stall_o    = 0;
            `endif 
        end

        6'b001000: begin
            // addi
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            RegWrite_o = 1;
        end

        6'b001100: begin
            // andi
            ALUCtl_o   = `ALU_CTL_AND;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            RegWrite_o = 1;
        end

        6'b001101: begin
            // ori
            ALUCtl_o   = `ALU_CTL_OR;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            RegWrite_o = 1;
        end

        6'b001110: begin
            // xori
            ALUCtl_o   = `ALU_CTL_XOR;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            RegWrite_o = 1;
        end

        6'b001010: begin
            // slti
            ALUCtl_o   = `ALU_CTL_SLT;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegDst_o   = `REG_DST_RT;
            RegWrite_o = 1;
        end

        6'b100011: begin
            // lw
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b1;
            MemRead_o  = 1'b1;
            RegDst_o   = `REG_DST_RT;
        end

        6'b101011: begin
            // sw
            ALUCtl_o   = `ALU_CTL_ADD;
            ALUSrc2_o  = `ALU_SRC_IMM;
            // MemToReg_o = 1'bx;
            MemWrite_o = 1'b1;
            RegDst_o   = `REG_DST_RT;
        end
    endcase
end

endmodule

