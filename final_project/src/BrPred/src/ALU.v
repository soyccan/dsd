`include "/home/raid7_2/userb07/b07050/DSD/final_project/src/Def.v"

module ALU(
    input [5:0] ALUCtl_i,
    input [31:0] Op1_i,
    input [31:0] Op2_i,
    input [4:0] shamt_i,
    output reg [31:0] Res_o,
    output [31:0] AdderRes_o
);

wire [32:0] adder_op1;
wire [32:0] adder_op2;
wire sign;
wire neg;

// add(100000): 0
// sub(100010), slt(101010): 1
// otherwise: don't-care
assign neg = ALUCtl_i[1];

// signed extension & negation
assign adder_op1 = {Op1_i[31], Op1_i};
assign adder_op2 = {Op2_i[31], Op2_i} ^ {33{neg}};

// `neg` will be mapped to carry_in of adder
assign {sign, AdderRes_o} = adder_op1 + adder_op2 + neg;

always @* begin
    Res_o = AdderRes_o;

    case (ALUCtl_i)
        `ALU_CTL_SLL: Res_o = Op2_i << shamt_i;
        `ALU_CTL_SRL: Res_o = Op2_i >> shamt_i;
        `ALU_CTL_SRA: Res_o = $signed(Op2_i) >>> shamt_i;
        `ALU_CTL_ADD, `ALU_CTL_SUB: Res_o = AdderRes_o;
        `ALU_CTL_AND: Res_o = Op1_i & Op2_i;
        `ALU_CTL_OR:  Res_o = Op1_i | Op2_i;
        `ALU_CTL_XOR: Res_o = Op1_i ^ Op2_i;
        `ALU_CTL_NOR: Res_o = ~(Op1_i | Op2_i);
        `ALU_CTL_SLT: Res_o = sign;
    endcase
end

endmodule
