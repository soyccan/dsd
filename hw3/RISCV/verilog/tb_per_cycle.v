`timescale 1 ns/10 ps

`define CYCLE 10 // You can modify your clock frequency
`define END_CYCLE 500 // You can modify your maximum cycles

`include "memory.v"
`define DMEM_DATA "data.txt"

// set instruction memory larger if code size is large
// unit: 32-bit word
`define IMEM_SIZE 256
`define IMEM_SIZE_LOG 8

// For different condition
`ifdef RV32I
    `define IMEM_INIT "pattern.txt"

    `ifdef RTL
        `include "CHIP.v"
    `endif
    `ifdef SYN
        `include "CHIP_syn.v"
        `include "tsmc13.v"
        `define SDF
        `define SDFFILE "./CHIP_syn.sdf"
    `endif
`endif

`ifdef RV32IC
    `define IMEM_INIT "pattern.txt"

    `ifdef RTL
        `include "CHIP_RV32IC.v"
    `endif
    `ifdef SYN
        `include "CHIP_RV32IC_syn.v"
        `include "tsmc13.v"
        `define SDF
        `define SDFFILE "./CHIP_RV32IC_syn.sdf"
    `endif
`endif

module RISCV_tb;

    reg         clk, rst_n ;

    wire        mem_wen_D  ;
    wire [31:0] mem_addr_D ;
    wire [31:0] mem_wdata_D;
    wire [31:0] mem_rdata_D;

    wire [31:0] mem_addr_I ;
    wire [31:0] mem_rdata_I;


    integer i;

    integer eof;
    reg eof_find;

    integer error_num;

    integer counter;

    // Note the design is connected at testbench, include:
    // 1. CHIP (RISCV + D_cache + I_chache)
    // 2. memory for data
    // 3. memory for instruction

    // Little endian to big endian
    function [31:0] BE32;
        input [31:0] word;
        BE32 = {word[7:0],
                word[15:8],
                word[23:16],
                word[31:24]};
    endfunction

    CHIP chip0(
        clk,
        rst_n,
        // for mem_D
        mem_wen_D,
        mem_addr_D,
        mem_wdata_D,
        mem_rdata_D,
        // for mem_I
        mem_addr_I,
        mem_rdata_I);

    memory #(.word_depth(`IMEM_SIZE),
             .addr_width(`IMEM_SIZE_LOG)) mem_I(
        .clk(clk),
        .wen(1'b0),
        .a(mem_addr_I[9:2]),
        .d(32'd0),
        .q(mem_rdata_I));

    memory mem_D(
        .clk(clk),
        .wen(mem_wen_D),
        .a(mem_addr_D[6:2]),
        .d(mem_wdata_D),
        .q(mem_rdata_D));

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, chip0);
    `endif

    // Initialize the data memory
    initial begin

        $fsdbDumpfile("RISCV.fsdb");
        $fsdbDumpvars(0,RISCV_tb,"+mda");

        $display("------------------------------------------------------------\n");
        $display("START!!! Simulation Start .....\n");
        $display("------------------------------------------------------------\n");

        clk = 1;
        rst_n = 1'b1;
        #(`CYCLE*0.5) rst_n = 1'b0;
        #(`CYCLE*2.0) rst_n = 1'b1;

        counter = 0;

        for (i=0; i<`IMEM_SIZE; i=i+1) mem_D.mem[i]    = 32'h00_00_00_00; // reset data in mem_D
        $readmemh (`DMEM_DATA, mem_D.mem);                        // initialize data in mem_D
        $readmemh (`IMEM_INIT, mem_I.mem);                        // initialize data in mem_I
        eof_find = 0;
        for (i=0; i<`IMEM_SIZE; i=i+1) begin
            if (mem_I.mem[i] === 32'bx) begin
                if (eof_find == 0) begin
                    eof_find = 1;
                    eof = i;
                end
                mem_I.mem[i] = 32'h33_00_00_00;
            end
        end

        #(`CYCLE*`END_CYCLE)
        $display("============================================================\n");
        $display("Simulation time is longer than expected.");
        $display("The test result is .....FAIL :(\n");
        $display("============================================================\n");
        $finish;
    end

    always @(negedge clk) begin

        $display("Cycle = %3d", counter);
        $display("PC = 0x%8x", chip0.pc);
        $display("x0(zero) = %5d  x8(s0)  = %5d  x16(a6) = %5d  x24(s8)  = %5d", $signed(chip0.Registers_U.register[0]), $signed(chip0.Registers_U.register[8 ]), $signed(chip0.Registers_U.register[16]), $signed(chip0.Registers_U.register[24]));
        $display("x1(ra)   = %5d  x9(s1)  = %5d  x17(a7) = %5d  x25(s9)  = %5d", $signed(chip0.Registers_U.register[1]), $signed(chip0.Registers_U.register[9 ]), $signed(chip0.Registers_U.register[17]), $signed(chip0.Registers_U.register[25]));
        $display("x2(sp)   = %5d  x10(a0) = %5d  x18(s2) = %5d  x26(s10) = %5d", $signed(chip0.Registers_U.register[2]), $signed(chip0.Registers_U.register[10]), $signed(chip0.Registers_U.register[18]), $signed(chip0.Registers_U.register[26]));
        $display("x3(gp)   = %5d  x11(a1) = %5d  x19(s3) = %5d  x27(s11) = %5d", $signed(chip0.Registers_U.register[3]), $signed(chip0.Registers_U.register[11]), $signed(chip0.Registers_U.register[19]), $signed(chip0.Registers_U.register[27]));
        $display("x4(tp)   = %5d  x12(a2) = %5d  x20(s4) = %5d  x28(t3)  = %5d", $signed(chip0.Registers_U.register[4]), $signed(chip0.Registers_U.register[12]), $signed(chip0.Registers_U.register[20]), $signed(chip0.Registers_U.register[28]));
        $display("x5(t0)   = %5d  x13(a3) = %5d  x21(s5) = %5d  x29(t4)  = %5d", $signed(chip0.Registers_U.register[5]), $signed(chip0.Registers_U.register[13]), $signed(chip0.Registers_U.register[21]), $signed(chip0.Registers_U.register[29]));
        $display("x6(t1)   = %5d  x14(a4) = %5d  x22(s6) = %5d  x30(t5)  = %5d", $signed(chip0.Registers_U.register[6]), $signed(chip0.Registers_U.register[14]), $signed(chip0.Registers_U.register[22]), $signed(chip0.Registers_U.register[30]));
        $display("x7(t2)   = %5d  x15(a5) = %5d  x23(s7) = %5d  x31(t6)  = %5d", $signed(chip0.Registers_U.register[7]), $signed(chip0.Registers_U.register[15]), $signed(chip0.Registers_U.register[23]), $signed(chip0.Registers_U.register[31]));
        $display("Data Memory: 0x00 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[ 0])), $signed(BE32(mem_D.mem[ 1])), $signed(BE32(mem_D.mem[ 2])), $signed(BE32(mem_D.mem[ 3])));
        $display("Data Memory: 0x10 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[ 4])), $signed(BE32(mem_D.mem[ 5])), $signed(BE32(mem_D.mem[ 6])), $signed(BE32(mem_D.mem[ 7])));
        $display("Data Memory: 0x20 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[ 8])), $signed(BE32(mem_D.mem[ 9])), $signed(BE32(mem_D.mem[10])), $signed(BE32(mem_D.mem[11])));
        $display("Data Memory: 0x30 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[12])), $signed(BE32(mem_D.mem[13])), $signed(BE32(mem_D.mem[14])), $signed(BE32(mem_D.mem[15])));
        $display("Data Memory: 0x40 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[16])), $signed(BE32(mem_D.mem[17])), $signed(BE32(mem_D.mem[18])), $signed(BE32(mem_D.mem[19])));
        $display("Data Memory: 0x50 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[20])), $signed(BE32(mem_D.mem[21])), $signed(BE32(mem_D.mem[22])), $signed(BE32(mem_D.mem[23])));
        $display("Data Memory: 0x60 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[24])), $signed(BE32(mem_D.mem[25])), $signed(BE32(mem_D.mem[26])), $signed(BE32(mem_D.mem[27])));
        $display("Data Memory: 0x70 = %10d %10d %10d %10d", $signed(BE32(mem_D.mem[28])), $signed(BE32(mem_D.mem[29])), $signed(BE32(mem_D.mem[30])), $signed(BE32(mem_D.mem[31])));
        $display("");
        $display("");

        if (mem_addr_I[31:2] >= eof) begin
            $finish;
        end

    end

    always @(posedge clk) begin

        counter = counter + 1;

    end

    always #(`CYCLE*0.5) clk = ~clk;

endmodule

