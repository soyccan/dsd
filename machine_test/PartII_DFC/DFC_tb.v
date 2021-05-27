`timescale 1ns/10ps
`define CYCLE    10           	        // Modify your clock period here
`define SDFFILE    "./DFC_syn.sdf"	       // Modify your sdf file name
`define DATA    "./datain.dat"         
`define CMD      "./cmd.dat"           
`define EXPECT   "./golden_DFC.dat"    

module test;
parameter DATA_N_PAT = 8;
parameter CMD_N_PAT = 3;
parameter OUT_LENGTH= 8;
parameter t_reset = `CYCLE*2;

reg           clk;
reg           reset;
reg   [7:0]   datain;
reg   [1:0]   cmd;
reg           cmd_valid;
wire  [8:0]   dataout;
wire          output_valid;
wire          busy;

reg   [7:0]   data_mem [0:DATA_N_PAT-1];
reg   [2:0]   cmd_mem   [0:CMD_N_PAT-1];
reg   [8:0]   ans_mem   [0:OUT_LENGTH-1];
reg   [8:0]   out_temp;


integer       i, j, out_f, err, pass, pattern_num;
reg           over;

   DFC DFC(.clk(clk), .reset(reset), .datain(datain), 
                .cmd(cmd), .cmd_valid(cmd_valid), .dataout(dataout), 
                .output_valid(output_valid), .busy(busy));          
   

   
`ifdef SDF
	initial $sdf_annotate(`SDFFILE, DFC);
`endif


initial	$readmemh (`DATA,  data_mem);
initial	$readmemh (`CMD,    cmd_mem);
initial	$readmemh (`EXPECT, ans_mem);

initial begin
   clk         = 1'b0;
   reset       = 1'b0;
   cmd_valid   = 1'b0;
   over        = 1'b0;
   pattern_num = 0;
   err         = 0;
   pass        = 0;             
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	// $dumpfile("DFC.vcd");
	// $dumpvars;
    $fsdbDumpfile("DFC.fsdb");
    $fsdbDumpvars(0, test, "+mda");
end


initial begin
   @(negedge clk)  reset = 1'b1;
   #t_reset        reset = 1'b0;
   
   @(negedge clk)    i=0;
   while (i <= CMD_N_PAT) begin               
      if(!busy) begin
        cmd = cmd_mem[i];
        cmd_valid = 1'b1;  
        
        if(cmd_mem[i] === 'd0) begin    //cmd: Load data        
           for(j=0; j<=DATA_N_PAT; j=j+1)begin
              @(negedge clk) datain = data_mem[j];
                             cmd = 'hz; cmd_valid = 1'b0;
           end
           i = i+1;
        end
        else begin                      //cmd: other command
           @(negedge clk) datain='hz; cmd_valid = 1'b0; i = i+1;
        end       
      end 
      else begin
         datain='hz; cmd = 'hz;  cmd_valid = 0;
         @(negedge clk);
      end               
    end                                       
end

always @(posedge clk)begin
   out_temp = ans_mem[pattern_num];
   if(output_valid)begin      
      if(dataout !== out_temp) begin
         $display("ERROR at pattern %d:output %h !=expect %h ",(pattern_num+1), dataout, out_temp);
         err = err + 1 ;          
      end            
      else if(dataout === out_temp)begin      
         pass = pass + 1 ;
      end      
      #1 pattern_num = pattern_num + 1;
   end
   if(pattern_num === OUT_LENGTH)  over = 1'b1;      
  
end


initial begin
      @(posedge over)      
      if(pass === OUT_LENGTH) begin
         $display("-----------------------------------------------------------\n");
         $display("Congratulations! All data have been generated successfully!\n");
         $display("-------------------------PASS------------------------------\n");
      end
      else begin
            $display("-----------------------------------------------------\n");
            $display("            There are %d errors!\n", err);
            $display("-----------------------------------------------------\n");
      end
      $finish;
end

initial begin
  #(`CYCLE*5000);
      $display("---------------------WARRNING------------------------\n");
      $display("Simulation STOP! Maybe your circuit has some problem!\n");
      $display("Please check your ciruit again ...                   \n");
      $display("-----------------------------------------------------\n");
      $finish;
end
   
endmodule
