`include "Def.v"

module MIPS_Pipeline(
    // control interface
    input clk,
    input rst_n,

    // I cache interface
    output        ICACHE_ren,
    output        ICACHE_wen,
    output [29:0] ICACHE_addr,
    output [31:0] ICACHE_wdata,
    input         ICACHE_stall,
    input  [31:0] ICACHE_rdata,

    // D cache interface
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr,
    output [31:0] DCACHE_wdata,
    input         DCACHE_stall,
    input  [31:0] DCACHE_rdata
);

wire rst;

wire [31:0] IF_PC;
wire [31:0] IF_PCPlus4;
wire [31:0] IF_PCNxt;
wire [31:0] IF_Inst;
wire IF_JumpImm;
wire IF_JumpReg;
wire [31:0] IF_BranchTarget;
wire IF_BranchTaken;
wire IF_Stall_icache;


wire ID_NoOp;
wire ID_RegDst;
wire [31:0] ID_BranchTarget;
wire ID_Branch;
wire ID_RegWrite;
wire ID_MemToReg;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_ALUSrc1;
wire ID_ALUSrc2;
wire ID_Beq;
wire ID_Bne;
wire ID_JumpReg;
wire ID_JumpImm;
wire ID_Link;
wire [3:0] ID_ALUCtl;

wire ID_Stall_ctrl;
wire ID_Stall_hazard;
wire ID_NoOp_EX;

reg [31:0] ID_Inst;
reg [31:0] ID_PC;
wire [5:0] ID_Opcode;
wire [5:0] ID_Funct;
wire [4:0] ID_Rd;
wire [4:0] ID_Rs1;
wire [4:0] ID_Rs2;
wire [31:0] ID_Rs1Data;
wire [31:0] ID_Rs2Data;
wire [31:0] ID_RdData;
wire [31:0] ID_Imm;



reg EX_RegWrite;
reg EX_MemToReg;
reg EX_MemRead;
reg EX_MemWrite;
reg EX_ALUSrc1;
reg EX_ALUSrc2;

wire [1:0] EX_Forward_A;
wire [1:0] EX_Forward_B;

reg [5:0] EX_Funct;
reg [4:0] EX_Rs1;
reg [4:0] EX_Rs2;
reg [4:0] EX_Rd;
reg [31:0] EX_Rs1Data;
reg [31:0] EX_Rs2Data;
reg [31:0] EX_Imm;

wire [31:0] EX_ALUOp1;
wire [31:0] EX_ALUOp2;
wire [31:0] EX_Rs1Fwd;
wire [31:0] EX_Rs2Fwd;
wire [31:0] EX_ALURes;
wire [31:0] EX_ALUAdderRes;
wire [31:0] EX_ALUResAsAddr;
wire [3:0]  EX_ALUCtl;

wire EX_Eq;
wire EX_BranchTaken;
wire EX_Flush;

reg EX_Branch;
reg [31:0] EX_BranchTarget;


reg MEM_RegWrite;
reg MEM_MemToReg;
reg MEM_MemRead;
reg MEM_MemWrite;

reg [4:0] MEM_Rd;

wire [31:0] MEM_DataFromMem;
reg [31:0] MEM_ALURes;
reg [31:0] MEM_DataToMem;
wire MEM_Stall_dcache;


reg WB_RegWrite;
reg WB_MemToReg;

reg [4:0] WB_Rd;

wire [31:0] WB_WriteBackData;
reg [31:0] WB_DataFromMem;
reg [31:0] WB_ALURes;


/// Combinational ///
assign rst = ~rst_n;


////////////////
/// IF Stage ///
////////////////

PC PC(
    .Clk_i(clk),
    .Rst_i(rst),
    .PCWrite_i(ID_PCWrite),
    .PC_i(IF_PCNxt),
    .PC_o(IF_PC)
);

assign IF_PCPlus4 = {IF_PC[31:2] + 1'b1, IF_PC[1:0]};

// assign IF_pc_nxt = EX_Flush ? EX_branch_target : (IF_PC + 4);
assign IF_PCNxt = IF_JumpImm     ? IF_Imm :
                  IF_JumpReg     ? IF_Rs2Data :
                  IF_BranchTaken ? IF_BranchTarget :
                  IF_PCPlus4;

assign IF_JumpImm = ID_JumpImm;
assign IF_JumpReg = ID_JumpReg;
assign IF_BranchTaken = EX_BranchTaken;
assign IF_BranchTarget = EX_ALUResAsAddr;

// I mem
assign ICACHE_ren = 1'b1;
assign ICACHE_wen = 1'b0;
assign ICACHE_addr = IF_PC;
assign ICACHE_wdata = 32'b0;
assign IF_Stall_icache = ICACHE_stall;
assign IF_Inst = ICACHE_rdata;



////////////////
/// ID Stage ///
////////////////

Control Control_U(
    .Opcode_i     (ID_Opcode    ),
    .Funct_i      (ID_Funct     ),

    .RegDst_o     (ID_RegDst    ),
    .ALUSrc1_o    (ID_ALUSrc1   ),
    .ALUSrc2_o    (ID_ALUSrc2   ),
    .RegWrite_o   (ID_RegWrite  ),
    .MemToReg_o   (ID_MemToReg  ),
    .MemRead_o    (ID_MemRead   ),
    .MemWrite_o   (ID_MemWrite  ),
    .Beq_o        (ID_Beq       ),
    .Bne_o        (ID_Bne       ),
    .JumpImm_o    (ID_JumpImm   ),
    .JumpReg_o    (ID_JumpReg   ),
    .Link_o       (ID_Link      ),
    .ALUCtl_o     (ID_ALUCtl    ),
    .Stall_o      (ID_Stall_ctrl)
);

Hazard_Detection Hazard_Detection_U(
    .EX_MemRead_i   (EX_MemRead     ),
    .EX_Rd_i        (EX_Rd          ),
    .ID_Rs1_i       (ID_Rs1         ),
    .ID_Rs2_i       (ID_Rs2         ),

    .NoOp_EX_o      (ID_NoOp_EX     ),
    .Stall_hazard_o (ID_Stall_hazard)
);

RegFile RegFile_U(
    .clk_i(clk),
    .rst_i(rst),

    .RegWrite_i(WB_RegWrite),
    .RDaddr_i(WB_Rd),
    .RS1addr_i(ID_Rs1),
    .RS2addr_i(ID_Rs2),
    .RDdata_i(ID_RdData),

    .RS1data_o(ID_Rs1Data),
    .RS2data_o(ID_Rs2Data)
);

// TODO: Valid instructions start with 11
// An empty entity in instruction memory is replaced with no-op
// assign ID_Opcode = ID_Inst[1:0] == 2'b11 ? ID_Inst[6:0] : 7'h13;
assign ID_Opcode = ID_Inst[31:26];

assign ID_Funct = ID_Inst[5:0];
assign ID_Rd = ID_Link ? 5'd31 : ID_Inst[15:11];
assign ID_Rs1 = ID_Inst[25:21];
assign ID_Rs2 = ID_Inst[20:16];
assign ID_Imm = ID_JumpImm ? $signed(ID_Inst[25:0]) :
                             $signed(ID_Inst[15:0]); // sign extension

assign ID_RdData = ID_Link ? ID_PCPlus4 : WB_WriteBackData;



////////////////
/// EX Stage ///
////////////////

ALU ALU(
    .ALUCtl_i(EX_ALUCtl),
    .Op1_i(EX_ALUOp1),
    .Op2_i(EX_ALUOp2),
    .Res_o(EX_ALURes),
    .AdderRes_o(EX_ALUAdderRes)
);

Forward Forward_U(
    .EX_Rs1_i(EX_Rs1),
    .EX_Rs2_i(EX_Rs2),
    .MEM_Rd_i(MEM_Rd),
    .WB_Rd_i(WB_Rd),
    .MEM_RegWrite_i(MEM_RegWrite),
    .WB_RegWrite_i(WB_RegWrite),

    .Forward_A_o(EX_Forward_A),
    .Forward_B_o(EX_Forward_B)
);

assign EX_Eq = EX_Rs1Data == EX_Rs2Data;
assign EX_BranchTaken = (EX_Beq && EX_Eq) || (EX_Bne && !EX_Eq);
assign EX_BranchTarget = EX_ALUResAsAddr;
assign EX_Flush = EX_BranchTaken;

// address is multiple of 2
assign EX_ALUResAsAddr = { EX_ALUAdderRes[31:2], 2'b00 };

assign EX_ALUOp1 = EX_ALUSrc1 ? EX_PC : EX_Rs1Fwd;

assign EX_Rs1Fwd = Forward_A == `FW_REG ? EX_Rs1Data :
                   Forward_A == `FW_WB  ? WB_WriteBackData :
                   MEM_ALURes; // Forward_A == FW_MEM

assign EX_ALUOp2 = EX_Beq || EQ_Bne ? { EX_Imm, 2'b00 } :
                   EX_ALUSrc2       ? EX_Imm :
                   EX_Rs2Fwd;

assign EX_Rs2Fwd = Forward_B == `FW_REG ? EX_Rs2Data :
                   Forward_B == `FW_WB  ? WB_WriteBackData :
                   MEM_ALURes; // Forward_B == FW_MEM



/////////////////
/// MEM Stage ///
/////////////////

assign DCACHE_ren = MEM_MemRead;
assign DCACHE_wen = MEM_MemWrite;
assign DCACHE_addr = MEM_ALUResAsAddr;
assign DCACHE_wdata = MEM_DataToMem;

assign MEM_Stall_dcache = DCACHE_stall;
assign MEM_DataToMem = DCACHE_rdata;



///////////////
// WB Stage ///
///////////////

assign WB_WriteBackData = WB_MemToReg ? WB_DataFromMem : WB_ALURes;



//// Sequential Logic ////
always @(posedge clk) begin
    if (rst) begin
        ID_PC           <= 0;
        ID_Inst         <= 0; // nop

        EX_RegWrite     <= 0;
        EX_MemToReg     <= 0;
        EX_MemRead      <= 0;
        EX_MemWrite     <= 0;
        EX_ALUOp        <= 0;
        EX_ALUSrc       <= 0;
        EX_Rs1Data      <= 0;
        EX_Rs2Data      <= 0;
        EX_Imm          <= 0;
        EX_Funct        <= 0;
        EX_Rs1          <= 0;
        EX_Rs2          <= 0;
        EX_Rd           <= 0;
        EX_Branch       <= 0;
        EX_BranchTarget <= 0;

        MEM_RegWrite    <= 0;
        MEM_MemToReg    <= 0;
        MEM_MemRead     <= 0;
        MEM_MemWrite    <= 0;
        MEM_ALURes      <= 0;
        MEM_DataToMem   <= 0;
        MEM_Rd          <= 0;

        WB_RegWrite     <= 0;
        WB_MemToReg     <= 0;
        WB_ALURes       <= 0;
        WB_DataFromMem  <= 0;
        WB_Rd           <= 0;
    end
    else begin

    end


    if (Rst_i || EX_Flush) begin
        ID_PC   <= 32'h0;
        ID_Inst <= 32'h13; // nop
    end
    else if (!Stall_hazard && !Stall_dcache) begin
        ID_PC   <= IF_PC;
        ID_Inst <= IF_Inst;
    end

    if (Rst_i || EX_Flush) begin
        EX_RegWrite     <= 0;
        EX_MemToReg     <= 0;
        EX_MemRead      <= 0;
        EX_MemWrite     <= 0;
        EX_ALUOp        <= 0;
        EX_ALUSrc       <= 0;
        EX_Rs1Data      <= 0;
        EX_Rs2Data      <= 0;
        EX_Imm          <= 0;
        EX_Funct        <= 0;
        EX_Rs1          <= 0;
        EX_Rs2          <= 0;
        EX_Rd           <= 0;
        EX_Branch       <= 0;
        EX_BranchTarget <= 0;
    end
    else if (!Stall_dcache) begin
        EX_RegWrite     <= ID_RegWrite;
        EX_MemToReg     <= ID_MemToReg;
        EX_MemRead      <= ID_MemRead;
        EX_MemWrite     <= ID_MemWrite;
        EX_ALUOp        <= ID_ALUOp;
        EX_ALUSrc       <= ID_ALUSrc;
        EX_Rs1Data      <= ID_Rs1Data;
        EX_Rs2Data      <= ID_Rs2Data;
        EX_Imm          <= ID_Imm;
        EX_Funct        <= ID_Funct;
        EX_Rs1          <= ID_Rs1;
        EX_Rs2          <= ID_Rs2;
        EX_Rd           <= ID_Rd;
        EX_Branch       <= ID_Branch;
        EX_BranchTarget <= ID_BranchTarget;
    end

    if (Rst_i) begin
    else if (!Stall_dcache) begin
        MEM_RegWrite    <= EX_RegWrite;
        MEM_MemToReg    <= EX_MemToReg;
        MEM_MemRead     <= EX_MemRead;
        MEM_MemWrite    <= EX_MemWrite;
        MEM_ALURes      <= EX_ALURes;
        MEM_DataToMem   <= EX_Rs2_fwd;
        MEM_Rd          <= EX_Rd;
    end

    if (Rst_i) begin
    end
    else if (!Stall_dcache) begin
        WB_RegWrite    <= MEM_RegWrite;
        WB_MemToReg    <= MEM_MemToReg;
        WB_ALURes      <= MEM_ALURes;
        WB_DataFromMem <= MEM_DataFromMem;
        WB_Rd          <= MEM_Rd;
    end
end

endmodule
