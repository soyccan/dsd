`include "Const.v"

module Decompressor(
  input [31:0] PC_i,
  input [31:0] Inst_i,
  output reg [31:0] Inst_o,
  output Compressed_o
);


//// Function Definition ////
function [4:0] reg_long;
  input [2:0] reg_short;
  case (reg_short)
    3'b000: reg_long = 5'd8;
    3'b001: reg_long = 5'd9;
    3'b010: reg_long = 5'd10;
    3'b011: reg_long = 5'd11;
    3'b100: reg_long = 5'd12;
    3'b101: reg_long = 5'd13;
    3'b110: reg_long = 5'd14;
    3'b111: reg_long = 5'd15;
  endcase
endfunction


//// Wires and Registers Definition ////
wire [15:0] inst16; // can be upper or lower half of Inst_i
wire [1:0] op;
wire [2:0] funct3_i;

// Partitions of output instruction
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [2:0] funct3;
reg [6:0] funct7;
reg [31:0] imm;
reg [6:0] opcode;


//// Combinational Logic ////
assign inst16 = PC_i[1] ? Inst_i[31:16] : Inst_i[15:0];
assign op = inst16[1:0];
assign funct3_i = inst16[15:13];

// Whether inst16 is a compressed instruction
// Otherwise, Inst_i[31:0] is a normal instruction
assign Compressed_o = !(inst16[1] & inst16[0]);

always @* begin
  rd      = 5'b0;
  rs1     = 5'b0;
  rs2     = 5'b0;
  imm     = 32'b0;
  opcode  = `OPCODE_OP;
  funct3  = 3'b0;
  funct7  = 7'b0;

  case (op)
    2'b00: begin
      case (funct3_i)
        3'b000: begin
          // c.addi4spn
          opcode = `OPCODE_OP_IMM;
          funct3 = `FUNCT3_ADD;
          rd = reg_long(inst16[4:2]);
          rs1 = 5'd2;
          imm = {inst16[10:7], inst16[12:11], inst16[5], inst16[6], 2'b0};
        end

        3'b010: begin
          // c.lw
          opcode = `OPCODE_LOAD;
          funct3 = `FUNCT3_WORD;
          rd = reg_long(inst16[4:2]);
          rs1 = reg_long(inst16[9:7]);
          imm = {inst16[5], inst16[12:10], inst16[6], 2'b0};
        end

        3'b110: begin
          // c.sw
          opcode = `OPCODE_STORE;
          funct3 = `FUNCT3_WORD;
          rs1 = reg_long(inst16[9:7]);
          rs2 = reg_long(inst16[4:2]);
          imm = {inst16[5], inst16[12:10], inst16[6], 2'b0};
        end
      endcase
    end

    2'b01: begin
      case (funct3_i)
        3'b000: begin
          // c.addi
          opcode = `OPCODE_OP_IMM;
          funct3 = `FUNCT3_ADD;
          rd = inst16[11:7];
          rs1 = inst16[11:7];
          imm = $signed({inst16[12], inst16[6:2]});
        end

        3'b001: begin
          // c.jal
          opcode = `OPCODE_JAL;
          rd = 5'b1;
          imm = $signed({inst16[12], inst16[8], inst16[10:9], inst16[6],
                         inst16[7], inst16[2], inst16[11], inst16[5:3], 1'b0});
        end

        3'b010: begin
          // c.li
          opcode = `OPCODE_OP_IMM;
          funct3 = `FUNCT3_ADD;
          rd = inst16[11:7];
          rs1 = 5'b0;
          imm = $signed({inst16[12], inst16[6:2]});
        end

        3'b011: begin
          rd = inst16[11:7];
          if (rd == 5'd2) begin
            // c.addi16sp
            opcode = `OPCODE_OP_IMM;
            funct3 = `FUNCT3_ADD;
            rs1 = rd;
            imm = $signed({inst16[12], inst16[4:3], inst16[5],
                           inst16[2], inst16[6], 4'b0});
          end
          else begin
            // c.lui
            opcode = `OPCODE_LUI;
            imm = $signed({inst16[12], inst16[6:2]});
          end
        end

        3'b100: begin
          case (inst16[11:10])
            2'b00: begin
              // c.srli
              opcode = `OPCODE_OP_IMM;
              funct3 = `FUNCT3_SR;
              funct7 = `FUNCT7_LOGIC;
              rd = reg_long(inst16[9:7]);
              rs1 = reg_long(inst16[9:7]);
              imm = {inst16[12], inst16[6:2]};
            end

            2'b01: begin
              // c.srai
              opcode = `OPCODE_OP_IMM;
              funct3 = `FUNCT3_SR;
              funct7 = `FUNCT7_ARITH;
              rd = reg_long(inst16[9:7]);
              rs1 = reg_long(inst16[9:7]);
              imm = {inst16[12], inst16[6:2]};
            end

            2'b10: begin
              // c.andi
              opcode = `OPCODE_OP_IMM;
              funct3 = `FUNCT3_AND;
              rd = reg_long(inst16[9:7]);
              rs1 = reg_long(inst16[9:7]);
              imm = $signed({inst16[12], inst16[6:2]});
            end

            2'b11: begin
              case (inst16[6:5])
                2'b00: begin
                  // c.sub
                  opcode = `OPCODE_OP;
                  funct3 = `FUNCT3_ADD;
                  funct7 = `FUNCT7_SUB;
                  rd = reg_long(inst16[9:7]);
                  rs1 = reg_long(inst16[9:7]);
                  rs2 = reg_long(inst16[4:2]);
                end

                2'b01: begin
                  // c.xor
                  opcode = `OPCODE_OP;
                  funct3 = `FUNCT3_XOR;
                  rd = reg_long(inst16[9:7]);
                  rs1 = reg_long(inst16[9:7]);
                  rs2 = reg_long(inst16[4:2]);
                end

                2'b10: begin
                  // c.or
                  opcode = `OPCODE_OP;
                  funct3 = `FUNCT3_OR;
                  rd = reg_long(inst16[9:7]);
                  rs1 = reg_long(inst16[9:7]);
                  rs2 = reg_long(inst16[4:2]);
                end

                2'b11: begin
                  // c.and
                  opcode = `OPCODE_OP;
                  funct3 = `FUNCT3_AND;
                  rd = reg_long(inst16[9:7]);
                  rs1 = reg_long(inst16[9:7]);
                  rs2 = reg_long(inst16[4:2]);
                end
              endcase
            end
          endcase
        end

        3'b101: begin
          // c.j
          opcode = `OPCODE_JAL;
          rd = 5'b0;
          imm = $signed({inst16[12], inst16[8], inst16[10:9], inst16[6],
                         inst16[7], inst16[2], inst16[11], inst16[5:3], 1'b0});
        end

        3'b110: begin
          // c.beqz
          opcode = `OPCODE_BRANCH;
          funct3 = `FUNCT3_EQ;
          rs1 = reg_long(inst16[9:7]);
          rs2 = 5'b0;
          imm = $signed({inst16[12], inst16[6:5], inst16[2],
                         inst16[11:10], inst16[4:3], 1'b0});
        end

        3'b111: begin
          // c.bnez
          opcode = `OPCODE_BRANCH;
          funct3 = `FUNCT3_NE;
          rs1 = reg_long(inst16[9:7]);
          rs2 = 5'b0;
          imm = $signed({inst16[12], inst16[6:5], inst16[2],
                         inst16[11:10], inst16[4:3], 1'b0});
        end
      endcase
    end

    2'b10: begin
      case (funct3_i)
        3'b000: begin
          // c.slli
          opcode = `OPCODE_OP_IMM;
          funct3 = `FUNCT3_SL;
          rd = inst16[11:7];
          rs1 = inst16[11:7];
          imm = {inst16[12], inst16[6:2]};
        end

        3'b010: begin
          // c.lwsp
          opcode = `OPCODE_LOAD;
          funct3 = `FUNCT3_WORD;
          rd = inst16[11:7];
          rs1 = 5'd2;
          imm = {inst16[3:2], inst16[12], inst16[6:4], 2'b0};
        end

        3'b100: begin
          if (!inst16[12]) begin
            if (!inst16[6:2]) begin
              // c.jr
              opcode = `OPCODE_JALR;
              rd = 5'b0;
              rs1 = inst16[11:7];
              imm = 20'b0;
            end
            else begin
              // c.mv
              opcode = `OPCODE_OP;
              funct3 = `FUNCT3_ADD;
              rd = inst16[11:7];
              rs1 = 5'b0;
              rs2 = inst16[6:2];
            end
          end
          else begin
            if (inst16[11:7] && inst16[6:2]) begin
              // c.add
              opcode = `OPCODE_OP;
              funct3 = `FUNCT3_ADD;
              rd = inst16[11:7];
              rs1 = inst16[11:7];
              rs2 = inst16[6:2];
            end
            else if (inst16[11:7]) begin
              // c.jalr
              opcode = `OPCODE_JALR;
              rd = 5'b1;
              rs1 = inst16[11:7];
              imm = 20'b0;
            end
            else begin
              // c.ebreak
            end
          end
        end

        3'b110: begin
          // c.swsp
          opcode = `OPCODE_STORE;
          funct3 = `FUNCT3_WORD;
          rs1 = 5'd2;
          rs2 = inst16[6:2];
          imm = {inst16[8:7], inst16[12:9], 2'b0};
        end
      endcase
    end
  endcase
end

always @* begin
  if (Compressed_o) begin
    // Compressed instruction
    case (opcode)
      `OPCODE_OP_IMM, `OPCODE_LOAD, `OPCODE_JALR: begin
        // I-type
        if (funct7)
          // specially for srai
          Inst_o = { funct7, imm[4:0], rs1, funct3, rd, opcode };
        else
          Inst_o = { imm[11:0], rs1, funct3, rd, opcode };
      end

      `OPCODE_STORE: begin
        // S-type
        Inst_o = { imm[11:5], rs2, rs1, funct3, imm[4:0], opcode };
      end

      `OPCODE_BRANCH: begin
        // B-type
        Inst_o = { imm[12], imm[10:5], rs2, rs1, funct3,
                   imm[4:1], imm[11], opcode };
      end

      `OPCODE_LUI: begin
        // U-type
        Inst_o = { imm[19:0], rd, opcode };
      end

      `OPCODE_JAL: begin
        // J-type
        Inst_o = { imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode };
      end

      default: begin
        // R-type
        Inst_o = { funct7, rs2, rs1, funct3, rd, opcode };
      end
    endcase
  end
  else begin
    // Uncompressed instruction
    Inst_o = Inst_i;
  end
end

endmodule
// vim: sw=2 sts=2
