`include "Def.v"

module Hazard_Detection(
    input       EX_MemRead_i,
    input [4:0] EX_Rd_i,
    // input [6:0] ID_Opcode_i,
    input [4:0] ID_Rs1_i,
    input [4:0] ID_Rs2_i,

    // control signal is NoOp starting
    // from EX stage
    output reg  NoOp_EX_o,

    // stall IF/ID register
    output reg  Stall_hazard_o
);

always @* begin
    NoOp_EX_o = 1'b0;
    Stall_hazard_o = 1'b0;

    if (EX_MemRead_i && EX_Rd_i != 0
            && (EX_Rd_i == ID_Rs1_i || EX_Rd_i == ID_Rs2_i)) begin
        // load-use hazard
        NoOp_EX_o = 1'b1;
        Stall_hazard_o = 1'b1;
    end
end

endmodule