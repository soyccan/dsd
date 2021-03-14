`timescale 1ns/10ps
`define CYCLE 20.0
`define SELFILE "Msel.pattern"
`define INFILE "Min.pattern"
`define OUTFILE "Mout_golden.pattern" 

module asu_test;
parameter pattern_num = 12;
wire [7:0] out;
wire carry;
reg [7:0] x, y;
reg mode;
reg  clk;
reg  stop;
integer i, num, error;

reg [8:0] ans_out;
reg [8:0] mux_out;

reg [1:0] data_base0 [0:100];
reg [7:0] data_base1 [0:100];
reg [8:0] data_base2 [0:100];

asu t (x, y, mode, carry, out);

//for scoring
integer fp_r, fp_w;

initial begin
	$readmemh(`SELFILE  , data_base0);
	$readmemh(`INFILE  , data_base1);
	$readmemh(`OUTFILE , data_base2);
	//for scoring
	fp_w = $fopen("../../student_score.txt", "a");
	$fwrite(fp_w, "asu_test: ");
	clk = 1'b1;
	error = 0;
	stop = 0;
	i=0;
end

always begin #(`CYCLE * 0.5) clk = ~clk;
end

initial begin
	mode = data_base0[0];
	x[7:0] = data_base1[0];
	y[7:0] = data_base1[1];
	
	for(num = 2; num < (pattern_num * 2); num = num + 2) begin
		@(posedge clk) begin
			mode = data_base0[num / 2];
			x[7:0] = data_base1[num];
			y[7:0] = data_base1[num + 1];
		end
	end
end


always@(posedge clk) begin
	i <= i + 1;
	if (i >= pattern_num)
		stop <= 1;
end

always@(posedge clk ) begin
	mux_out <= {carry, out};
	ans_out <= data_base2[i];
	if(mux_out !== ans_out) begin
		error <= error + 1;
		$display("An ERROR occurs at no.%d pattern: Output %b != answer %b.\n", i, mux_out, ans_out);
	end
end

initial begin
	@(posedge stop) begin
		if(error == 0) begin
			$display("==========================================\n");
			$display("======  Congratulation! You Pass!  =======\n");
			$display("==========================================\n");
			//for scoring
			$fwrite(fp_w, "Pass! ");
		end
		else begin
			$display("===============================\n");
			$display("There are %d errors.", error);
			$display("===============================\n");
			//for scoring
			$fwrite(fp_w, "%d errors, fail; ",error);
		end
		$finish;
	end
end

/*================Dumping Waveform files====================*/
initial begin
//$dumpfile("mux.vcd");
//$dumpvars;
$fsdbDumpfile("mux.fsdb");
$fsdbDumpvars;
end

endmodule