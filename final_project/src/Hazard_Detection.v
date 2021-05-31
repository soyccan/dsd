`include "Def.v"

module Hazard_Detection(
    input       EX_MemRead_i,
    input [4:0] EX_Rd_i,
    // input [6:0] ID_Opcode_i,
    input [4:0] ID_Rs_i,
    input [4:0] ID_Rt_i,

    // EX stage should be NoOp
    output reg  NoOp_o,

    // stall IF/ID register
    output reg  Stall_o
);

always @* begin
    NoOp_o = 1'b0;
    Stall_o = 1'b0;

    if (EX_MemRead_i && EX_Rd_i != 0
            && (EX_Rd_i == ID_Rs_i || EX_Rd_i == ID_Rt_i)) begin
        // load-use hazard
        NoOp_o = 1'b1;
        Stall_o = 1'b1;
    end
end

endmodule