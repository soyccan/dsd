`ifndef _CONST_V_
`define _CONST_V_


// ALU Control unit output "ALUctl"
`define ALU_CTL_AND  4'd0
`define ALU_CTL_OR   4'd1
`define ALU_CTL_XOR  4'd2
`define ALU_CTL_NAND 4'd3
`define ALU_CTL_NOR  4'd4

`define ALU_CTL_ADD  4'd6
`define ALU_CTL_SUB  4'd7
`define ALU_CTL_ADDU 4'd8
`define ALU_CTL_SUBU 4'd9

`define ALU_CTL_MUL  4'd10
`define ALU_CTL_DIV  4'd11

`define ALU_CTL_SLL  4'd12
`define ALU_CTL_SRL  4'd13
`define ALU_CTL_SRA  4'd14


// Control unit output "ALUOp"
`define ALU_OP_REG        2'd0  // Integer register-register computation
`define ALU_OP_IMM        2'd1  // Integer register-immediat computation
`define ALU_OP_LOAD_STORE 2'd2  // Load/Store
`define ALU_OP_BRANCH     2'd3  // Branch


// Control unit output "ALUSrc"
`define ALU_SRC_REG 1'b0
`define ALU_SRC_IMM 1'b1


// Forwarding unit output, the source of forwarding
`define FW_REG 2'b00
`define FW_WB  2'b01
`define FW_MEM 2'b10


// OPCODE follows RISC-V spec
`define OPCODE_LOAD     7'b0000011
`define OPCODE_LOAD_FP  7'b0000111
`define OPCODE_MISC_MEM 7'b0001111
`define OPCODE_OP_IMM   7'b0010011
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_OP_IMM32 7'b0011011
`define OPCODE_STORE    7'b0100011
`define OPCODE_STORE_FP 7'b0100111
`define OPCODE_AMO      7'b0101111
`define OPCODE_OP       7'b0110011
`define OPCODE_LUI      7'b0110111
`define OPCODE_OP32     7'b0111011
`define OPCODE_MADD     7'b1000011
`define OPCODE_MSUB     7'b1000111
`define OPCODE_NMSUB    7'b1001011
`define OPCODE_NMADD    7'b1001111
`define OPCODE_OP_FP    7'b1010011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JALR     7'b1100111
`define OPCODE_JAL      7'b1101111
`define OPCODE_SYSTEM   7'b1110011


// Funct3 and Funct7 follow RISC-V spec
// Funct3 for integer computation
`define FUNCT3_ADD  3'b000  // add/sub
`define FUNCT3_SL   3'b001  // shift left
`define FUNCT3_SLT  3'b010  // set less than
`define FUNCT3_SLTU 3'b011  // set less than unsigned
`define FUNCT3_XOR  3'b100
`define FUNCT3_SR   3'b101  // shift right
`define FUNCT3_OR   3'b110
`define FUNCT3_AND  3'b111

// Funct3 for load/store specifies width
`define FUNCT3_BYTE  3'b000
`define FUNCT3_HWORD 3'b001
`define FUNCT3_WORD  3'b010
`define FUNCT3_DWORD 3'b011

// Funct3 for branch
`define FUNCT3_EQ  3'b000
`define FUNCT3_NE  3'b001
`define FUNCT3_LT  3'b100
`define FUNCT3_GE  3'b101
`define FUNCT3_LTU 3'b110
`define FUNCT3_GEU 3'b111

// Funct3 for RV32M
`define FUNCT3_MUL    3'b000
`define FUNCT3_MULH   3'b001
`define FUNCT3_MULHSU 3'b010
`define FUNCT3_MULHU  3'b011
`define FUNCT3_DIV    3'b100
`define FUNCT3_DIVU   3'b101
`define FUNCT3_REM    3'b110
`define FUNCT3_REMU   3'b111

// Funct7 for shift left/right logically/arithmetically
// Used by register/immediate shift both
`define FUNCT7_LOGIC 7'0000000
`define FUNCT7_ARITH 7'0100000

// Funct7 for integer register-register computation
`define FUNCT7_ADD 7'b0000000
`define FUNCT7_SUB 7'b0100000

// Funct7 for RV32M
`define FUNCT7_MUL 7'b0000001  // mul/div


`endif  // ifndef _CONST_V_
