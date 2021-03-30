`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // parameters
    parameter pattern_num = 50;

    // port declaration for design-under-test
    reg clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    
    // instantiate the design-under-test
    register_file rf(
        clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );

    // write your test pattern here
    integer count, i, error;
    reg [17:0] pattern_in[0:pattern_num-1];
    reg [15:0] pattern_out_gold[0:pattern_num-1];
    reg [7:0] busX_gold;
    reg [7:0] busY_gold;

    initial begin
        // dump waveform
        $fsdbDumpfile("register_file.fsdb");
        $fsdbDumpvars("+mda");
        $dumpfile("register_file.vcd");
        $dumpvars;
        // for (i = 0; i < 100; i = i + 1) begin
        //     $dumpvars(1, rf._reg[i]);
        // end

        // register initialization
        for (i = 0; i < 8; i = i + 1) begin
            rf._reg[i] = 8'b0;
        end
        rf._reg[1] = 8'haa;
        rf._reg[2] = 8'hbb;
        rf._reg[3] = 8'hcc;
        rf._reg[4] = 8'hdd;
        rf._reg[5] = 8'hee;
        rf._reg[6] = 8'hff;

        for (i = 0; i < 8; i = i + 1) begin
            $monitor("_reg[%d] = %x", i, rf._reg[i]);
        end

        // variable initialization
        clk = 1'b1;
        count = 0;
        error = 0;

        // read pattern
        $readmemb("pattern.in", pattern_in);
        $readmemh("pattern.out.golden", pattern_out_gold);

        {WEN, RW, RX, RY, busW} = pattern_in[0];
        {busX_gold, busY_gold} = pattern_out_gold[0];

        for (i = 1; i < pattern_num; i = i + 1) begin
            // Note: 
            //   @(posedge clk) should be placed at the end of
            //   the initial block
            //   otherwise the code after these expressions will be executed
            //   at the end of simulation
            @(negedge clk) begin
                // Note: 
                //   should be non-blocking, otherwise the 
                //   "_reg[i] <= nxt_reg[i]" assignment in register_file.v
                //   will be trigger AFTER {WEN ...} input signal is updated, 
                //   which is unwanted
                // Observation: 
                //   the @(posedge clk) blocks share events 
                //   across modules
                {WEN, RW, RX, RY, busW} <= pattern_in[i];
                {busX_gold, busY_gold} <= pattern_out_gold[i];
            end
        end
    end

    always begin
        #(`CYCLE * 0.5) clk = ~clk;
    end

    always @(negedge clk) begin
        // input changes at negedge
        // so test at middle point between posedge and negedge
        #(`CYCLE * 0.25);

        if (busY != busY_gold || busX != busX_gold) begin
            error <= error + 1;
            $display("ERROR: count=%2d WEN=%h RW=%h RX=%h RY=%h busW=%h", 
                     count, WEN, RW, RX, RY, busW);
            $display("       output   busX=%h busY=%h", busX, busY);
            $display("       expected busX=%h busY=%h", 
                     busX_gold, busY_gold);
            $display();
        end
    end

    always @(posedge clk) begin
        count <= count + 1;

        if (count >= pattern_num) begin
            if (error) 
                $display("There are %d errors.", error);
            else 
                $display("No error.");
            
            $finish;
        end
    end

endmodule
