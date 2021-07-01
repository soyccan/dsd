
module StallControl(
    input IF_Stall_icache_i,
    input MEM_Stall_dcache_i,
    //BrPred extension
    //`ifdef BrPred
    //    input EX_WrongPredict_i,
    //`else
    input EX_BranchTaken_i,
    //`endif
    //

    input ID_Stall_hazard_i,
    input ID_Stall_ctrl_i,
    input EX_Jump_i,

    output reg FlushID_o,
    output reg FlushEX_o,
    output reg FlushMEM_o,
    output reg FlushWB_o,

    output reg WritePC_o,
    output reg WriteID_o,
    output reg WriteEX_o,
    output reg WriteMEM_o,
    output reg WriteWB_o
);

always @* begin
    FlushID_o  = 0;
    FlushEX_o  = 0;
    FlushMEM_o = 0;
    FlushWB_o  = 0;

    WritePC_o  = 1;
    WriteID_o  = 1;
    WriteEX_o  = 1;
    WriteMEM_o = 1;
    WriteWB_o  = 1;

    if (IF_Stall_icache_i || MEM_Stall_dcache_i) begin
        // memory stall: stall all stages
        WritePC_o  = 0;
        WriteID_o  = 0;
        WriteEX_o  = 0;
        WriteMEM_o = 0;
        WriteWB_o  = 0;
    end
    //BrPred extension

`ifdef BrPred
    else if (EX_WrongPredict_i) begin
        // branch taken: flush IF
        // nxt_ID_PCPlus4 = don't care
        // nxt_ID_Inst = 0; // nop
        FlushEX_o  = 1;
    end
`else

    else if (EX_BranchTaken_i) begin
        // branch taken: flush IF
        // nxt_ID_PCPlus4 = don't care
        // nxt_ID_Inst = 0; // nop
        FlushID_o  = 1;
    end
`endif

    else if (EX_Jump_i) begin
        // jump taken: flush IF
        // nxt_ID_PCPlus4 = don't care
        // nxt_ID_Inst = 0; // nop
        FlushID_o  = 1;
    end
    else if (ID_Stall_ctrl_i) begin
        // branch or jump seen: stall, insert bubble into ID stage
        // nxt_ID_PCPlus4 = don't care
        // nxt_ID_Inst = 0; // nop
        WritePC_o  = 0;
        FlushID_o  = 1;
    end
    else if (ID_Stall_hazard_i) begin
        // load-use hazard: stall, insert bubble into EX stage
        WritePC_o  = 0;
        WriteID_o  = 0;
        FlushEX_o  = 1;
    end
end

endmodule
