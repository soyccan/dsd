module cache_D( //2setx4blockx4word
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
    output  [29:0] mem_addr;
    output [127:0] mem_wdata;

//==== wire/reg definition ================================
    reg            mem_read, mem_write,mem_write_next,mem_read_next;
    reg     [29:0] mem_addr,mem_addr_next;
    reg    [127:0] mem_wdata;
    reg  [127:0]   mem_wdata_next;
    reg      [1:0] state_w;
    reg      [1:0] state;
    reg      [3:0] valid1, valid2,valid1_next,valid2_next;
    reg      [3:0] dirty1, dirty2,dirty1_next,dirty2_next;
    reg            be_dirty,be_dirty_next;
    reg      [3:0] lru,lru_next;             // 0:data1 1:data2
    reg     [29:4] tag1    [0:3], tag2    [0:3],tag1_next[0:3] , tag2_next[0:3];
    reg    [127:0] data1   [0:3], data2   [0:3], data1_next[0:3], data2_next[0:3];
    wire           hit1, hit2;
    wire     [3:2] set = proc_addr[3:2];
    wire     [1:0] off = proc_addr[1:0];
    wire    [6:0] temp;
//==== combinational circuit ==============================
    localparam IDLE = 2'd0;
    localparam WB   = 2'd3;
    localparam RD   = 2'd2;
integer i;
assign temp = (off << 5);
assign proc_stall = ~(hit1 | hit2) && (proc_read | proc_write);
assign proc_rdata = hit1
                  ? data1[set][temp+:32]
                  : data2[set][temp+:32];
assign hit1 = valid1[set] & (tag1[set] == proc_addr[29:4]);
assign hit2 = valid2[set] & (tag2[set] == proc_addr[29:4]);

//assign mem_wdata = lru[set] ? data2[set]: data1[set];



always@(*) begin
   
    case (state)
    IDLE:
        if (proc_stall)
            state_w = (~lru[set] & dirty1[set] | lru[set] & dirty2[set]) ? WB : RD;
        else
            state_w = IDLE;
    WB:
        state_w = mem_ready ? RD : WB;
    RD:
        state_w = mem_ready ? IDLE : RD;
    default:
        state_w = IDLE;
    endcase
end


always@(*) begin
    lru_next =lru;
    mem_write_next =mem_write;  
    mem_read_next =mem_read;  
    mem_addr_next =mem_addr;
   
    valid1_next =valid1;
    valid2_next =valid2;
    be_dirty_next = (proc_read) ? 1'b0 : (proc_write) ? 1'b1 : be_dirty;

    mem_wdata_next =mem_wdata;
for(i=0;i<4;i=i+1)begin
    tag1_next[i] =tag1[i];
    tag2_next[i] =tag2[i];

end
for(i=0;i<4;i=i+1)begin
      dirty1_next[i] =dirty1[i];
    dirty2_next[i] =dirty2[i];
    data1_next[i] =data1[i];
    data2_next[i] =data2[i];  
end

    case (state)
    IDLE: begin
          if ((proc_read | proc_write) & (hit1 | hit2))
                lru_next[set] = hit1;


          if (proc_read && ~(hit1 | hit2)) begin
                if (~lru[set] & dirty1[set]) begin
                    mem_write_next  = 1;
                    mem_addr_next   = {tag1[set],set,off};
                     mem_wdata_next  = data1[set];
                end else if (lru[set] & dirty2[set]) begin
                    mem_write_next  = 1;
                    mem_addr_next   = {tag2[set],set,off};
                    mem_wdata_next  = data2[set];
                end else begin
                    mem_read_next   = 1;
                    mem_addr_next   = proc_addr[29:0];
                end
            end
            else if (proc_write) begin
                if (hit1) begin
                    dirty1_next[set] = 1;
                   data1_next[set][temp+:32] = proc_wdata;
                end else if (hit2) begin
                    dirty2_next[set] = 1;
                    data2_next[set][temp+:32] = proc_wdata;
                end else if (~lru[set] & dirty1[set]) begin
                    mem_write_next  = 1;
                    mem_addr_next   = {tag1[set],set,off};
                    mem_wdata_next  = data1[set];
                end else if (lru[set] & dirty2[set]) begin
                    mem_write_next  = 1;
                    mem_addr_next   = {tag2[set],set,off};
                    mem_wdata_next  = data2[set];
                end else begin
                    mem_read_next   = 1;
                    mem_addr_next   = proc_addr[29:0];
                end
            end






            end
    WB:begin
        
          if (mem_ready) begin
                mem_read_next   = 1;
                mem_write_next  = 0;
                mem_addr_next   =  proc_addr[29:0];
          end
        end
    RD:begin
      


 if (mem_ready) begin
                mem_read_next   = 0;
                if (~lru[set]) begin
                    valid1_next[set] = 1;
                    dirty1_next[set] = be_dirty;
                    tag1_next  [set] = proc_addr[29:4];
                    data1_next [set] = mem_rdata;
                end else begin
                    valid2_next[set] = 1;
                    dirty2_next[set] = be_dirty;
                    tag2_next  [set] = proc_addr[29:4];
                    data2_next [set] = mem_rdata;
                end
            end
end

    endcase


end

always@(*) begin
  

end
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        mem_read   <= 0;
        mem_write  <= 0;
        state   <= IDLE;
        valid1  <= 4'b0;
        valid2  <= 4'b0;
        dirty1  <= 4'b0;
        dirty2  <= 4'b0;
        lru     <= 4'b0;
        mem_wdata<=0;
        mem_addr <=0;
        be_dirty <=0;
        for(i=0;i<4;i=i+1) begin
          tag1[i] <=  0;
          tag2[i] <=  0;          
          data1[i] <= 0;
          data2[i] <= 0;
        end 
    end
    else begin
        state   <= state_w;
        be_dirty <= be_dirty_next;
        lru <= lru_next;
        mem_wdata <=mem_wdata_next;
        mem_write  <= mem_write_next;
        mem_addr   <= mem_addr_next;
        mem_read   <=mem_read_next;
        dirty1 <=  dirty1_next;
        dirty2 <=  dirty2_next ;
        valid2 <= valid2_next;
        valid1 <= valid1_next;
     for(i=0 ;i<4;i=i+1) begin
        tag1[i] <= tag1_next[i];
        tag2[i] <= tag2_next[i];          
        data1[i] <=data1_next[i];
        data2[i] <= data2_next[i];
     end





        


    end
end
endmodule