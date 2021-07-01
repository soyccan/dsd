module MultDiv_normal(
    input clk_i,
    input [4:1] ALUCtl_i,
    input [31:0] Op1_i,
    input [31:0] Op2_i,
    input rst_i,
    output reg [31:0] Res_o,
    output reg Stall_o,
    output reg remain_o
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


reg [63:0] shreg, shreg_nxt;
reg  [31:0] multdiv_num;//, multdiv_num_nxt;//sign bit extension
reg  [32:0] alu_in1, alu_in2, alu_out;
reg alu_sgn;
reg  [ 1:0] state, state_nxt;
reg  [ 4:0] counter, counter_nxt;
reg multdiv, div, mult;
reg multdiv_start, last_cycle;//, mf_valid

//reg m_or_d, m_or_d_nxt; //m:0 d:1
reg err, err_nxt, err_sgn, err_sgn_nxt;


always @(*) begin
    multdiv_num   = Op2_i;
    multdiv_start = ALUCtl_i[4] & ALUCtl_i[3];//ALUCtl_i[4:3] == 2'b11;   //multi div

    last_cycle =    & counter;  // 5'b11111
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
    counter_nxt = counter + (multdiv | (multdiv_start & (~ALUCtl_i[1]) ) ) ;//mult(start form 1) or div(start form 0)
    //m_or_d_nxt = (multdiv_start)? ALUCtl_i[1] : m_or_d;
end

// ALU input
always @(*) begin
    /*
    case(state)
        IDLE: begin
            if (multdiv_start)  multdiv_num_nxt = Op2_i;
            else                multdiv_num_nxt = 0;
        end
        default: multdiv_num_nxt = multdiv_num; //mulu | div
    endcase*/
    div     = (state == DIV);
    alu_in1 = (div)?    {shreg[62], shreg[62:31]} : {shreg[63], shreg[63:32]};
    alu_in2 = (div)?    {multdiv_num[31], multdiv_num} : 
                        {multdiv_num[31], multdiv_num} & {33{shreg[0]}};

    alu_sgn = (div)?    shreg[63] ~^ multdiv_num[31] : last_cycle;
    alu_out = alu_in1 + (alu_in2 ^ {33{alu_sgn}}) + alu_sgn;


    //( ((state == MULT) & shreg[0]) | div )? in_1 + alu_in^{32{div}} : {1'b0, shreg[63:32]};
end


// Todo 4:  register and output
always @(*) begin

    if (ALUCtl_i[4:3] == 2'b10) begin
        if(ALUCtl_i[1]) begin
            if (err)
                Res_o = (err_sgn)? shreg[31:0]-1 : shreg[31:0]+1;
            else
                Res_o = shreg[31:0] ;

        end else 
            Res_o = (err)? 0: shreg[63:32];//MF
    end
    else    Res_o = 0;

    Stall_o         = (multdiv & (~(& counter[4:1]))) | multdiv_start;
    remain_o        = (multdiv & (~(last_cycle))) | multdiv_start;

    //multdiv_num_nxt = (multdiv_start)? Op2_i : multdiv_num;


    //
    mult = state == MULT;
    if (div) begin
        err_nxt =  last_cycle & (~& alu_out[15:0]) & shreg[63];
        err_sgn_nxt     = last_cycle & multdiv_num[63];
    end else if (mult) begin
        err_nxt = 0;
        err_sgn_nxt = 0;
    end else begin
        err_nxt = err;
        err_sgn_nxt = err_sgn;
    end
    //err_sgn_nxt     = (div & last_cycle)? shreg[63] : err_sgn;
    shreg_nxt       = shreg;
    case(state)
        MULT:begin

            shreg_nxt[30:0]  = shreg[31:1];
            shreg_nxt[63:31] = alu_out;
            //Stall_o          = ~(& counter[4:1]) | multdiv_start;
        end

        DIV :begin

            if (~last_cycle )   begin
                shreg_nxt[32:1]  = shreg[31:0];
                //Stall_o          = ~(& counter[4:1]);

                if ( ( alu_out[32] ~^ shreg_nxt[63] )  ) begin //alu_out taken
                    shreg_nxt[0]     = 1;
                    shreg_nxt[62:32] = alu_out[30:0];
                end
                else begin  //alu_out not taken
                    shreg_nxt[0]     = 0;
                    shreg_nxt[62:33] = shreg[61:32];
                end
            end
        end

        default:begin                   //IDLE
            if (multdiv_start) begin
                shreg_nxt[63:0] = (ALUCtl_i[1])?{ {31{Op1_i[31]}}, Op1_i,   (Op1_i[31] ^ Op2_i[31])  } :
                                                { ({Op2_i[31], Op2_i[31:0]} & {33{Op1_i[0]}}), Op1_i[31:1]  };
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
        //multdiv_num <= 0;
        //m_or_d  <= 0;  
        err     <= 0;
        err_sgn <= 0;
    end
    else begin
        state   <= state_nxt;
        counter <= counter_nxt;
        shreg   <= shreg_nxt;
        //multdiv_num <= multdiv_num_nxt;
        //m_or_d  <= m_or_d_nxt;  
        err     <= err_nxt;
        err_sgn <= err_sgn_nxt;
    end
end

endmodule