// ==============================
// Module: CHIP_RV32IC
// Author: soyccan
// Description:
// Simple Single-Cycle RISC-V CPU in RTL
// ISA: RV32IC
// ==============================

`include "Registers.v"
`include "PC.v"
`include "Control.v"
`include "ALU_Control.v"
`include "ALU.v"
`include "Imm_Gen.v"
`include "Decompressor.v"
`include "Branch.v"


module CHIP(
    input         clk, rst_n ,

    // for mem_D
    output        mem_wen_D  ,  // mem_wen_D is high, CHIP writes data to D-mem; else, CHIP reads data from D-mem
    output [31:0] mem_addr_D ,  // the specific address to fetch/store data
    output [31:0] mem_wdata_D,  // data writing to D-mem
    input  [31:0] mem_rdata_D,  // data reading from D-mem

    // for mem_I
    output [31:0] mem_addr_I ,  // the fetching address of next instruction
    input  [31:0] mem_rdata_I   // instruction reading from I-mem
);

//////// Functions ////////
// Little endian to big endian
function [31:0] BE32;
    input [31:0] word;
    BE32 = {word[7:0],
            word[15:8],
            word[23:16],
            word[31:24]};
endfunction

// Big endian to little endian
function [31:0] LE32;
    input [31:0] word;
    LE32 = BE32(word);
endfunction


//////// Parameter ////////


//////// Reg & Wire Declaration ////////

wire [31:0] inst;
wire [31:0] inst_raw;

wire rst;

wire [31:0] pc_nxt;
wire [31:0] pc_nxt_norm; // next PC in normal case (without branch)
wire [31:0] pc_plus_2;
wire [31:0] pc_plus_4;
wire [31:0] pc_plus_imm;
wire [31:0] pc;

wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] rd_data;
wire [31:0] imm_val;

wire [31:0] alu_op2;
wire [31:0] alu_res;
wire alu_zero;
wire alu_overflow;

wire [31:0] data_from_mem;
wire [31:0] data_to_mem;
wire [31:0] write_back_data;

wire ALUSrc;
wire RegWrite;
wire MemToReg;
wire MemRead;
wire MemWrite;
wire Branch;
wire PCWrite;
wire Jal;
wire Jalr;
wire LUI;
wire AUIPC;
wire Compressed;
wire BranchTaken;

wire [1:0] ALUOp;
wire [3:0] ALUCtl;


//////// Submodule Instantiation ////////

PC PC_U(
    .Clk_i(clk),
    .Rst_i(rst),
    .PCWrite_i(PCWrite),
    .PC_i(pc_nxt),
    .PC_o(pc)
);

Decompressor Decompressor_U(
    .PC_i(pc),
    .Inst_i(inst_raw),
    .Inst_o(inst),
    .Compressed_o(Compressed)
);

Control Control_U(
    .Opcode_i(inst[6:0]),
    .NoOp_i(1'b0),
    .ALUOp_o(ALUOp),
    .ALUSrc_o(ALUSrc),
    .RegWrite_o(RegWrite),
    .MemToReg_o(MemToReg),
    .MemRead_o(MemRead),
    .MemWrite_o(MemWrite),
    .Branch_o(Branch),
    .Jal_o(Jal),
    .Jalr_o(Jalr),
    .LUI_o(LUI),
    .AUIPC_o(AUIPC)
);

Branch Branch_U(
    .Branch_i(Branch),
    .ALUZero_i(alu_zero),
    .ALUOverflow_i(alu_overflow),
    .Funct3_i(inst[14:12]),
    .BranchTaken_o(BranchTaken)
);

Registers Registers_U(
    .clk_i(clk),
    .rst_i(rst),
    .RS1addr_i(inst[19:15]),
    .RS2addr_i(inst[24:20]),
    .RDaddr_i(inst[11:7]),
    .RDdata_i(rd_data),
    .RegWrite_i(RegWrite),
    .RS1data_o(rs1_data),
    .RS2data_o(rs2_data)
);

ALU_Control ALU_Control_U(
    .ALUOp_i(ALUOp),
    .Funct7_i(inst[31:25]),
    .Funct3_i(inst[14:12]),
    .ALUCtl_o(ALUCtl)
);

Imm_Gen Imm_Gen_U(
    .Inst_i(inst),
    .Imm_o(imm_val)
);

ALU ALU_U(
    .ALUCtl_i(ALUCtl),
    .Op1_i(rs1_data),
    .Op2_i(alu_op2),
    .Res_o(alu_res),
    .Zero_o(alu_zero),
    .Overflow_o(alu_overflow)
);


//////// Finite-State Machine ////////


//////// Combinational Logic ////////

assign rst = ~rst_n;

assign pc_plus_2 = pc + 3'd2;
assign pc_plus_4 = pc + 3'd4;
assign pc_plus_imm = pc + imm_val;

assign pc_nxt_norm = Compressed ? pc_plus_2 : pc_plus_4;

assign pc_nxt = BranchTaken ? pc_plus_imm :
                Jal         ? pc_plus_imm :
                Jalr        ? alu_res     :
                // LUI         ? imm_val     :
                // AUIPC       ? pc_plus_imm :
                pc_nxt_norm;

assign alu_op2 = ALUSrc ? imm_val : rs2_data;

// TODO: Following code cause never-ending simulation
// If register file supports forwarding, this causes a loop
assign rd_data = Jal || Jalr ? pc_nxt_norm : write_back_data;

assign data_to_mem = rs2_data;

assign write_back_data = MemToReg ? data_from_mem : alu_res;

assign PCWrite = 1'b1;


// Data memory
assign mem_wen_D = MemWrite;

assign mem_addr_D = alu_res;

assign mem_wdata_D = LE32(data_to_mem);

assign data_from_mem = BE32(mem_rdata_D);


// Instruction memory
assign mem_addr_I = pc;

assign inst_raw = BE32(mem_rdata_I);


//////// Sequential Logic ////////


endmodule