//continuous assignment tb
`timescale 1ns/10ps
`define CYCLE   10
`define HCYCLE  5

module alu_assign_tb;

    parameter pattern_num = 62;
    
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    reg clk;
    integer i, j, stop, error;

    reg [19:0] pattern_in[0:100]; // ctrl(4) x(8) y(8)
    reg [8:0]  pattern_out_gold[0:100]; // carry(1) out(8)

    alu_assign alu_assign(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

     initial begin
       $fsdbDumpfile("alu_assign.fsdb");
       $fsdbDumpvars;
	   $dumpfile("alu_assign.vcd");
	   $dumpvars;
 
        $readmemh("../pattern.in", pattern_in);
        $readmemh("../pattern.out.golden", pattern_out_gold);

        clk = 1'b1;
        i = 0;
        stop = 0;
        error = 0;

        ctrl[3:0] = pattern_in[0][19:16];
        x[7:0] = pattern_in[0][15:8];
        y[7:0] = pattern_in[0][7:0];

        for (j = 1; j < pattern_num; j = j + 1) begin
            @(posedge clk) begin
                ctrl[3:0] = pattern_in[j][19:16];
                x[7:0] = pattern_in[j][15:8];
                y[7:0] = pattern_in[j][7:0];
            end
        end
    end

    always begin
        #(`CYCLE * 0.5) clk = ~clk;
    end

    always @(posedge clk) begin
        if (out != pattern_out_gold[i][7:0]
            || ((ctrl == 4'b0000 || ctrl == 4'b0001) 
                && carry != pattern_out_gold[i][8])) begin
            error = error + 1;
            $display("ERROR: i=%2d x=%h y=%h ctrl=%h {carry,out}=%h", i, x, y, ctrl, {carry,out});
            $display("       expected {carry,out}=%h", pattern_out_gold[i]);
            $display();
        end
    end

    always @(posedge clk) begin
        i <= i + 1;
        if (i >= pattern_num)
            stop <= 1;
    end

    always @(posedge clk) begin
        if (stop) begin

            #(`HCYCLE);
            if (error) $display("There are %d errors.", error);
            else $display("No error.");
            
            // finish tb
            #(`CYCLE) $finish;
        end
    end
endmodule
