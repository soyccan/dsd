module MultDiv_tree(
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
reg div_start, last_cycle;//, mf_valid

reg  mult_end, mult_end_nxt;
reg  [63:0]  res_nxt;
//reg m_or_d, m_or_d_nxt; //m:0 d:1
reg err, err_nxt, err_sgn, err_sgn_nxt;


always @(*) begin
    multdiv_num   = Op2_i;

    mult_end_nxt = ALUCtl_i[4:1] == 4'b1100;
    div_start = ALUCtl_i[4:1] == 4'b1101;

    last_cycle =    & counter;  // 5'b11111
    if (~(state[1] | state[0])) begin //state=2'b00
        if (div_start)
            state_nxt = DIV ;
        else
            state_nxt = IDLE;
    end
    else
        state_nxt = (last_cycle)? IDLE : state; //MULT and DIV   
end
// Todo 2: Counter
always @(*) begin
    counter_nxt = counter + div ;//mult(start form 1) or div(start form 0)
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
    alu_in1 = {shreg[62], shreg[62:31]};
    alu_in2 = {multdiv_num[31], multdiv_num} ;

    alu_sgn = shreg[63] ~^ multdiv_num[31] ;
    alu_out = alu_in1 + (alu_in2 ^ {33{alu_sgn}}) + alu_sgn;


    //( ((state == MULT) & shreg[0]) | div )? in_1 + alu_in^{32{div}} : {1'b0, shreg[63:32]};
end


// Todo 4:  register and output
always @(*) begin

    if (ALUCtl_i[4:3] == 2'b10) begin
        if(ALUCtl_i[1]) begin
            if (err)
                Res_o = shreg[31:0] + ( {{31{1'b0}}, 1'b1}^{32{err_sgn}}) + err_sgn ;
            else
                Res_o = shreg[31:0] ;

        end else 
            Res_o = (err)? 0: shreg[63:32];//MF
    end
    else    Res_o = 0;

    Stall_o         = (div & (~(& counter[4:1]))) | div_start;
    remain_o        = (div & (~(last_cycle))) | div_start;

    //multdiv_num_nxt = (multdiv_start)? Op2_i : multdiv_num;


    //
    //mult = state == MULT;
    if (div) begin
        err_nxt =  last_cycle & (~& alu_out[15:0]) & shreg[63];
        err_sgn_nxt     = last_cycle & multdiv_num[63];
    end else if (mult_end_nxt) begin
        err_nxt = 0;
        err_sgn_nxt = 0;
    end else begin
        err_nxt = err;
        err_sgn_nxt = err_sgn;
    end
    //err_sgn_nxt     = (div & last_cycle)? shreg[63] : err_sgn;
    shreg_nxt       = shreg;
    case(state)

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
            if (div_start) begin
                shreg_nxt[63:0] = { {31{Op1_i[31]}}, Op1_i,   (Op1_i[31] ^ Op2_i[31])  } ;
                                  
            end
            else begin
                shreg_nxt = (mult_end)?  res_nxt : shreg;          //save until data move out
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


integer i;
integer k, j;
reg [62:0] stg0 [0:31];
reg [31:0] alter1;
reg [30:0] alter2;
reg inv2;

//pipeline stage 0
always @(*)   begin
    alter1 = Op1_i[31:0];
    alter2 = Op2_i[30:0];
    inv2   = Op2_i[31];

    stg0[0] = { 30'b0, 1'b1, ~(alter1[0] & inv2), {31{alter1[0]}} & alter2 };
    stg0[1] = { 30'b0, ~(alter1[1] & inv2),  {31{alter1[1]}} & alter2, 1'b0};
    stg0[2] = { 29'b0, ~(alter1[2] & inv2),  {31{alter1[2]}} & alter2, 2'b0};  
    stg0[3] = { 28'b0, ~(alter1[3] & inv2),  {31{alter1[3]}} & alter2, 3'b0};       
    stg0[4] = { 27'b0, ~(alter1[4] & inv2),  {31{alter1[4]}} & alter2, 4'b0}; 
    stg0[5] = { 26'b0, ~(alter1[5] & inv2),  {31{alter1[5]}} & alter2, 5'b0}; 
    stg0[6] = { 25'b0, ~(alter1[6] & inv2),  {31{alter1[6]}} & alter2, 6'b0};
    stg0[7] = { 24'b0, ~(alter1[7] & inv2),  {31{alter1[7]}} & alter2, 7'b0}; 
    stg0[8] = { 23'b0, ~(alter1[8] & inv2),  {31{alter1[8]}} & alter2, 8'b0}; 
    stg0[9] = { 22'b0, ~(alter1[9] & inv2),  {31{alter1[9]}} & alter2, 9'b0};
    stg0[10] = { 21'b0, ~(alter1[10] & inv2),  {31{alter1[10]}} & alter2, 10'b0};
    stg0[11] = { 20'b0, ~(alter1[11] & inv2),  {31{alter1[11]}} & alter2, 11'b0};
    stg0[12] = { 19'b0, ~(alter1[12] & inv2),  {31{alter1[12]}} & alter2, 12'b0};  
    stg0[13] = { 18'b0, ~(alter1[13] & inv2),  {31{alter1[13]}} & alter2, 13'b0};       
    stg0[14] = { 17'b0, ~(alter1[14] & inv2),  {31{alter1[14]}} & alter2, 14'b0}; 
    stg0[15] = { 16'b0, ~(alter1[15] & inv2),  {31{alter1[15]}} & alter2, 15'b0}; 
    stg0[16] = { 15'b0, ~(alter1[16] & inv2),  {31{alter1[16]}} & alter2, 16'b0}; 
    stg0[17] = { 14'b0, ~(alter1[17] & inv2),  {31{alter1[17]}} & alter2, 17'b0}; 
    stg0[18] = { 13'b0, ~(alter1[18] & inv2),  {31{alter1[18]}} & alter2, 18'b0}; 
    stg0[19] = { 12'b0, ~(alter1[29] & inv2),  {31{alter1[19]}} & alter2, 19'b0}; 
    stg0[20] = { 11'b0, ~(alter1[20] & inv2),  {31{alter1[20]}} & alter2, 20'b0};
    stg0[21] = { 10'b0, ~(alter1[21] & inv2),  {31{alter1[21]}} & alter2, 21'b0};
    stg0[22] = { 9'b0, ~(alter1[22] & inv2),  {31{alter1[22]}} & alter2, 22'b0};  
    stg0[23] = { 8'b0, ~(alter1[23] & inv2),  {31{alter1[23]}} & alter2, 23'b0};       
    stg0[24] = { 7'b0, ~(alter1[24] & inv2),  {31{alter1[24]}} & alter2, 24'b0}; 
    stg0[25] = { 6'b0, ~(alter1[25] & inv2),  {31{alter1[25]}} & alter2, 25'b0}; 
    stg0[26] = { 5'b0, ~(alter1[26] & inv2),  {31{alter1[26]}} & alter2, 26'b0}; 
    stg0[27] = { 4'b0, ~(alter1[27] & inv2),  {31{alter1[27]}} & alter2, 27'b0}; 
    stg0[28] = { 3'b0, ~(alter1[28] & inv2),  {31{alter1[28]}} & alter2, 28'b0}; 
    stg0[29] = { 2'b0, ~(alter1[29] & inv2),  {31{alter1[29]}} & alter2, 29'b0}; 
    stg0[30] = { 1'b0, ~(alter1[30] & inv2),  {31{alter1[30]}} & alter2, 30'b0};
    stg0[31] = { (alter1[31] & inv2), ~({31{alter1[31]}} & alter2), 31'b0};


end

wire [63:0] stg1 [0:21];


PAR_ADDER    #(.num(63))par1_1   ( stg0[0][62:0], stg0[1][62:0], stg0[2][62:0],      stg1[0][62:0], stg1[1][63:1] );

PAR_ADDER    #(.num(63))par1_2   ( stg0[3][62:0], stg0[4][62:0], stg0[5][62:0],      stg1[2][62:0], stg1[3][63:1] );

PAR_ADDER    #(.num(63))par1_3   ( stg0[6][62:0], stg0[7][62:0], stg0[8][62:0],      stg1[4][62:0], stg1[5][63:1] );

PAR_ADDER    #(.num(63))par1_4   ( stg0[9][62:0], stg0[10][62:0], stg0[11][62:0],    stg1[6][62:0], stg1[7][63:1] );

PAR_ADDER   #(.num(63))par1_5   ( stg0[12][62:0], stg0[13][62:0], stg0[14][62:0],   stg1[8][62:0], stg1[9][63:1] );

PAR_ADDER   #(.num(63))par1_6   ( stg0[15][62:0], stg0[16][62:0], stg0[17][62:0],   stg1[10][62:0], stg1[11][63:1] );

PAR_ADDER   #(.num(63))par1_7   ( stg0[18][62:0], stg0[19][62:0], stg0[20][62:0],   stg1[12][62:0], stg1[13][63:1] );

PAR_ADDER   #(.num(63))par1_8   ( stg0[21][62:0], stg0[22][62:0], stg0[23][62:0],   stg1[14][62:0], stg1[15][63:1] );

PAR_ADDER   #(.num(63))par1_9   ( stg0[24][62:0], stg0[25][62:0], stg0[26][62:0],   stg1[16][62:0], stg1[17][63:1] );

PAR_ADDER   #(.num(63))par1_10  ( stg0[27][62:0], stg0[28][62:0], stg0[29][62:0],   stg1[18][62:0], stg1[19][63:1] );


assign stg1[1][0] = 0;
assign stg1[3][0] = 0;
assign stg1[5][0] = 0;
assign stg1[7][0] = 0;
assign stg1[9][0] = 0;
assign stg1[11][0] = 0;
assign stg1[13][0] = 0;
assign stg1[15][0] = 0;
assign stg1[17][0] = 0;
assign stg1[19][0] = 0;

assign stg1[0][63] = 0;
assign stg1[2][63] = 0;
assign stg1[4][63] = 0;
assign stg1[6][63] = 0;
assign stg1[8][63] = 0;
assign stg1[10][63] = 0;
assign stg1[12][63] = 0;
assign stg1[14][63] = 0;
assign stg1[16][63] = 0;
assign stg1[18][63] = 0;

assign stg1[20] = stg0[30];
assign stg1[21] = stg0[31];

//stage 2====================================================================================================================
wire [63:0] stg2 [0:14];

PAR_ADDER   #(.num(63))par2_1   ( stg1[0][62:0], stg1[1][62:0], stg1[2][62:0],      stg2[0][62:0], stg2[1][63:1] );

PAR_ADDER   #(.num(63))par2_2   ( stg1[3][62:0], stg1[4][62:0], stg1[5][62:0],      stg2[2][62:0], stg2[3][63:1] );

PAR_ADDER   #(.num(63))par2_3   ( stg1[6][62:0], stg1[7][62:0], stg1[8][62:0],      stg2[4][62:0], stg2[5][63:1] );

PAR_ADDER   #(.num(63))par2_4   ( stg1[9][62:0], stg1[10][62:0], stg1[11][62:0],    stg2[6][62:0], stg2[7][63:1] );

PAR_ADDER   #(.num(63))par2_5   ( stg1[12][62:0], stg1[13][62:0], stg1[14][62:0],   stg2[8][62:0], stg2[9][63:1] );

PAR_ADDER   #(.num(63))par2_6   ( stg1[15][62:0], stg1[16][62:0], stg1[17][62:0],   stg2[10][62:0], stg2[11][63:1] );

PAR_ADDER   #(.num(63))par2_7   ( stg1[18][62:0], stg1[19][62:0], stg1[20][62:0],   stg2[12][62:0], stg2[13][63:1] );


assign stg2[1][0] = 0;
assign stg2[3][0] = 0;
assign stg2[5][0] = 0;
assign stg2[7][0] = 0;
assign stg2[9][0] = 0;
assign stg2[11][0] = 0;
assign stg2[13][0] = 0;

assign stg2[0][63] = 0;
assign stg2[2][63] = 0;
assign stg2[4][63] = 0;
assign stg2[6][63] = 0;
assign stg2[8][63] = 0;
assign stg2[10][63] = 0;
assign stg2[12][63] = 0;

assign stg2[14] = stg1[21];


//stage 3====================================================================================================================
wire [63:0] stg3 [0:9];

PAR_ADDER   #(.num(63))par3_1   ( stg2[0][62:0], stg2[1][62:0], stg2[2][62:0],      stg3[0][62:0], stg3[1][63:1] );

PAR_ADDER   #(.num(63))par3_2   ( stg2[3][62:0], stg2[4][62:0], stg2[5][62:0],      stg3[2][62:0], stg3[3][63:1] );

PAR_ADDER   #(.num(63))par3_3   ( stg2[6][62:0], stg2[7][62:0], stg2[8][62:0],      stg3[4][62:0], stg3[5][63:1] );

PAR_ADDER   #(.num(63))par3_4   ( stg2[9][62:0], stg2[10][62:0], stg2[11][62:0],    stg3[6][62:0], stg3[7][63:1] );

PAR_ADDER   #(.num(63))par3_5   ( stg2[12][62:0], stg2[13][62:0], stg2[14][62:0],   stg3[8][62:0], stg3[9][63:1] );

assign stg3[1][0] = 0;
assign stg3[3][0] = 0;
assign stg3[5][0] = 0;
assign stg3[7][0] = 0;
assign stg3[9][0] = 0;

assign stg3[0][63] = 0;
assign stg3[2][63] = 0;
assign stg3[4][63] = 0;
assign stg3[6][63] = 0;
assign stg3[8][63] = 0;
//stage 4====================================================================================================================
wire [63:0] stg4 [0:6];

PAR_ADDER   #(.num(63))par4_1   ( stg3[0][62:0], stg3[1][62:0], stg3[2][62:0],      stg4[0][62:0], stg4[1][63:1] );

PAR_ADDER   #(.num(63))par4_2   ( stg3[3][62:0], stg3[4][62:0], stg3[5][62:0],      stg4[2][62:0], stg4[3][63:1] );

PAR_ADDER   #(.num(63))par4_3   ( stg3[6][62:0], stg3[7][62:0], stg3[8][62:0],      stg4[4][62:0], stg4[5][63:1] );


assign stg4[1][0] = 0;
assign stg4[3][0] = 0;
assign stg4[5][0] = 0;

assign stg4[0][63] = 0;
assign stg4[2][63] = 0;
assign stg4[4][63] = 0;

assign stg4[6] = stg3[9];


//stage 5====================================================================================================================
wire [63:0] stg5 [0:4];

PAR_ADDER   #(.num(63))par5_1   ( stg4[0][62:0], stg4[1][62:0], stg4[2][62:0],      stg5[0][62:0], stg5[1][63:1] );

PAR_ADDER   #(.num(63))par5_2   ( stg4[3][62:0], stg4[4][62:0], stg4[5][62:0],      stg5[2][62:0], stg5[3][63:1] );


assign stg5[1][0] = 0;
assign stg5[3][0] = 0;

assign stg5[0][63] = 0;
assign stg5[2][63] = 0;


assign stg5[4] = stg4[6];


//stage 6====================================================================================================================
wire [63:0] stg6 [0:3];

PAR_ADDER   #(.num(63))par6_1   ( stg5[0][62:0], stg5[1][62:0], stg5[2][62:0],      stg6[0][62:0], stg6[1][63:1] );

assign stg6[1][0] = 0;
assign stg6[0][63] = 0;

assign stg6[3] = stg5[4];
assign stg6[2] = stg5[3];
//stage 6====================================================================================================================
wire [63:0] stg7 [0:2];

PAR_ADDER   #(.num(63))par7_1   ( stg6[0][62:0], stg6[1][62:0], stg6[2][62:0],      stg7[0][62:0], stg7[1][63:1] );

assign stg7[1][0] = 0;

assign stg7[2] = stg6[3];
//stage 6====================================================================================================================
wire [63:0] stg8 [0:1];

PAR_ADDER   #(.num(63))par8_1   ( stg7[0][62:0], stg7[1][62:0], stg7[2][62:0],      stg8[0][62:0], stg8[1][63:1] );


//pipeline stage 
reg [62:0] pip0;
reg [63:1] pip1;

//reg  [63:0]  res_nxt;
//reg  mult_end, mult_end_nxt;

always @(posedge clk_i)   begin
    if (rst_i)  begin
        pip0 <= {63{1'b0}};
        pip1 <= {63{1'b0}};
        //res  <= {64{1'b0}};
        mult_end<= 0;
    end else begin
        pip0 <= stg8 [0][62:0];
        pip1 <= stg8 [1][63:1] ; 
        //res  <= res_nxt;  
        mult_end<= mult_end_nxt;    
    end
end
always @(*) begin
    res_nxt   =  {1'b1, pip0} + {pip1, 1'b0} ;
end



//
endmodule


module PAR_ADDER(
    input [62:0]  in1,
    input [62:0]  in2,
    input [62:0]  ci,
    output [62:0] out,
    output [62:0] co 
);
    parameter num = 63;
    genvar i;
    generate
        for(i=0; i < num; i=i+1) begin: BLK1
            assign {co[i], out[i]} = in1[i] + in2[i] + ci[i];
        end
    endgenerate
endmodule