`timescale 1ns/10ps
`define CYCLE  10.00 

module test;

//==================================Data file setting==============================//
parameter FILE_A = "ALU_a.dat"; 
parameter FILE_B = "ALU_b.dat"; 
parameter FILE_golden = "golden_ALU.dat"; 

//==================================Signal Declaration==============================//
wire [8:0] out;
reg [7:0] in_a , in_b;
reg  mode;
reg [8:0] ans;

reg [7:0] A [7:0];
reg [7:0] B [7:0];
reg [8:0] golden [7:0];
integer err , i;

//==================================Design Under Test==============================//
ALU my_alu ( .out(out) , .mode(mode) , .in_a(in_a) , .in_b(in_b)  ); 



//==================================Data File Reading==============================//
initial	$readmemh( FILE_A , A);
initial	$readmemh( FILE_B , B);
initial	$readmemh( FILE_golden , golden);



//==================================Waveform Generation==============================//
initial begin
	// $dumpvars();
    // $dumpfile("ALU.vcd");
    $fsdbDumpfile("ALU.fsdb");
    $fsdbDumpvars(0, test, "+mda");
end

//==================================Signal Stimulus==============================//
initial begin
	err = 0;
	$display ("============== Start to test ALU==============\n");
	for ( i=0 ; i<4 ; i=i+1 ) begin
		#8 
			mode=0; in_a = A[i]; in_b = B[i]; ans=golden[i];
		#2
			if (out!==ans) begin
				$display ("Pattern %d: ALU unsigned addition error : %d + %d , golden pattern = %d , output = %d\n", (i+1), in_a , in_b , ans , out);
				err = err + 1; 
			end
	end
	for ( i=4 ; i<8 ; i=i+1 ) begin
		#8 
			mode=1; in_a = A[i]; in_b = B[i]; ans=golden[i];
		#2
			if (out!==ans) begin
				$display ("Pattern %d: ALU signed addition error : %d + %d , golden pattern = %d , output = %d\n", (i+1), $signed(in_a) , $signed(in_b) , $signed(ans) , $signed(out));
				err = err + 1; 
			end
	end
	
	
	
	if(err==0) begin
    // $display("---------------------------------------------");
    $display("\n============!!!Congratulations!!!=============\n");
		$display("ALU functions have been tested successfully!");
    $display("\n==============================================\n");
  end

  #50
	$display ("=================  END  ======================\n");
    $finish;
end

initial begin
	#(`CYCLE*(100)) $finish;   //manual termination
end



endmodule
