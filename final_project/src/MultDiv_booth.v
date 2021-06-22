module MultDivB(
    input           clk_i,
    input [4:1]     ALUCtl_i,
    input [31:0]    Op1_i,
    input [31:0]    Op2_i,
    input           rst_i,
    output reg [31:0] Res_o,
    output reg      Stall_o
);
/*
parameter MFHI = 6'b010000;
parameter MFLO = 6'b010010;
parameter DIV  = 6'b011010;
parameter MULT = 6'b011000;
*/
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
reg         multdiv_start, last_cycle;//, mf_valid

reg         booth_neg, booth_1, booth_2, in_p1, in_0, in_n1, pre_stall;
reg  [15:0] booth;

always @(*) begin
    multdiv_start = ALUCtl_i[4] & ALUCtl_i[3];//ALUCtl_i[4:3] == 2'b11;   //multi div
    //mf_valid =     ALUCtl_i[4:3] == 2'b10;
    last_cycle =    (&counter[3:0]) & ((state == MULT) | ( div & counter[4])) ;  // 5'b11111

    if (~(state[1] | state[0])) begin //state=2'b00
        if (multdiv_start)
            state_nxt = (ALUCtl_i[1])?  DIV  : MULT;
        else
            state_nxt = IDLE;
    end
    else
        state_nxt = (last_cycle)? IDLE : state; //MULT and DIV   
end
// Todo 2: Counter
always @(*) begin
    multdiv = state[0] ^ state[1];
    counter_nxt = (last_cycle)? 0 : (counter + (multdiv | multdiv_start)) ;
end
//Booth generate
always @(*) begin
    in_n1 = (multdiv_start)? 0 : shreg[-1]; 
    in_0  = (multdiv_start)? Op1_i[0] : shreg[0];
    in_p1 = (multdiv_start)? Op1_i[1] : shreg[1];

    booth_1       = in_n1 ^ in_0;
    booth_2       = (in_n1 & in_0 & ~in_p1) | 
                    (~in_n1 & ~in_0 & in_p1);
    booth_neg     = in_p1;
end
// ALU input
always @(*) begin
    case(state)
        IDLE: begin
            if (multdiv_start)  multdiv_num_nxt = Op2_i;
            else                multdiv_num_nxt = 0;
        end

        default: multdiv_num_nxt = multdiv_num; //mulu | div
    endcase
    div     = (state == DIV);

    pre_in2 = (multdiv_start)?  Op2_i               : multdiv_num;

    alu_in1 = (div)?    {shreg[62], shreg[62:31]}   : {{2{shreg[63]}}, shreg[63:32]};
    alu_in2 = (div)?    { pre_in2[31], pre_in2}     : ( { pre_in2[31], pre_in2} & {33{booth_1} } |
                                                        { pre_in2, 1'b0} & {33{booth_2} } );
    alu_sgn = (div)?    shreg[63] ~^ pre_in2[31]    : booth_neg;

    alu_out = alu_in1 + (alu_in2 ^ {33{alu_sgn}}) + alu_sgn;
    //( ((state == MULT) & shreg[0]) | div )? in_1 + alu_in^{32{div}} : {1'b0, shreg[63:32]};
end


// Todo 4:  register and output
always @(*) begin

    if (ALUCtl_i[4] & (~ALUCtl_i[3]))   Res_o = (ALUCtl_i[1])? shreg[31:0] : shreg[63:32];//MF
    else                                Res_o = 0;

    pre_stall       = (div)? (~(& counter[4:1])) : (~(& counter[3:1]));
    Stall_o         = (pre_stall & multdiv) | multdiv_start;

    multdiv_num_nxt = (multdiv_start)? Op2_i : multdiv_num;

    shreg_nxt       = shreg;
    case(state)
        MULT:begin
            shreg_nxt[29:-1]  = shreg[31:1];
            shreg_nxt[63:30] = {alu_out[32], alu_out};
            //Stall_o          = ~(& counter[4:1]) | multdiv_start;
        end

        DIV :begin
            shreg_nxt[32:1]  = shreg[31:0];
            //Stall_o          = ~(& counter[4:1]);

            if ( ( alu_out[32] ~^ shreg_nxt[63] ) | ( ~| alu_out[31:0] ) ) begin //alu_out taken
                shreg_nxt[0]     = 1;
                shreg_nxt[62:32] = alu_out[30:0];
            end
            else begin  //alu_out not taken
                shreg_nxt[0]     = 0;
                shreg_nxt[62:33] = shreg[61:32];
            end
        end

        default:begin                   //IDLE
            /*
            if (ALUCtl_i[4:3] == 2'b10) begin
                Res_o   = (ALUCtl_i[1])? shreg[31:0] : shreg[63:32];//MF
            end
            */ 
            if (multdiv_start) begin
                shreg_nxt[63:-1] = (ALUCtl_i[1])? { {31{Op1_i[31]}}, Op1_i,   (Op1_i[31] ^ Op2_i[31]), 1'b0  } :
                                                    {alu_out[32], alu_out, Op1_i[31:1]};//{ alu_out, Op1_i[31:1], 1'b0 };
            end
            else begin
                shreg_nxt = shreg;          //save until data move out
            end
        end 
        
    endcase
end
// Todo: Sequential always block
always @(posedge clk_i ) begin
    if (rst_i) begin
        state <= IDLE;
        counter <= 0;
        shreg   <= 0;
        multdiv_num  <= 0;
    end
    else begin
        state   <= state_nxt;
        counter <= counter_nxt;
        shreg   <= shreg_nxt;
        multdiv_num  <= multdiv_num_nxt;
    end
end

endmodule