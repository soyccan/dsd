`include "Def.v"

module MultDiv_booth(
    input           clk_i,
    input           rst_i,
    input [`ALU_CTL_BITS-1:0] ALUCtl_i,
    input [31:0]    Op1_i,
    input [31:0]    Op2_i,
    output reg [31:0] Res_o,
    output reg      Stall_o
);

parameter IDLE = 2'b00;
parameter MULT = 2'b10;
parameter DIV  = 2'b01;
//parameter OUT  = 2'b11;   //no OUT state


reg  [63:-1] shreg, shreg_nxt;
reg  [31:0] multdiv_num, multdiv_num_nxt, pre_in2;//sign bit extension
reg  [32:0] alu_in1, alu_in2, alu_out;
reg         alu_sgn;
reg  [ 1:0] state, state_nxt;
reg  [ 4:0] counter, counter_nxt;
reg         multdiv, div;
reg         start, last_cycle;//, mf_valid

reg         booth_neg, booth_1, booth_2, in_p1, in_0, in_n1, pre_stall;
reg  [15:0] booth;



// counter
always @(*) begin
    counter_nxt = (last_cycle)? 0 : (counter + (multdiv | start)) ;
    last_cycle = (&counter[3:0]) & ((state == MULT) | ( div & counter[4])) ;  // 5'b11111
end

// Booth generate
always @(*) begin
    in_n1 = (start)? 0 : shreg[-1];
    in_0  = (start)? Op1_i[0] : shreg[0];
    in_p1 = (start)? Op1_i[1] : shreg[1];

    booth_1       = in_n1 ^ in_0;
    booth_2       = (in_n1 & in_0 & ~in_p1) |
                    (~in_n1 & ~in_0 & in_p1);
    booth_neg     = in_p1;
end

// ALU input
always @(*) begin

    pre_in2 = (start)?  Op2_i               : multdiv_num;

    alu_in1 = (div)?    {shreg[62], shreg[62:31]}   : {{2{shreg[63]}}, shreg[63:32]};
    alu_in2 = (div)?    { pre_in2[31], pre_in2}     : ( { pre_in2[31], pre_in2} & {33{booth_1} } |
                                                        { pre_in2, 1'b0} & {33{booth_2} } );
    alu_sgn = (div)?    shreg[63] ~^ pre_in2[31]    : booth_neg;

    alu_out = alu_in1 + (alu_in2 ^ {33{alu_sgn}}) + alu_sgn;
    //( ((state == MULT) & shreg[0]) | div )? in_1 + alu_in^{32{div}} : {1'b0, shreg[63:32]};
end

// output: Res_o
always @* begin
    Res_o = 0;

    if (ALUCtl_i == `ALU_CTL_MFLO) begin
        Res_o = shreg[31:0];
    end
    else if (ALUCtl_i == `ALU_CTL_MFHI) begin
        Res_o = shreg[63:32];
    end
end

// output: Stall_o
always @* begin
    pre_stall       = (div)? (~(& counter[4:1])) : (~(& counter[3:1]));
    Stall_o         = (pre_stall & multdiv) | start;
end



// next state: multdiv_num
always @* begin
    multdiv_num_nxt = (start)? Op2_i : multdiv_num;
end


// next state: state
always @* begin
    state_nxt = state;

    if (state == IDLE && start) begin
        if (ALUCtl_i == `ALU_CTL_MULT) begin
            state_nxt = MULT;
        end
        else if (ALUCtl_i == `ALU_CTL_DIV) begin
            state_nxt = DIV;
        end
    end
    else if (last_cycle) begin
        state_nxt = IDLE;
    end
end


// next state: shreg
always @* begin
    shreg_nxt = shreg;

    case (state)
        MULT: begin
            shreg_nxt[29:-1]  = shreg[31:1];
            shreg_nxt[63:30] = {alu_out[32], alu_out};
        end

        DIV: begin
            shreg_nxt[32:1]  = shreg[31:0];

            if ( ( alu_out[32] ~^ shreg_nxt[63] ) | ( ~| alu_out[31:0] ) ) begin //alu_out taken
                shreg_nxt[0]     = 1;
                shreg_nxt[62:32] = alu_out[30:0];
            end
            else begin  //alu_out not taken
                shreg_nxt[0]     = 0;
                shreg_nxt[62:33] = shreg[61:32];
            end
        end

        default: begin // IDLE
            if (start) begin
                shreg_nxt[63:-1] = (ALUCtl_i[1])? { {31{Op1_i[31]}}, Op1_i,   (Op1_i[31] ^ Op2_i[31]), 1'b0  } :
                                                    {alu_out[32], alu_out, Op1_i[31:1]};//{ alu_out, Op1_i[31:1], 1'b0 };
            end
            else begin
                shreg_nxt = shreg;          //save until data move out
            end
        end

    endcase
end



always @(posedge clk_i) begin
    if (rst_i) begin
        state       <= IDLE;
        counter     <= 0;
        shreg       <= 0;
        multdiv_num <= 0;
    end
    else begin
        state       <= state_nxt;
        counter     <= counter_nxt;
        shreg       <= shreg_nxt;
        multdiv_num <= multdiv_num_nxt;
    end
end

endmodule