//remove dirty bit and write-back state
// proc_write and proc_wdata (iutput port) can be removed
// mem_wdata (output port) can be removed
//mem_write is always 1'b0;

module cacheI(
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
    mem_wdata,
    mem_rdata,
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
    reg[1:0]   state, state_next;

   // output FF
    reg proc_stall;
    reg [31:0] proc_rdata;
    reg mem_read, mem_read_next;
    reg [27:0] mem_addr;



   //internal FF
    reg [4:0]   cache_tag[7:0];
    reg [4:0]   cache_tag_next[7:0];
    reg         cache_valid[7:0];
    reg         cache_valid_next[7:0];
    reg [31:0]  cache_mem[31:0];
    reg [31:0]  cache_mem_next[31:0];
   // reg         cache_dirty[7:0];
   // reg         cache_dirty_next[7:0];

    parameter Idle = 2'd0;
    parameter CompareTag = 2'd1;
    parameter Allocate = 2'd2;
    integer i;
//==== combinational circuit ==============================
  assign  mem_write = 1'b0;
  always@(*)begin  //FSM
     //initial state(to avoid latch)
     for (i=0;i<8;i=i+1) begin

           cache_valid_next[i]=  cache_valid[i];
           cache_tag_next[i] = cache_tag[i];
     end
     for (i=0;i<32;i=i+1) begin
           cache_mem_next[i] = cache_mem[i];

     end

     mem_read_next = mem_read;

     proc_rdata = 32'd0;
     mem_addr =28'd0;


     case(state)
         Idle:
             begin
                 if (proc_read) begin
                         state_next = CompareTag;
                         proc_stall = 1'b1;
                 end
                 else begin
                         state_next = Idle;
                         proc_stall = 1'b0;
                 end

             end
         CompareTag:
              begin
                  if ( (cache_tag[proc_addr[4:2]] == proc_addr[9:5]) && cache_valid[proc_addr[4:2]]) begin  //hit

                       proc_rdata =  cache_mem[4*proc_addr[4:2]+proc_addr[1:0]];
                       state_next = Idle;
                       proc_stall = 1'b0;
                  end
                  else begin

                         mem_read_next = 1'b1;
                         state_next = Allocate;
                         proc_stall = 1'b1;
                  end
              end

         Allocate:  // read from mem //state 3
             begin
                  if (mem_ready == 1'b1 ) begin
                           state_next = CompareTag;
                           mem_read_next = 1'b0;
                  end
                  else begin   //memory_not_ready
                           state_next = Allocate;
                           mem_read_next = 1'b1;
                  end
               cache_valid_next[proc_addr[4:2]] = 1'b1;
               cache_tag_next[proc_addr[4:2]]   =  proc_addr[9:5];

               mem_addr = proc_addr[29:2];
               cache_mem_next[4*proc_addr[4:2]]   = mem_rdata[31:0];
               cache_mem_next[4*proc_addr[4:2]+1] = mem_rdata[63:32];
               cache_mem_next[4*proc_addr[4:2]+2] = mem_rdata[95:64];
               cache_mem_next[4*proc_addr[4:2]+3] = mem_rdata[127:96];
               proc_stall = 1'b1;
             end

         default:
              begin
              state_next = Idle;
              end
    endcase
   end
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
       for(i=0;i<8;i=i+1) begin
         cache_valid[i]  <= 1'b0;


         cache_tag[i]<=1'b0;
         end

       for(i=0;i<32;i=i+1) begin
         cache_mem[i]  <= 1'b0;
         end
       state <= 1'b0;
       mem_read <= 1'b0;

    end
    else begin
       for(i=0;i<8;i=i+1) begin
         cache_valid[i]  <= cache_valid_next[i];
         cache_tag[i]  <= cache_tag_next[i];
         end
       for(i=0;i<32;i=i+1) begin
         cache_mem[i]  <= cache_mem_next[i];
         end
       state <= state_next;
       mem_read <= mem_read_next;


    end
end

endmodule