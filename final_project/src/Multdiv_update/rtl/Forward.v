`include "/home/raid7_2/userb07/b07050/DSD/final_project/src/Def.v"

module Forward(
    input [4:0] EX_Rs_i,
    input [4:0] EX_Rt_i,

    input [4:0] MEM_Rd_i,
    input MEM_RegWrite_i,

    input [4:0] WB_Rd_i,
    input WB_RegWrite_i,

    output reg [1:0] Forward_A_o,
    output reg [1:0] Forward_B_o
);

always @* begin
    // Default: Forward from register file
    Forward_A_o = `FW_REG;
    Forward_B_o = `FW_REG;

    // Forward from MEM stage
    if (MEM_RegWrite_i
            && MEM_Rd_i != 0
            && MEM_Rd_i == EX_Rs_i) begin
        Forward_A_o = `FW_MEM;
    end
    if (MEM_RegWrite_i
            && MEM_Rd_i != 0
            && MEM_Rd_i == EX_Rt_i) begin
        Forward_B_o = `FW_MEM;
    end

    // Forward from WB stage, provided that not forwarding from MEM stage
    if (WB_RegWrite_i
            && WB_Rd_i != 0
            && WB_Rd_i == EX_Rs_i
            && Forward_A_o != `FW_MEM) begin
        Forward_A_o = `FW_WB;
    end
    if (WB_RegWrite_i
            && WB_Rd_i != 0
            && WB_Rd_i == EX_Rt_i
            && Forward_B_o != `FW_MEM) begin
        Forward_B_o = `FW_WB;
    end
end

endmodule