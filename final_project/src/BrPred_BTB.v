module BrPred_BTB(
    input               clk_i,
    input               rst_i,

    input               SC_FlushID_i,
    input               SC_FlushEX_i,

    input      [31:2]   IF_PC_i,
    input      [31:26]  IF_Inst_i,

    input               EX_BranchTaken_i,
    input      [31:2]   IF_BranchTarget_i,
    input      [31:2]   EX_PCPlus4_i,
    //input      [31:0]   ReadAddr_i,
    output reg [31:0]   ReadTarget_o,
    output reg          hit_o,
    output reg          BPfalse_o
);

localparam INDEX_BIT_num = 2;
localparam ENTRY_num     = 8;
//localparam REC_DEP       = 2;
/*
localparam NT   = 2'b01;
localparam nNT  = 2'b00;//near NT
localparam nT   = 2'b10;
localparam T    = 2'b11;
*/
integer i, j;

reg        BTBsel [0:ENTRY_num-1], BTBsel_nxt [0:ENTRY_num-1];
reg [31:0] BTBaddr[0:ENTRY_num-1], BTBaddr_nxt[0:ENTRY_num-1];


reg       br_shreg [0:1], br_shreg_nxt [0:1]; //IF->ID(0)->EX(1)
reg [2:0] br_addr_shreg[0:1], br_addr_shreg_nxt[0:1];//IF->ID(0)->EX(1)
//reg       j_shreg [0:1], j_shreg_nxt [0:1]; //IF->ID(0)->EX(1)

reg sel_false;


always @(*) begin
    //br_addr_shreg_nxt[0] = (SC_FlushID_i)? 0 : IF_PC_i[4:2];

    //br_shreg_nxt[0] = 0;
    //j_shreg_nxt[0]  = 0;

    if (IF_Inst_i[31:27] == 5'b00010)begin      //beq or bne
        hit_o        = BTBsel [ IF_PC_i[4:2] ];
        ReadTarget_o = (hit_o)? BTBaddr[ IF_PC_i[4:2] ] : 0;
        br_shreg_nxt[0] = ~SC_FlushID_i;
    /*
    end else if (IF_Inst_i[31:27] == 5'b00001)  begin           //jal j 
        hit_o        = BTBsel [ IF_PC_i[3:2] ];
        ReadTarget_o = ( hit_o )? BTBaddr[ IF_PC_i[4:2] ] : 0;
        j_shreg_nxt[0] = 1;
    */
    end else begin
        hit_o        = 0;
        ReadTarget_o = 0;
        br_shreg_nxt[0] = 0;
        br_addr_shreg_nxt[0] = (SC_FlushID_i)? 0 : IF_PC_i[4:2];

    end


    //ID stage
    br_addr_shreg_nxt[1] = br_addr_shreg[0] ;
    br_shreg_nxt[1]      = br_shreg[0]      ;
    //j_shreg_nxt[1]       = j_shreg[0]       ;

    //EX stage
    sel_false = br_shreg[1] ^ EX_BranchTaken_i; 

    BPfalse_o = ( sel_false & br_shreg_nxt[1] ) | ( (~br_shreg_nxt[1]) & EX_BranchTaken_i );

    for(i=0; i<ENTRY_num; i=i+1) begin
        BTBsel_nxt[i]  = BTBsel[i] ;
        BTBaddr_nxt[i] = BTBaddr[i];
    end
    /*
    if (sel_false) begin
        BTBsel_nxt[ br_addr_shreg[1] ] = EX_BranchTaken_i ;
    end
    */
    if( br_shreg[1] | EX_BranchTaken_i )   begin   
        BTBsel_nxt[ br_addr_shreg[1] ] = EX_BranchTaken_i ;
        BTBaddr_nxt[ br_addr_shreg[1] ] = {IF_BranchTarget_i,2'b00};
    end 
end

always @(posedge clk_i) begin
    if (rst_i) begin
        
        for(j=0; j<2; j=j+1)    begin
            br_shreg[j] <= 0;
            br_addr_shreg[j] <= 0;
        end
        for(i=0; i<ENTRY_num; i=i+1) begin
                BTBsel[i]  <= 0      ;
                BTBaddr[i] <= 0      ;
        end
    end else begin
        
        for(j=0; j<2; j=j+1)    begin
            br_addr_shreg[j] <= br_addr_shreg_nxt[j];
            br_shreg[j] <= br_shreg_nxt[j];
        end
        for(i=0; i<ENTRY_num; i=i+1) begin
            BTBsel[i]  <= BTBsel_nxt[i] ; 
            BTBaddr[i] <= BTBaddr_nxt[i];
        end
    end
end
endmodule

/*
reg [1:0] predict [0:NUM_ENTRY-1];
reg [1:0] nxt_predict [0:NUM_ENTRY-1];
//
wire [NUM_INDEX_BIT-1:0] index;
//
integer i;
//
//
assign index = Addr_i[NUM_INDEX_BIT-1:0];
//
assign Hit_o =
always @* begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        nxt_predict[i] = predict[i];
    end

    nxt_predict[index] = Target_i;
end

always @(posedge clk) begin
    for (i = 0; i < NUM_ENTRY; i = i + 1) begin
        predict[i] <= nxt_predict[i];
    end
end
*/
