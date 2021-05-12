// DSD spring 2020
// Testbench for Direct-Mapped Cache

`timescale 1 ns/10 ps
`define CYCLE       10.0                // Modify cycle time here
`define SDFFILE    "./cache_syn.sdf"   // Modify your sdf file name

`define OUTPUT_DELAY    0.3
`define INPUT_DELAY     0.3

module tb_cache;

    parameter MEM_NUM = 256;
    parameter MEM_WIDTH = 128;
    
    reg             clk;
    reg             proc_reset;
    reg             proc_read;
    reg             proc_write;
    reg     [29:0]  proc_addr;
    reg     [31:0]  proc_wdata;
    wire    [31:0]  proc_rdata;
    wire            proc_stall;

    wire                    mem_ready;
    wire                    mem_read;
    wire                    mem_write;
    wire    [27:0]          mem_addr;
    wire    [MEM_WIDTH-1:0] mem_wdata;
    wire    [MEM_WIDTH-1:0] mem_rdata;

    integer i, k, error, h, x, y;
    
    memory u_mem (
        .clk        (clk)       ,
        .mem_read   (mem_read)  ,
        .mem_write  (mem_write) ,
        .mem_addr   (mem_addr)  ,
        .mem_wdata  (mem_wdata) ,
        .mem_rdata  (mem_rdata) ,
        .mem_ready  (mem_ready)
    );

    cache u_cache(
        .clk        (clk)       ,
        .proc_reset (proc_reset),
        .proc_read  (proc_read) ,
        .proc_write (proc_write),
        .proc_addr  (proc_addr) ,
        .proc_rdata (proc_rdata),
        .proc_wdata (proc_wdata),
        .proc_stall (proc_stall),
        .mem_read   (mem_read)  ,
        .mem_write  (mem_write) ,
        .mem_addr   (mem_addr)  ,
        .mem_wdata  (mem_wdata) ,
        .mem_rdata  (mem_rdata) ,
        .mem_ready  (mem_ready)
    );

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, u_cache);
    `endif

    // waveform dump
    initial begin
        // $dumpfile("cache.vcd");
        // $dumpvars;
        $fsdbDumpfile( "cache.fsdb" );
        $fsdbDumpvars(0,tb_cache, "+mda");
    end
    
    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 100000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
    
    // clock
    initial begin
        clk = 1'b0;
        forever #(`CYCLE * 0.5) clk = ~clk;
    end
    
    // memory initialization
    initial begin
        for( i=0; i<MEM_NUM*4; i=i+1 ) begin
            u_mem.mem[i]  = i; 
        end
        $display("Memory has been initialized.\n");
    end
    
    // simulation part
    initial begin
        error = 0;
        proc_read = 1'b0;
        proc_write = 1'b0;
        proc_addr = 0;
        proc_wdata = 0;
        proc_reset = 1'b1;
        #(`CYCLE*4 );
        proc_reset = 1'b0;
        #(`CYCLE*0.5 );
        
        $display( "Processor: Read initial data from memory." );
        // read sequentially from address 0 to address 1023
        for( k=0; k<MEM_NUM*4; k=k) begin
            #(`INPUT_DELAY);
            proc_read = 1'b1;
            proc_write = 1'b0;
            proc_addr = k[29:0];
            #(`CYCLE - `OUTPUT_DELAY - `INPUT_DELAY);
            if( ~proc_stall ) begin
                if( proc_rdata !== k[31:0] ) begin
                    error = error+1;
                    $display( "    Error: proc_addr=%d, data=%d, expected=%d.", proc_addr, proc_rdata, k[31:0] );
                end
                k = k+1;
            end
            #(`OUTPUT_DELAY);
        end
        if(error==0) $display( "    Done correctly so far! ^_^\n" );
        else         $display( "    Total %d errors detected so far! >\"<\n", error[14:0] );
        
        $display( "Processor: Write new data to memory." );
        // write sequentially from address 0 to address 1023
        for( k=0; k<MEM_NUM*4; k=k ) begin
            #(`INPUT_DELAY);
            proc_read = 1'b0;
            proc_write = 1'b1;
            proc_addr = k[29:0];
            proc_wdata = k*3+1;
            #(`CYCLE - `OUTPUT_DELAY - `INPUT_DELAY);
            if( ~proc_stall ) k = k+1;
            #(`OUTPUT_DELAY);
        end
        $display( "    Finish writing!\n" );
        
        $display( "Processor: Read new data from memory." );
        // read the first 64 addresses in the order of 0, 32, 1, 33, 2, 34, ..., 30, 62, 31, 63
        // read the next 64 addresses in the order of 64, 96, 65, 97, 66, 98, ..., 94, 126, 95, 127 
        // and so on
        for (x=0; x<((MEM_NUM*4)/64); x=x+1) begin
            for (y=0; y<64; y=y) begin
                if (y[0] == 0) begin
                    k = 64*x+y/2;
                end
                else begin
                    k = 64*x+32+(y-1)/2;
                end

                #(`INPUT_DELAY);
                proc_read = 1'b1;
                proc_write = 1'b0;
                proc_addr = k[29:0];
                #(`CYCLE - `OUTPUT_DELAY - `INPUT_DELAY);
                if( ~proc_stall ) begin
                    h = k*3+1;
                    if( proc_rdata !== (h[31:0]) )begin
                        error = error + 1;
                        $display( "    Error: proc_addr=%d, data=%d, expected=%d.", proc_addr, proc_rdata, h[31:0] );
                    end
                    #(`OUTPUT_DELAY) y = y+1;
                end
                else #(`OUTPUT_DELAY);
            end
        end
        if(error==0) $display( "    Done correctly so far! ^_^ \n" );
        else         $display( "    Total %d errors detected so far! >\"< \n", error[14:0] );
        
        #(`CYCLE*4);
        if( error != 0 ) $display( "==== SORRY! There are %d errors. ====\n", error[14:0] );
        else $display( "==== CONGRATULATIONS! Pass cache read-write-read test. ====\n" );
        $display( "Finished all operations at:  ", $time, " ns" );
        
        #(`CYCLE * 10 );
        $display( "Exit testbench simulation at:", $time, " ns" );
        $display( "\n" );
        $finish;
    end

endmodule
