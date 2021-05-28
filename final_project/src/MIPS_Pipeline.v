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

wire Stall_hazard;
wire Stall_dcache;

wire rst;

wire [31:0] IF_PC;
wire [31:0] IF_PCNext;
wire [31:0] IF_Inst;


wire ID_NoOp;
wire ID_PCWrite;
wire [31:0] ID_BranchTarget;
wire ID_Branch;
wire ID_RegWrite;
wire ID_MemToReg;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_ALUSrc;
wire [1:0] ID_ALUOp;

reg [31:0] ID_Inst;
reg [31:0] ID_PC;
wire [6:0] ID_Opcode;
wire [9:0] ID_Funct;
wire [4:0] ID_Rd;
wire [4:0] ID_Rs1;
wire [4:0] ID_Rs2;
wire [31:0] ID_Rs1Data;
wire [31:0] ID_Rs2Data;
wire [31:0] ID_Imm;



reg EX_RegWrite;
reg EX_MemToReg;
reg EX_MemRead;
reg EX_MemWrite;
reg EX_ALUSrc;
reg [1:0] EX_ALUOp;

wire [1:0] Forward_A;
wire [1:0] Forward_B;

reg [9:0] EX_Funct;
reg [4:0] EX_Rs1;
reg [4:0] EX_Rs2;
reg [4:0] EX_Rd;
reg [31:0] EX_Rs1Data;
reg [31:0] EX_Rs2Data;
reg [31:0] EX_Imm;

wire [31:0] EX_ALUOp1;
wire [31:0] EX_ALUOp2;
wire [31:0] EX_Rs2_fwd;
wire [31:0] EX_ALURes;
wire EX_ALUZero;
wire EX_ALUOverflow;
wire [3:0] EX_ALUCtl;

wire EX_Flush;
reg EX_Branch;
reg [31:0] EX_BranchTarget;
wire EX_BranchCond;  // whether branch condition holds


reg MEM_RegWrite;
reg MEM_MemToReg;
reg MEM_MemRead;
reg MEM_MemWrite;

reg [4:0] MEM_Rd;

wire [31:0] MEM_DataFromMem;
reg [31:0] MEM_ALURes;
reg [31:0] MEM_DataToMem;


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
assign IF_pc_plus_4 = {pc[31:2] + 1'b1, pc[1:0]};
// assign IF_pc_nxt = EX_Flush ? EX_branch_target : (IF_PC + 4);
assign IF_pc_nxt = BranchTaken || Jal ? alu_res_as_addr : pc_nxt_norm;

assign ICACHE_ren = 1'b1;
assign ICACHE_wen = 1'b0;
assign ICACHE_addr = IF_PC;
assign ICACHE_wdata = 32'b0;
assign Stall_icache = ICACHE_stall;
assign IF_Inst = ICACHE_rdata;

PC PC(
    .Clk_i(clk),
    .Rst_i(rst),
    .PCWrite_i(ID_PCWrite),
    .PC_i(IF_PCNext),
    .PC_o(IF_PC)
);

Instruction_Memory Instruction_Memory(
    .Addr_i(IF_PC),
    .Instr_o(IF_Inst)
);


////////////////
/// ID Stage ///
////////////////
assign ID_BranchTarget = ID_Imm + ID_PC;

assign ID_BranchTaken = ID_Branch && (rs1_data == rs2_data);

// TODO: Valid instructions start with 11
// An empty entity in instruction memory is replaced with no-op
// assign ID_Opcode = ID_Inst[1:0] == 2'b11 ? ID_Inst[6:0] : 7'h13;
assign ID_Opcode = ID_Inst[6:0];

assign ID_Funct = {ID_Inst[31:25], ID_Inst[14:12]};
assign ID_Rd = ID_Inst[11:7];
assign ID_Rs1 = ID_Inst[19:15];
assign ID_Rs2 = ID_Inst[24:20];

assign ID_RdData = ID_Jal ? ID_PCPlus4 : WB_WriteBackData;

// IF/ID Register
always @(posedge Clk_i) begin
    ID_PC   <= ID_PC;
    ID_Inst <= ID_Inst;

    if (Rst_i || EX_Flush) begin
        ID_PC   <= 32'h0;
        ID_Inst <= 32'h13; // nop
    end
    else if (!Stall_hazard && !Stall_dcache) begin
        ID_PC   <= IF_PC;
        ID_Inst <= IF_Inst;
    end
end

Control Control(
    .Opcode_i(ID_Opcode),
    .NoOp_i(ID_NoOp),
    .RegWrite_o(ID_RegWrite),
    .MemToReg_o(ID_MemToReg),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),
    .Branch_o(ID_Branch)
);

Hazard_Detection_Unit Hazard_Detection_Unit(
    .EX_MemRead_i(EX_MemRead),
    .EX_Rd_i(EX_Rd),
    .ID_Rs1_i(ID_Rs1),
    .ID_Rs2_i(ID_Rs2),
    .ID_Opcode_i(ID_Opcode),
    .NoOp_o(ID_NoOp),
    .Stall_o(Stall_hazard),
    .PCWrite_o(ID_PCWrite)
);

Forward Forward(
    .EX_Rs1_i(EX_Rs1),
    .EX_Rs2_i(EX_Rs2),
    .MEM_Rd_i(MEM_Rd),
    .WB_Rd_i(WB_Rd),
    .MEM_RegWrite_i(MEM_RegWrite),
    .WB_RegWrite_i(WB_RegWrite),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B)
);


Imm_Gen Imm_Gen(
    .Inst_i(ID_Inst),
    .Imm_o(ID_Imm)
);

Registers Registers(
    .clk_i(Clk_i),
    .RegWrite_i(WB_RegWrite),
    .RDaddr_i(WB_Rd),
    .RS1addr_i(ID_Rs1),
    .RS2addr_i(ID_Rs2),
    .RDdata_i(ID_RdData),
    .RS1data_o(ID_Rs1Data),
    .RS2data_o(ID_Rs2Data)
);



////////////////
/// EX Stage ///
////////////////
assign EX_Flush = EX_Branch && EX_BranchCond;

assign EX_BranchCond =
    EX_Funct[2:0] == `FUNCT3_EQ  ? EX_ALUZero      :
    EX_Funct[2:0] == `FUNCT3_NE  ? ~EX_ALUZero     :
    EX_Funct[2:0] == `FUNCT3_LT  ? EX_ALUOverflow  :
    EX_Funct[2:0] == `FUNCT3_GE  ? ~EX_ALUOverflow :
    EX_Funct[2:0] == `FUNCT3_LTU ? EX_ALUOverflow  :
    EX_Funct[2:0] == `FUNCT3_GEU ? ~EX_ALUOverflow : 1'b0;

// ID/EX Register
always @(posedge Clk_i) begin
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
end

ALU_Control ALU_Control(
    .ALUOp_i(EX_ALUOp),
    .Funct_i(EX_Funct),
    .ALUCtl_o(EX_ALUCtl)
);

// address is multiple of 2
assign EX_alu_res_as_addr = { EX_alu_adder_res[31:1], 1'b0 };

assign EX_ALUOp1 = EX_ALUSrc1 ? EX_pc : EX_Rs1_fwd;

assign EX_Rs1_fwd = Forward_A == `FW_REG ? EX_Rs1Data :
                    Forward_A == `FW_WB  ? WB_WriteBackData :
                    MEM_ALURes; // Forward_A == FW_MEM

assign EX_ALUOp2 = EX_ALUSrc2 ? EX_Imm : EX_Rs2_fwd;

assign EX_Rs2_fwd = Forward_B == `FW_REG ? EX_Rs2Data :
                    Forward_B == `FW_WB  ? WB_WriteBackData :
                    MEM_ALURes; // Forward_B == FW_MEM

ALU ALU(
    .ALUCtl_i(EX_ALUCtl),
    .Op1_i(EX_ALUOp1),
    .Op2_i(EX_ALUOp2),
    .Res_o(EX_ALURes),
    .Zero_o(EX_ALUZero),
    .Overflow_o(EX_ALUOverflow)
);



/////////////////
/// MEM Stage ///
/////////////////

// EX/MEM Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        MEM_RegWrite    <= 0;
        MEM_MemToReg    <= 0;
        MEM_MemRead     <= 0;
        MEM_MemWrite    <= 0;
        MEM_ALURes      <= 0;
        MEM_DataToMem   <= 0;
        MEM_Rd          <= 0;
    end
    else if (!Stall_dcache) begin
        MEM_RegWrite    <= EX_RegWrite;
        MEM_MemToReg    <= EX_MemToReg;
        MEM_MemRead     <= EX_MemRead;
        MEM_MemWrite    <= EX_MemWrite;
        MEM_ALURes      <= EX_ALURes;
        MEM_DataToMem   <= EX_Rs2_fwd;
        MEM_Rd          <= EX_Rd;
    end
end

assign DCACHE_ren = MEM_MemRead;
assign DCACHE_wen = MEM_MemWrite;
assign DCACHE_addr = MEM_ALUResAsAddr;
assign DCACHE_wdata = MEM_DataToMem;

assign Stall_dcache = DCACHE_stall;
assign MEM_DataToMemn = DCACHE_rdata;



///////////////
// WB Stage ///
///////////////

// MEM/WB Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        WB_RegWrite    <= 0;
        WB_MemToReg    <= 0;
        WB_ALURes      <= 0;
        WB_DataFromMem <= 0;
        WB_Rd          <= 0;
    end
    else if (!Stall_dcache) begin
        WB_RegWrite    <= MEM_RegWrite;
        WB_MemToReg    <= MEM_MemToReg;
        WB_ALURes      <= MEM_ALURes;
        WB_DataFromMem <= MEM_DataFromMem;
        WB_Rd          <= MEM_Rd;
    end
end

assign WB_WriteBackData = WB_MemToReg ? WB_DataFromMem : WB_ALURes;

endmodule
