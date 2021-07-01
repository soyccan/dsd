`include "Def.v"

module MultDiv_normal(
    input clk_i,
    input rst_i,
    input [`ALU_CTL_BITS-1:0] ALUCtl_i,
    input [31:0] Op1_i,
    input [31:0] Op2_i,
    output reg [31:0] Res_o,
    output reg Stall_o,
    output reg remain_o
);

parameter IDLE = 2'b00;
parameter MULT = 2'b10;
parameter DIV  = 2'b01;
// parameter OUT  = 2'b11;


reg         err, err_nxt;
reg         err_sgn, err_sgn_nxt;
reg  [63:0] shreg, shreg_nxt;
reg  [ 1:0] state, state_nxt;
reg  [ 4:0] counter;
reg  [ 4:0] counter_nxt;
reg  [32:0] alu_in1, alu_in2, alu_out;
reg         alu_sgn;
reg  [31:0] multdiv_num; // sign extension
reg         multdiv, div, mult;
reg         last_cycle;
reg         start;



always @* begin
    multdiv_num = Op2_i;

    start   = ALUCtl_i == `ALU_CTL_MULT || ALUCtl_i == `ALU_CTL_DIV;

    mult    = state == MULT;
    div     = state == DIV;
    multdiv = state == MULT || state == DIV;
end

// counter
always @* begin
    last_cycle = counter == 5'd31;
    counter_nxt = counter + multdiv;
end

// ALU
always @* begin
    alu_in1 = div ?
        {shreg[62], shreg[62:31]} :
        {shreg[63], shreg[63:32]};

    alu_in2 = div ?
        {multdiv_num[31], multdiv_num} :
        {multdiv_num[31], multdiv_num} & {33{shreg[0]}};

    alu_sgn = div ?
        shreg[63] ~^ multdiv_num[31] :
        last_cycle;

    alu_out = alu_in1 + (alu_in2 ^ {33{alu_sgn}}) + alu_sgn;
end

// output
always @* begin
    Stall_o   = (multdiv & (~(& counter[4:1]))) | (start && state==IDLE);
    remain_o  = (multdiv & (~(last_cycle))) | start;
end


// output: Res_o
always @* begin
    Res_o = 0;

    if (ALUCtl_i == `ALU_CTL_MFLO) begin
        if (err) begin
            Res_o = err_sgn ? shreg[31:0]-1 : shreg[31:0]+1;
        end
        else begin
            Res_o = shreg[31:0];
        end
    end
    else if (ALUCtl_i == `ALU_CTL_MFHI) begin
        Res_o = err ? 0 : shreg[63:32];
    end
end



// FSM: state
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


// FSM: err, err_sgn
always @* begin
    err_nxt     = err;
    err_sgn_nxt = err_sgn;

    if (div) begin
        err_nxt     = last_cycle && alu_out[15:0] != 16'hffff && shreg[63];
        err_sgn_nxt = last_cycle && multdiv_num[63];
    end
    else if (mult) begin
        err_nxt     = 0;
        err_sgn_nxt = 0;
    end
end


// FSM: shreg
always @* begin
    shreg_nxt = shreg;

    case (state)
        MULT: begin
            shreg_nxt[30:0]  = shreg[31:1];
            shreg_nxt[63:31] = alu_out;
        end

        DIV: begin
            if (~last_cycle) begin
                shreg_nxt[32:1]  = shreg[31:0];

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

        default: begin                   //IDLE
            if (start) begin
                if (ALUCtl_i == `ALU_CTL_DIV) begin
                    shreg_nxt[63:0] = {
                        {31{Op1_i[31]}},
                        Op1_i,
                        Op1_i[31] ^ Op2_i[31] };
                end
                else begin
                    shreg_nxt[63:0] = {
                        {Op2_i[31], Op2_i[31:0]} & {33{Op1_i[0]}},
                        Op1_i[31:1] };
                end
            end
            else begin
                shreg_nxt = shreg;          //save until data move out
            end
        end
    endcase
end



always @(posedge clk_i) begin
    if (rst_i) begin
        state   <= IDLE;
        counter <= 0;
        shreg   <= 0;
        err     <= 0;
        err_sgn <= 0;
    end
    else begin
        state   <= state_nxt;
        counter <= counter_nxt;
        shreg   <= shreg_nxt;
        err     <= err_nxt;
        err_sgn <= err_sgn_nxt;
    end
end

endmodule