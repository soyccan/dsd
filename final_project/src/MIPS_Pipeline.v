`include "Def.v"

// TODO debug, to remove
// `define BrPred

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
wire Stall;

// Instruction-Fetch stage
wire [31:0]    IF_PC;
wire [31:0]    IF_PCPlus4;
wire [31:0]    IF_PCNxt;
wire [31:0]    IF_Inst;
wire [31:0]    IF_JumpImmTarget;
wire [31:0]    IF_RsData;
wire           IF_PCWrite;
wire           IF_JumpImm;
wire           IF_JumpReg;
wire [31:0]    IF_BranchTarget;
wire           IF_BranchTaken;
wire           IF_Stall_icache;
wire           IF_BPUse;
wire [31:0]    IF_BPTarget;


// Instruction-Decode stage
wire           ID_RegDst;
wire           ID_RegWrite;
wire           ID_MemToReg;
wire           ID_MemRead;
wire           ID_MemWrite;
wire           ID_ALUSrc1;
wire           ID_ALUSrc2;
wire           ID_Beq;
wire           ID_Bne;
wire           ID_JumpReg;
wire           ID_JumpImm;
wire           ID_Link;
wire [`ALU_CTL_BITS-1:0]     ID_ALUCtl;

wire           ID_Stall_ctrl;
wire           ID_Stall_hazard;
wire           ID_BPHit;
wire [31:0]    ID_BPTarget;

wire [5:0]     ID_Opcode;
wire [5:0]     ID_Funct;
wire [4:0]     ID_Rd;
wire [4:0]     ID_Rs;
wire [4:0]     ID_Rt;
wire [31:0]    ID_RsData;
wire [31:0]    ID_RtData;
wire [31:0]    ID_Imm;

// IF/ID pipeline register
reg [31:0]     ID_Inst;
reg [31:0]     ID_PCPlus4;
reg [31:0]     nxt_ID_Inst;
reg [31:0]     nxt_ID_PCPlus4;


// Execution stage
wire [1:0]     EX_Forward_A;
wire [1:0]     EX_Forward_B;
wire [31:0]    EX_ALUOp1;
wire [31:0]    EX_ALUOp2;
wire [31:0]    EX_RsFwd;
wire [31:0]    EX_RtFwd;
wire [31:0]    EX_ALURes;
wire [31:0]    EX_ALUAdderRes;
wire [4:0]     EX_Shamt;

wire           EX_Eq;
wire           EX_BranchTaken;
wire [31:0]    EX_BranchTarget;
wire           EX_WrongPredict;

// ID/EX pipeline register
reg            EX_BPHit;
reg            EX_BPTarget;
reg            EX_RegWrite;
reg            EX_MemToReg;
reg            EX_MemRead;
reg            EX_MemWrite;
reg            EX_ALUSrc1;
reg            EX_ALUSrc2;
reg            EX_Beq;
reg            EX_Bne;
reg            EX_Link;
reg            EX_JumpImm;
reg            EX_JumpReg;
reg  [`ALU_CTL_BITS-1:0]     EX_ALUCtl;
reg  [31:0]    EX_PCPlus4;
reg  [4:0]     EX_Rs;
reg  [4:0]     EX_Rt;
reg  [4:0]     EX_Rd;
reg  [31:0]    EX_RsData;
reg  [31:0]    EX_RtData;
reg  [31:0]    EX_Imm;
reg            nxt_EX_BPHit;
reg            nxt_EX_BPTarget;
reg            nxt_EX_RegWrite;
reg            nxt_EX_MemToReg;
reg            nxt_EX_MemRead;
reg            nxt_EX_MemWrite;
reg            nxt_EX_ALUSrc1;
reg            nxt_EX_ALUSrc2;
reg            nxt_EX_Beq;
reg            nxt_EX_Bne;
reg            nxt_EX_Link;
reg            nxt_EX_JumpImm;
reg            nxt_EX_JumpReg;
reg  [`ALU_CTL_BITS-1:0]     nxt_EX_ALUCtl;
reg  [31:0]    nxt_EX_PCPlus4;
reg  [4:0]     nxt_EX_Rs;
reg  [4:0]     nxt_EX_Rt;
reg  [4:0]     nxt_EX_Rd;
reg  [31:0]    nxt_EX_RsData;
reg  [31:0]    nxt_EX_RtData;
reg  [31:0]    nxt_EX_Imm;


// Memory stage
wire [31:0]    MEM_DataFromMem;
wire [31:0]    MEM_DataToMem;
wire           MEM_Stall_dcache;
wire [31:0]    MEM_DataFromALU;

// EX/MEM pipeline register
reg            MEM_RegWrite;
reg            MEM_MemToReg;
reg            MEM_MemRead;
reg            MEM_MemWrite;
reg  [31:0]    MEM_ALURes;
reg            MEM_Link;
reg  [31:0]    MEM_LinkAddr;
reg  [4:0]     MEM_Rd;
reg  [31:0]    MEM_RtData;
reg            nxt_MEM_RegWrite;
reg            nxt_MEM_MemToReg;
reg            nxt_MEM_MemRead;
reg            nxt_MEM_MemWrite;
reg  [31:0]    nxt_MEM_ALURes;
reg            nxt_MEM_Link;
reg  [31:0]    nxt_MEM_LinkAddr;
reg  [4:0]     nxt_MEM_Rd;
reg  [31:0]    nxt_MEM_RtData;


// WB stage
wire [31:0]    WB_WriteBackData;

// MEM/WB pipeline register
reg             WB_RegWrite;
reg             WB_MemToReg;
reg  [4:0]      WB_Rd;
reg  [31:0]     WB_DataFromMem;
reg  [31:0]     WB_DataFromALU;
reg             nxt_WB_RegWrite;
reg             nxt_WB_MemToReg;
reg  [4:0]      nxt_WB_Rd;
reg  [31:0]     nxt_WB_DataFromMem;
reg  [31:0]     nxt_WB_DataFromALU;


// stall control
wire SC_FlushID;
wire SC_FlushEX;
wire SC_FlushMEM;
wire SC_FlushWB;
wire SC_WritePC;
wire SC_WriteID;
wire SC_WriteEX;
wire SC_WriteMEM;
wire SC_WriteWB;



//// Combinational ////

assign rst = ~rst_n;
assign Stall = IF_Stall_icache || ID_Stall_ctrl
               || ID_Stall_hazard || MEM_Stall_dcache;


// IF Stage //

PC PC_U(
    .Clk_i(clk),
    .Rst_i(rst),
    .PCWrite_i(IF_PCWrite),
    .PC_i(IF_PCNxt),
    .PC_o(IF_PC)
);

`ifdef BrPred
BrPred BrPred_U(
    .clk               (clk                ),
    .rst               (rst                ),

    .BranchTaken_i     (EX_BranchTaken     ),
    .WriteAddr_i       (EX_PCPlus4         ),
    .WriteTarget_i     (EX_BranchTarget    ),

    .ReadAddr_i        (ID_PCPlus4         ),
    .ReadTarget_o      (ID_BPTarget        ),
    .Hit_o             (ID_BPHit           )
);
`endif

assign IF_PCPlus4 = {IF_PC[31:2] + 1'b1, IF_PC[1:0]};

assign IF_PCNxt =
    IF_JumpImm ? IF_JumpImmTarget :
    IF_JumpReg ? IF_RsData :
    IF_BranchTaken ? IF_BranchTarget :
`ifdef BrPred
    EX_WrongPredict ? EX_PCPlus4 :
    IF_BPUse ? IF_BPTarget :
`endif
    IF_PCPlus4;

assign IF_JumpImm       = EX_JumpImm;
assign IF_JumpReg       = EX_JumpReg;
assign IF_BranchTaken   = EX_BranchTaken;
assign IF_BranchTarget  = EX_BranchTarget;
assign IF_PCWrite       = SC_WritePC;
assign IF_JumpImmTarget = EX_Imm;
assign IF_RsData        = EX_RsFwd;
assign IF_BPUse         =
    ID_BPHit && (ID_Beq || ID_Bne || ID_JumpImm || ID_JumpReg);
assign IF_BPTarget      = ID_BPTarget;

// I mem
assign ICACHE_ren       = 1'b1;
assign ICACHE_wen       = 1'b0;
assign ICACHE_addr      = IF_PC[31:2];
assign ICACHE_wdata     = 32'b0;
assign IF_Stall_icache  = ICACHE_stall;
assign IF_Inst          = ICACHE_rdata;



// ID Stage //

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

HazardDetect HazardDetect_U(
    .EX_MemRead_i (EX_MemRead     ),
    .EX_Rd_i      (EX_Rd          ),
    .ID_Rs_i      (ID_Rs          ),
    .ID_Rt_i      (ID_Rt          ),

    .Stall_o      (ID_Stall_hazard)
);

RegFile RegFile_U(
    .clk_i(clk),
    .rst_i(rst),

    .RegWrite_i(WB_RegWrite),
    .RDaddr_i(WB_Rd),
    .RS1addr_i(ID_Rs),
    .RS2addr_i(ID_Rt),
    .RDdata_i(WB_WriteBackData),

    .RS1data_o(ID_RsData),
    .RS2data_o(ID_RtData)
);

assign ID_Opcode  = ID_Inst[31:26];
assign ID_Rs      = ID_Inst[25:21];
assign ID_Rt      = ID_Inst[20:16];
assign ID_Rd      = ID_JumpImm && ID_Link ? 5'd31 :
                    ID_RegDst ? ID_Inst[20:16] :
                    ID_Inst[15:11];
assign ID_Funct   = ID_Inst[5:0];

// sign extension
assign ID_Imm     = ID_JumpImm ?
    { ID_Inst[25:0], 2'b00 } :
    { {16{ID_Inst[15]}}, ID_Inst[15:0]};



// EX Stage //

ALU ALU_U(
    .ALUCtl_i           (EX_ALUCtl        ),
    .Op1_i              (EX_ALUOp1        ),
    .Op2_i              (EX_ALUOp2        ),
    .shamt_i            (EX_Shamt         ),
    .Res_o              (EX_ALURes        ),
    .AdderRes_o         (EX_ALUAdderRes   )
);

Forward Forward_U(
    .EX_Rs_i(EX_Rs),
    .EX_Rt_i(EX_Rt),
    .MEM_Rd_i(MEM_Rd),
    .WB_Rd_i(WB_Rd),
    .MEM_RegWrite_i(MEM_RegWrite),
    .WB_RegWrite_i(WB_RegWrite),

    .Forward_A_o(EX_Forward_A),
    .Forward_B_o(EX_Forward_B)
);

assign EX_Eq = EX_RsFwd == EX_RtFwd;
assign EX_BranchTaken = (EX_Beq && EX_Eq) || (EX_Bne && !EX_Eq);
assign EX_BranchTarget = EX_PCPlus4 + { EX_Imm, 2'b00 };
assign EX_WrongPredict =
    (EX_Beq || EX_Bne)
    && (
        EX_BPHit != EX_BranchTaken
        || EX_BPTarget != EX_BranchTarget
    );
assign EX_Shamt = EX_Imm[10:6];

assign EX_ALUOp1 = EX_RsFwd;

assign EX_RsFwd =
    EX_Forward_A == `FW_REG ? EX_RsData :
    EX_Forward_A == `FW_WB ? WB_WriteBackData :
    MEM_ALURes; // Forward_A == FW_MEM

assign EX_ALUOp2 =
    EX_ALUSrc2 ? EX_Imm :
    EX_RtFwd;

assign EX_RtFwd =
    EX_Forward_B == `FW_REG ? EX_RtData :
    EX_Forward_B == `FW_WB ? WB_WriteBackData :
    MEM_ALURes; // Forward_B == FW_MEM



// MEM Stage //
assign MEM_DataFromALU  = MEM_Link ? MEM_LinkAddr : MEM_ALURes;

assign MEM_DataToMem    = MEM_RtData;

// D mem
assign DCACHE_ren       = MEM_MemRead;
assign DCACHE_wen       = MEM_MemWrite;
assign DCACHE_addr      = MEM_ALURes[31:2];
assign DCACHE_wdata     = MEM_DataToMem;

assign MEM_Stall_dcache = DCACHE_stall;
assign MEM_DataFromMem  = DCACHE_rdata;



// WB Stage //

assign WB_WriteBackData = WB_MemToReg ? WB_DataFromMem : WB_DataFromALU;



// stall controller
StallControl StallControl_U(
    .IF_Stall_icache_i     (IF_Stall_icache          ),
    .MEM_Stall_dcache_i    (MEM_Stall_dcache         ),
`ifdef BrPred
    .EX_WrongPredict_i     (EX_WrongPredict          ),
`else
    .EX_BranchTaken_i      (EX_BranchTaken           ),
`endif
    .ID_Stall_hazard_i     (ID_Stall_hazard          ),
    .ID_Stall_ctrl_i       (ID_Stall_ctrl            ),
    .EX_Jump_i             (EX_JumpImm || EX_JumpReg ),

    .FlushID_o             (SC_FlushID               ),
    .FlushEX_o             (SC_FlushEX               ),
    .FlushMEM_o            (SC_FlushMEM              ),
    .FlushWB_o             (SC_FlushWB               ),

    .WritePC_o             (SC_WritePC               ),
    .WriteID_o             (SC_WriteID               ),
    .WriteEX_o             (SC_WriteEX               ),
    .WriteMEM_o            (SC_WriteMEM              ),
    .WriteWB_o             (SC_WriteWB               )
);

// pipeline registers //
always @* begin
    // default: stall
    nxt_ID_PCPlus4     = ID_PCPlus4      ;
    nxt_ID_Inst        = ID_Inst         ;

    nxt_EX_BPHit       = EX_BPHit        ;
    nxt_EX_BPTarget    = EX_BPTarget     ;
    nxt_EX_RegWrite    = EX_RegWrite     ;
    nxt_EX_MemToReg    = EX_MemToReg     ;
    nxt_EX_MemRead     = EX_MemRead      ;
    nxt_EX_MemWrite    = EX_MemWrite     ;
    nxt_EX_ALUSrc1     = EX_ALUSrc1      ;
    nxt_EX_ALUSrc2     = EX_ALUSrc2      ;
    nxt_EX_Beq         = EX_Beq          ;
    nxt_EX_Bne         = EX_Bne          ;
    nxt_EX_Link        = EX_Link         ;
    nxt_EX_JumpImm     = EX_JumpImm      ;
    nxt_EX_JumpReg     = EX_JumpReg      ;
    nxt_EX_ALUCtl      = EX_ALUCtl       ;
    nxt_EX_PCPlus4     = EX_PCPlus4      ;
    nxt_EX_Rs          = EX_Rs           ;
    nxt_EX_Rt          = EX_Rt           ;
    nxt_EX_Rd          = EX_Rd           ;
    nxt_EX_RsData      = EX_RsData       ;
    nxt_EX_RtData      = EX_RtData       ;
    nxt_EX_Imm         = EX_Imm          ;

    nxt_MEM_RegWrite   = MEM_RegWrite    ;
    nxt_MEM_MemToReg   = MEM_MemToReg    ;
    nxt_MEM_MemRead    = MEM_MemRead     ;
    nxt_MEM_MemWrite   = MEM_MemWrite    ;
    nxt_MEM_ALURes     = MEM_ALURes      ;
    nxt_MEM_Link       = MEM_Link        ;
    nxt_MEM_LinkAddr   = MEM_LinkAddr    ;
    nxt_MEM_Rd         = MEM_Rd          ;
    nxt_MEM_RtData     = MEM_RtData      ;

    nxt_WB_RegWrite    = WB_RegWrite     ;
    nxt_WB_MemToReg    = WB_MemToReg     ;
    nxt_WB_Rd          = WB_Rd           ;
    nxt_WB_DataFromMem = WB_DataFromMem  ;
    nxt_WB_DataFromALU = WB_DataFromALU  ;

    if (SC_FlushID) begin
        nxt_ID_PCPlus4     = 0;
        nxt_ID_Inst        = 0;
    end
    else if (SC_WriteID) begin
        nxt_ID_PCPlus4     = IF_PCPlus4       ;
        nxt_ID_Inst        = IF_Inst          ;
    end

    if (SC_FlushEX) begin
        nxt_EX_BPHit       = 0;
        nxt_EX_BPTarget    = 0;
        nxt_EX_RegWrite    = 0;
        nxt_EX_MemToReg    = 0;
        nxt_EX_MemRead     = 0;
        nxt_EX_MemWrite    = 0;
        nxt_EX_ALUSrc1     = 0;
        nxt_EX_ALUSrc2     = 0;
        nxt_EX_Beq         = 0;
        nxt_EX_Bne         = 0;
        nxt_EX_Link        = 0;
        nxt_EX_JumpImm     = 0;
        nxt_EX_JumpReg     = 0;
        nxt_EX_ALUCtl      = 0;
        nxt_EX_PCPlus4     = 0;
        nxt_EX_Rs          = 0;
        nxt_EX_Rt          = 0;
        nxt_EX_Rd          = 0;
        nxt_EX_RsData      = 0;
        nxt_EX_RtData      = 0;
        nxt_EX_Imm         = 0;
    end
    else if (SC_WriteEX) begin
        nxt_EX_BPHit       = ID_BPHit         ;
        nxt_EX_BPTarget    = ID_BPTarget      ;
        nxt_EX_RegWrite    = ID_RegWrite      ;
        nxt_EX_MemToReg    = ID_MemToReg      ;
        nxt_EX_MemRead     = ID_MemRead       ;
        nxt_EX_MemWrite    = ID_MemWrite      ;
        nxt_EX_ALUSrc1     = ID_ALUSrc1       ;
        nxt_EX_ALUSrc2     = ID_ALUSrc2       ;
        nxt_EX_Beq         = ID_Beq           ;
        nxt_EX_Bne         = ID_Bne           ;
        nxt_EX_Link        = ID_Link          ;
        nxt_EX_JumpImm     = ID_JumpImm       ;
        nxt_EX_JumpReg     = ID_JumpReg       ;
        nxt_EX_ALUCtl      = ID_ALUCtl        ;
        nxt_EX_PCPlus4     = ID_PCPlus4       ;
        nxt_EX_Rs          = ID_Rs            ;
        nxt_EX_Rt          = ID_Rt            ;
        nxt_EX_Rd          = ID_Rd            ;
        nxt_EX_RsData      = ID_RsData        ;
        nxt_EX_RtData      = ID_RtData        ;
        nxt_EX_Imm         = ID_Imm           ;
    end

    if (SC_FlushMEM) begin
        nxt_MEM_RegWrite   = 0;
        nxt_MEM_MemToReg   = 0;
        nxt_MEM_MemRead    = 0;
        nxt_MEM_MemWrite   = 0;
        nxt_MEM_ALURes     = 0;
        nxt_MEM_Link       = 0;
        nxt_MEM_LinkAddr   = 0;
        nxt_MEM_Rd         = 0;
        nxt_MEM_RtData     = 0;
    end
    else if (SC_WriteMEM) begin
        nxt_MEM_RegWrite   = EX_RegWrite      ;
        nxt_MEM_MemToReg   = EX_MemToReg      ;
        nxt_MEM_MemRead    = EX_MemRead       ;
        nxt_MEM_MemWrite   = EX_MemWrite      ;
        nxt_MEM_ALURes     = EX_ALURes        ;
        nxt_MEM_Link       = EX_Link          ;
        nxt_MEM_LinkAddr   = EX_PCPlus4       ;
        nxt_MEM_Rd         = EX_Rd            ;
        nxt_MEM_RtData     = EX_RtData        ;
    end

    if (SC_FlushWB) begin
        nxt_WB_RegWrite    = 0;
        nxt_WB_MemToReg    = 0;
        nxt_WB_Rd          = 0;
        nxt_WB_DataFromMem = 0;
        nxt_WB_DataFromALU = 0;
    end
    else if (SC_WriteWB) begin
        nxt_WB_RegWrite    = MEM_RegWrite     ;
        nxt_WB_MemToReg    = MEM_MemToReg     ;
        nxt_WB_Rd          = MEM_Rd           ;
        nxt_WB_DataFromMem = MEM_DataFromMem  ;
        nxt_WB_DataFromALU = MEM_DataFromALU  ;
    end
end



//// Sequential Logic ////
always @(posedge clk) begin
    if (rst) begin
        ID_PCPlus4     <= 0;
        ID_Inst        <= 0;
        EX_BPHit       <= 0;
        EX_BPTarget    <= 0;
        EX_RegWrite    <= 0;
        EX_MemToReg    <= 0;
        EX_MemRead     <= 0;
        EX_MemWrite    <= 0;
        EX_ALUSrc1     <= 0;
        EX_ALUSrc2     <= 0;
        EX_Beq         <= 0;
        EX_Bne         <= 0;
        EX_Link        <= 0;
        EX_JumpImm     <= 0;
        EX_JumpReg     <= 0;
        EX_ALUCtl      <= 0;
        EX_PCPlus4     <= 0;
        EX_Rs          <= 0;
        EX_Rt          <= 0;
        EX_Rd          <= 0;
        EX_RsData      <= 0;
        EX_RtData      <= 0;
        EX_Imm         <= 0;
        MEM_RegWrite   <= 0;
        MEM_MemToReg   <= 0;
        MEM_MemRead    <= 0;
        MEM_MemWrite   <= 0;
        MEM_ALURes     <= 0;
        MEM_Link       <= 0;
        MEM_LinkAddr   <= 0;
        MEM_Rd         <= 0;
        MEM_RtData     <= 0;
        WB_RegWrite    <= 0;
        WB_MemToReg    <= 0;
        WB_Rd          <= 0;
        WB_DataFromMem <= 0;
        WB_DataFromALU <= 0;
    end
    else begin
        ID_PCPlus4     <= nxt_ID_PCPlus4      ;
        ID_Inst        <= nxt_ID_Inst         ;
        EX_BPHit       <= nxt_EX_BPHit        ;
        EX_BPTarget    <= nxt_EX_BPTarget     ;
        EX_RegWrite    <= nxt_EX_RegWrite     ;
        EX_MemToReg    <= nxt_EX_MemToReg     ;
        EX_MemRead     <= nxt_EX_MemRead      ;
        EX_MemWrite    <= nxt_EX_MemWrite     ;
        EX_ALUSrc1     <= nxt_EX_ALUSrc1      ;
        EX_ALUSrc2     <= nxt_EX_ALUSrc2      ;
        EX_Beq         <= nxt_EX_Beq          ;
        EX_Bne         <= nxt_EX_Bne          ;
        EX_Link        <= nxt_EX_Link         ;
        EX_JumpImm     <= nxt_EX_JumpImm      ;
        EX_JumpReg     <= nxt_EX_JumpReg      ;
        EX_ALUCtl      <= nxt_EX_ALUCtl       ;
        EX_PCPlus4     <= nxt_EX_PCPlus4      ;
        EX_Rs          <= nxt_EX_Rs           ;
        EX_Rt          <= nxt_EX_Rt           ;
        EX_Rd          <= nxt_EX_Rd           ;
        EX_RsData      <= nxt_EX_RsData       ;
        EX_RtData      <= nxt_EX_RtData       ;
        EX_Imm         <= nxt_EX_Imm          ;
        MEM_RegWrite   <= nxt_MEM_RegWrite    ;
        MEM_MemToReg   <= nxt_MEM_MemToReg    ;
        MEM_MemRead    <= nxt_MEM_MemRead     ;
        MEM_MemWrite   <= nxt_MEM_MemWrite    ;
        MEM_ALURes     <= nxt_MEM_ALURes      ;
        MEM_Link       <= nxt_MEM_Link        ;
        MEM_LinkAddr   <= nxt_MEM_LinkAddr    ;
        MEM_Rd         <= nxt_MEM_Rd          ;
        MEM_RtData     <= nxt_MEM_RtData      ;
        WB_RegWrite    <= nxt_WB_RegWrite     ;
        WB_MemToReg    <= nxt_WB_MemToReg     ;
        WB_Rd          <= nxt_WB_Rd           ;
        WB_DataFromMem <= nxt_WB_DataFromMem  ;
        WB_DataFromALU <= nxt_WB_DataFromALU  ;
    end
end

endmodule
