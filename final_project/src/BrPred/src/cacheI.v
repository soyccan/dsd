module cache_I( //cacheI _ directed-mapped _ 8block X 4words
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);

//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;

//==== wire/reg definition ================================
    reg            mem_read,mem_read_next;
    reg     [27:0] mem_addr,mem_addr_next;
 //   reg    [127:0] mem_wdata;

    reg       state_w;
    reg       state;
    reg      [7:0] valid1, valid1_next;

  //  reg      [3:0] lru,lru_next;             // 0:data1 1:data2
    reg     [29:5] tag1    [0:7], tag1_next[0:7];
    reg    [127:0] data1   [0:7], data1_next[0:7];
    wire           hit1;
    wire     [4:2] set = proc_addr[4:2];
    wire     [1:0] off = proc_addr[1:0];
    wire    [6:0] temp;
//==== combinational circuit ==============================
    localparam IDLE = 2'd0;
   // localparam WB   = 2'd3;
    localparam RD   = 2'd1;
integer i;
assign temp = (off << 5);
assign proc_stall = ~(hit1) && (proc_read);
assign proc_rdata =  data1[set][temp+:32];

assign mem_write = 1'b0;
assign hit1 = valid1[set] & (tag1[set] == proc_addr[29:5]);


//assign mem_wdata = lru[set] ? data2[set]: data1[set];


always@(*) begin
   
    case (state)
    IDLE:
        state_w = proc_stall;
    RD:
        state_w = ~mem_ready;
    default:
        state_w = IDLE;
    endcase
end


always@(*) begin
  //  mem_write_next = mem_write;
    mem_read_next =mem_read;  
    mem_addr_next =mem_addr;
    valid1_next =valid1;
  //  valid2_next =valid2;
  //  be_dirty_next = (proc_read) ? 1'b0 : (proc_write) ? 1'b1 : be_dirty;
   // dirty1_next =dirty1;
   // dirty2_next =dirty2;

for(i=0;i<8;i=i+1)begin
    tag1_next[i] =tag1[i];
  //  tag2_next[i] =tag2[i];

end
for(i=0;i<8;i=i+1)begin
  
    data1_next[i] =data1[i];
  //  data2_next[i] =data2[i];  
end

    case (state)
    IDLE: begin
          if (proc_stall) begin 
                mem_read_next = 1;
                mem_addr_next = proc_addr[29:2];
            end
          end
        RD:
            if (mem_ready) begin
                mem_read_next   = 0;
    
                    valid1_next[set] = 1;
                    tag1_next  [set] = proc_addr[29:5];
                    data1_next [set] = mem_rdata;
                 
            end
//
 
     

    endcase


end

always@(*) begin
  

end
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        mem_read   <= 0;
     //   mem_write  <= 0;
        state   <= IDLE;
        valid1  <= 0;
     //   valid2  <= 4'b0;
     //   dirty1  <= 4'b0;
     //   dirty2  <= 4'b0;
     //   lru     <= 4'b0;

    end
    else begin
        state   <= state_w;
      //  be_dirty <= be_dirty_next;
      //  lru <= lru_next;

      //  mem_write  <= mem_write_next;
        mem_addr   <= mem_addr_next;
        mem_read   <=mem_read_next;
       // dirty1 <=  dirty1_next;
       // dirty2 <=  dirty2_next ;
       // valid2 <= valid2_next;
        valid1 <= valid1_next;
     for(i=0 ;i<8;i=i+1) begin
        tag1[i] <= tag1_next[i];
      //  tag2[i] <= tag2_next[i];          
        data1[i] <=data1_next[i];
      //  data2[i] <= data2_next[i];
     end





        


    end
end
endmodule