`include "/home/raid7_2/userb07/b07050/DSD/final_project/src/Def.v"

module HazardDetect(
    input       EX_MemRead_i,
    input [4:0] EX_Rd_i,
    // input [6:0] ID_Opcode_i,
    input [4:0] ID_Rs_i,
    input [4:0] ID_Rt_i,

    // stall IF/ID register
    output reg  Stall_o
);

always @* begin
    Stall_o = 1'b0;

    if (EX_MemRead_i && EX_Rd_i != 0
            && (EX_Rd_i == ID_Rs_i || EX_Rd_i == ID_Rt_i)) begin
        // load-use hazard: insert bubble into EX stage
        Stall_o = 1'b1;
    end
end

endmodule