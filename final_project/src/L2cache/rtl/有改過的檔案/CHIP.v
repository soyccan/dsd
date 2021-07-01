// Top module of your design, you cannot modify this module!!
module CHIP (	clk,
				rst_n,
//----------for slow_memD------------
				mem_read_D,
				mem_write_D,
				mem_addr_D,
				mem_wdata_D,
				mem_rdata_D,
				mem_ready_D,
//----------for slow_memI------------
				mem_read_I,
				mem_write_I,
				mem_addr_I,
				mem_wdata_I,
				mem_rdata_I,
				mem_ready_I,
//----------for TestBed--------------				
				DCACHE_addr, 
				DCACHE_wdata,
				DCACHE_wen   
			);
input			clk, rst_n;
//--------------------------

output			mem_read_D;
output			mem_write_D;
output	[31:4]	mem_addr_D;
output	[127:0]	mem_wdata_D;
input	[127:0]	mem_rdata_D;
input			mem_ready_D;
//--------------------------
output			mem_read_I;
output			mem_write_I;
output	[31:4]	mem_addr_I;
output	[127:0]	mem_wdata_I;
input	[127:0]	mem_rdata_I;
input			mem_ready_I;
//----------for TestBed--------------
output	[29:0]	DCACHE_addr;
output	[31:0]	DCACHE_wdata;
output			DCACHE_wen;
//--------------------------

// wire declaration
wire        ICACHE_ren;
wire        ICACHE_wen;
wire [29:0] ICACHE_addr;
wire [31:0] ICACHE_wdata;
wire        ICACHE_stall;
wire [31:0] ICACHE_rdata;

wire        DCACHE_ren;
wire        DCACHE_wen;
wire [29:0] DCACHE_addr;
wire [31:0] DCACHE_wdata;
wire        DCACHE_stall;
wire [31:0] DCACHE_rdata;

// L2 interface added

wire L1_read_D;
wire L1_write_D;
wire	[29:0]	L1_addr_D;
wire	[127:0]	L1_wdata_D;  //dependent on  the L1 word width 
wire	[127:0]	L1_rdata_D;  //dependent on  the L1 word width 
wire	L1_ready_D;
wire	L2_stall_D;


wire	L1_read_I;
wire	L1_write_I;
wire	[29:0]	L1_addr_I;
wire	[127:0]	L1_wdata_I;   //dependent on  the L1 word width 
wire	[127:0]	L1_rdata_I;   //dependent on  the L1 word width 
wire	L1_ready_I;
wire	L2_stall_I;

assign	L1_ready_D=~L2_stall_D;

assign	L1_ready_I=~L2_stall_I;


//=========================================
	// Note that the overall design of your MIPS includes:
	// 1. pipelined MIPS processor
	// 2. data cache
	// 3. instruction cache


	MIPS_Pipeline i_MIPS(
		// control interface
		.clk            (clk)           , 
		.rst_n          (rst_n)         ,
//----------I cache interface-------		
		.ICACHE_ren     (ICACHE_ren)    ,
		.ICACHE_wen     (ICACHE_wen)    ,
		.ICACHE_addr    (ICACHE_addr)   ,
		.ICACHE_wdata   (ICACHE_wdata)  ,
		.ICACHE_stall   (ICACHE_stall)  ,
		.ICACHE_rdata   (ICACHE_rdata)  ,
//----------D cache interface-------
		.DCACHE_ren     (DCACHE_ren)    ,
		.DCACHE_wen     (DCACHE_wen)    ,
		.DCACHE_addr    (DCACHE_addr)   ,
		.DCACHE_wdata   (DCACHE_wdata)  ,
		.DCACHE_stall   (DCACHE_stall)  ,
		.DCACHE_rdata   (DCACHE_rdata)
	);
	
	cache_D D_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (DCACHE_ren)  ,
        .proc_write (DCACHE_wen)  ,
        .proc_addr  (DCACHE_addr) ,
        .proc_rdata (DCACHE_rdata),
        .proc_wdata (DCACHE_wdata),
        .proc_stall (DCACHE_stall),
        .mem_read   (L1_read_D)  ,
        .mem_write  (L1_write_D) ,
        .mem_addr   (L1_addr_D)  ,
        .mem_wdata  (L1_wdata_D) ,
        .mem_rdata  (L1_rdata_D) ,
        .mem_ready  (L1_ready_D)
	);

	cache_I I_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (ICACHE_ren)  ,
        .proc_write (ICACHE_wen)  ,
        .proc_addr  (ICACHE_addr) ,
        .proc_rdata (ICACHE_rdata),
        .proc_wdata (ICACHE_wdata),
        .proc_stall (ICACHE_stall),
        .mem_read   (L1_read_I)  ,
        .mem_write  (L1_write_I) ,
        .mem_addr   (L1_addr_I)  ,
        .mem_wdata  (L1_wdata_I) ,
        .mem_rdata  (L1_rdata_I) ,
        .mem_ready  (L1_ready_I)
	);

	L2cache_D D_cache_L2(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
		//modified from here
        .proc_read  (L1_read_D)  ,
        .proc_write (L1_write_D)  ,
        .proc_addr  (L1_addr_D) ,
        .proc_rdata (L1_rdata_D),
        .proc_wdata (L1_wdata_D),
        .proc_stall (L2_stall_D),
		//end modified
        .mem_read   (mem_read_D)  ,
        .mem_write  (mem_write_D) ,
        .mem_addr   (mem_addr_D)  ,
        .mem_wdata  (mem_wdata_D) ,
        .mem_rdata  (mem_rdata_D) ,
        .mem_ready  (mem_ready_D)
    );

	L2cache_I I_cache_L2(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
		//modified from here
        .proc_read  (L1_read_I)  ,
        .proc_write (L1_write_I)  ,
        .proc_addr  (L1_addr_I) ,
        .proc_rdata (L1_rdata_I),
        .proc_wdata (L1_wdata_I),
        .proc_stall (L2_stall_I),
		//end modified
        .mem_read   (mem_read_I)  ,
        .mem_write  (mem_write_I) ,
        .mem_addr   (mem_addr_I)  ,
        .mem_wdata  (mem_wdata_I) ,
        .mem_rdata  (mem_rdata_I) ,
        .mem_ready  (mem_ready_I)
    );
endmodule
