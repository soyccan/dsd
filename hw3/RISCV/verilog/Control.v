`include "Const.v"

module Control(input [6:0] Opcode_i,
               input [6:0] Funct7_i,
               input [2:0] Funct3_i,
               output reg ALUSrc1_o,
               output reg ALUSrc2_o,
               output reg RegWrite_o,
               output reg MemToReg_o,
               output reg MemRead_o,
               output reg MemWrite_o,
               output reg Branch_o,
               output reg Jal_o,      // jal, jalr
               output reg [3:0] ALUCtl_o);

always @* begin
    ALUSrc1_o   = `ALU_SRC_REG;
    ALUSrc2_o   = `ALU_SRC_REG;
    RegWrite_o  = 1'b0;
    MemToReg_o  = 1'b0;
    MemRead_o   = 1'b0;
    MemWrite_o  = 1'b0;
    Branch_o    = 1'b0;
    Jal_o       = 1'b0;
    ALUCtl_o    = `ALU_CTL_ADD;

    case (Opcode_i)
        `OPCODE_OP: begin
            ALUSrc1_o  = `ALU_SRC_REG;
            ALUSrc2_o  = `ALU_SRC_REG;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b0;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o   = 1'b0;
            Jal_o      = 1'b0;

            case (Funct3_i)
                3'b000: begin
                    if (Funct7_i[5])
                        ALUCtl_o = `ALU_CTL_SUB;  // sub
                    else
                        ALUCtl_o = `ALU_CTL_ADD;  // add
                end
                3'b010: ALUCtl_o = `ALU_CTL_SLT;  // slt
                3'b110: ALUCtl_o = `ALU_CTL_OR;   // or
                3'b111: ALUCtl_o = `ALU_CTL_AND;  // and
            endcase
        end

        `OPCODE_LOAD: begin
            // lw
            ALUSrc1_o  = `ALU_SRC_REG;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b1;
            MemRead_o  = 1'b1;
            MemWrite_o = 1'b0;
            Branch_o   = 1'b0;
            Jal_o      = 1'b0;
            ALUCtl_o   = `ALU_CTL_ADD;
        end

        `OPCODE_STORE: begin
            // sw
            ALUSrc1_o  = `ALU_SRC_REG;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b0;
            MemToReg_o = 1'bx;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b1;
            Branch_o   = 1'b0;
            Jal_o      = 1'b0;
            ALUCtl_o   = `ALU_CTL_ADD;
        end

        `OPCODE_BRANCH: begin
            // beq
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b0;
            MemToReg_o = 1'bx;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o   = 1'b1;
            Jal_o      = 1'b0;
            ALUCtl_o   = `ALU_CTL_ADD;
        end

        `OPCODE_JAL: begin
            // jal
            ALUSrc1_o  = `ALU_SRC_PC;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'bx;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o   = 1'b0;
            Jal_o      = 1'b1;
            ALUCtl_o   = `ALU_CTL_ADD;
        end

        `OPCODE_JALR: begin
            // jalr
            ALUSrc1_o  = `ALU_SRC_REG;
            ALUSrc2_o  = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'bx;
            MemRead_o  = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o   = 1'b0;
            Jal_o      = 1'b1;
            ALUCtl_o   = `ALU_CTL_ADD;
        end
    endcase
end

endmodule

