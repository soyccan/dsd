`timescale 1 ns/10 ps
`define TestPort    30'h3FF      // 1023
`define BeginSymbol 32'h00000168
`define EndSymbol   32'h00000D5D
`define CheckNum    12'd161

module	TestBed(
	clk,
	rst,
	addr,
	data,
	wen,
	error_num,
	duration,
	finish
);
	input			clk, rst;
	input	[29:0]	addr;
	input	[31:0]	data;
	input			wen;

	output	[7:0]	error_num;
	output	[15:0]	duration;
	output			finish;
	reg		[7:0]	error_num;
	reg		[15:0]	duration;
	reg				finish;
	
	reg		[31:0]	answer;

	reg		[1:0]	curstate;
	reg		[1:0]	nxtstate;
	reg		[11:0]	curaddr;
	reg		[11:0]	nxtaddr;
	reg		[7:0]	nxt_error_num;
	reg		[15:0]	nxtduration;
	
	reg				state,state_next;
		
	parameter	state_idle 	= 2'b00;
	parameter	state_check = 2'b01;
	parameter	state_report= 2'b10;	
		
	always@( posedge clk or negedge rst )						// State-DFF
	begin
		if( ~rst )
		begin
			curstate <= state_idle;
			curaddr  <= 0;
			duration <= 0;
			error_num <= 8'd255;
			
			state <= 0;
		end
		else
		begin
			curstate <= nxtstate;
			curaddr  <= nxtaddr;
			duration <= nxtduration;
			error_num <= nxt_error_num;
			
			state <= state_next;
		end
	end
			
	always@(*)	// FSM for test
	begin
		finish = 1'b0;
		case( curstate )
		state_idle: 	begin
							nxtaddr = 0;
							nxtduration = 0;
							nxt_error_num = 255;	
							if( addr==`TestPort && data==`BeginSymbol && wen )
							begin
								nxt_error_num = 0;
								nxtstate = state_check;
							end	 	
							else nxtstate = state_idle;
						end
		state_check:	begin
							nxtduration = duration + 1;
							nxtaddr = curaddr;						
							nxt_error_num = error_num;	
							if( addr==`TestPort && wen && state==0 )
							begin
								nxtaddr = curaddr + 1;
								if( data != answer )
									nxt_error_num = error_num + 8'd1;
							end
							nxtstate = curstate;
							if( curaddr==`CheckNum )	
								nxtstate = state_report;
						end
		state_report:	begin
							finish = 1'b1;
							nxtaddr = curaddr;
							nxtstate = curstate;		
							nxtduration = duration;
							nxt_error_num = error_num;	
						end				
		endcase	
	end

	always@( negedge clk )						
	begin
		if(curstate == state_report) begin
			$display("--------------------------- Simulation FINISH !!---------------------------");
			if (error_num) begin 
				$display("============================================================================");
				$display("\n (T_T) FAIL!! The simulation result is FAIL!!! there were %d errors at all.\n", error_num);
				$display("============================================================================");
			end
			 else begin 
				$display("============================================================================");
				$display("\n \\(^o^)/ CONGRATULATIONS!!  The simulation result is PASS!!!\n");
				$display("============================================================================");
			end
		end
	end
	
	always@(*)begin//sub-FSM (avoid the Dcache stall condition)
		case(state)
			1'b0:begin
				if(wen)
					state_next=1;
				else
					state_next=state;				
			end
			1'b1:begin
				if(!wen)
					state_next=0;
				else
					state_next=state;	
			end
		endcase
	end
	
	
	always@(*)	// ROM for correct result
	begin
		answer = 0;
		case( curaddr )
		12'd0   : answer = 32'd0     ;
		12'd1   : answer = 32'd1     ;
		12'd2   : answer = 32'd2     ;
		12'd3   : answer = 32'd3     ;
		12'd4   : answer = 32'd1     ;
		12'd5   : answer = 32'd2     ;
		12'd6   : answer = 32'd3     ;
		12'd7   : answer = 32'd4     ;
		12'd8   : answer = 32'd1     ;
		12'd9   : answer = 32'd2     ;
		12'd10  : answer = 32'd3     ;
		12'd11  : answer = 32'd4     ;
		12'd12  : answer = 32'd2     ;
		12'd13  : answer = 32'd3     ;
		12'd14  : answer = 32'd4     ;
		12'd15  : answer = 32'd5     ;
		12'd16  : answer = 32'd3     ;
		12'd17  : answer = 32'd4     ;
		12'd18  : answer = 32'd5     ;
		12'd19  : answer = 32'd6     ;
		12'd20  : answer = 32'd5     ;
		12'd21  : answer = 32'd6     ;
		12'd22  : answer = 32'd7     ;
		12'd23  : answer = 32'd8     ;
		12'd24  : answer = 32'd8     ;
		12'd25  : answer = 32'd9     ;
		12'd26  : answer = 32'd10    ;
		12'd27  : answer = 32'd11    ;
		12'd28  : answer = 32'd13    ;
		12'd29  : answer = 32'd14    ;
		12'd30  : answer = 32'd15    ;
		12'd31  : answer = 32'd16    ;
		12'd32  : answer = 32'd21    ;
		12'd33  : answer = 32'd22    ;
		12'd34  : answer = 32'd23    ;
		12'd35  : answer = 32'd24    ;
		12'd36  : answer = 32'd34    ;
		12'd37  : answer = 32'd35    ;
		12'd38  : answer = 32'd36    ;
		12'd39  : answer = 32'd37    ;
		12'd40  : answer = 32'd55    ;
		12'd41  : answer = 32'd56    ;
		12'd42  : answer = 32'd57    ;
		12'd43  : answer = 32'd58    ;
		12'd44  : answer = 32'd89    ;
		12'd45  : answer = 32'd90    ;
		12'd46  : answer = 32'd91    ;
		12'd47  : answer = 32'd92    ;
		12'd48  : answer = 32'd144   ;
		12'd49  : answer = 32'd145   ;
		12'd50  : answer = 32'd146   ;
		12'd51  : answer = 32'd147   ;
		12'd52  : answer = 32'd233   ;
		12'd53  : answer = 32'd234   ;
		12'd54  : answer = 32'd235   ;
		12'd55  : answer = 32'd236   ;
		12'd56  : answer = 32'd377   ;
		12'd57  : answer = 32'd378   ;
		12'd58  : answer = 32'd379   ;
		12'd59  : answer = 32'd380   ;
		12'd60  : answer = 32'd610   ;
		12'd61  : answer = 32'd611   ;
		12'd62  : answer = 32'd612   ;
		12'd63  : answer = 32'd613   ;
		12'd64  : answer = 32'd987   ;
		12'd65  : answer = 32'd988   ;
		12'd66  : answer = 32'd989   ;
		12'd67  : answer = 32'd990   ;
		12'd68  : answer = 32'd1597  ;
		12'd69  : answer = 32'd1598  ;
		12'd70  : answer = 32'd1599  ;
		12'd71  : answer = 32'd1600  ;
		12'd72  : answer = 32'd2584  ;
		12'd73  : answer = 32'd2585  ;
		12'd74  : answer = 32'd2586  ;
		12'd75  : answer = 32'd2587  ;
		12'd76  : answer = 32'd4181  ;
		12'd77  : answer = 32'd4182  ;
		12'd78  : answer = 32'd4183  ;
		12'd79  : answer = 32'd4184  ;
		12'd80  : answer = 32'd4184  ;
		12'd81  : answer = 32'd4183  ;
		12'd82  : answer = 32'd4182  ;
		12'd83  : answer = 32'd4181  ;
		12'd84  : answer = 32'd2587  ;
		12'd85  : answer = 32'd2586  ;
		12'd86  : answer = 32'd2585  ;
		12'd87  : answer = 32'd2584  ;
		12'd88  : answer = 32'd1600  ;
		12'd89  : answer = 32'd1599  ;
		12'd90  : answer = 32'd1598  ;
		12'd91  : answer = 32'd1597  ;
		12'd92  : answer = 32'd990   ;
		12'd93  : answer = 32'd989   ;
		12'd94  : answer = 32'd988   ;
		12'd95  : answer = 32'd987   ;
		12'd96  : answer = 32'd613   ;
		12'd97  : answer = 32'd612   ;
		12'd98  : answer = 32'd611   ;
		12'd99  : answer = 32'd610   ;
		12'd100 : answer = 32'd380   ;
		12'd101 : answer = 32'd379   ;
		12'd102 : answer = 32'd378   ;
		12'd103 : answer = 32'd377   ;
		12'd104 : answer = 32'd236   ;
		12'd105 : answer = 32'd235   ;
		12'd106 : answer = 32'd234   ;
		12'd107 : answer = 32'd233   ;
		12'd108 : answer = 32'd147   ;
		12'd109 : answer = 32'd146   ;
		12'd110 : answer = 32'd145   ;
		12'd111 : answer = 32'd144   ;
		12'd112 : answer = 32'd92    ;
		12'd113 : answer = 32'd91    ;
		12'd114 : answer = 32'd90    ;
		12'd115 : answer = 32'd89    ;
		12'd116 : answer = 32'd58    ;
		12'd117 : answer = 32'd57    ;
		12'd118 : answer = 32'd56    ;
		12'd119 : answer = 32'd55    ;
		12'd120 : answer = 32'd37    ;
		12'd121 : answer = 32'd36    ;
		12'd122 : answer = 32'd35    ;
		12'd123 : answer = 32'd34    ;
		12'd124 : answer = 32'd24    ;
		12'd125 : answer = 32'd23    ;
		12'd126 : answer = 32'd22    ;
		12'd127 : answer = 32'd21    ;
		12'd128 : answer = 32'd16    ;
		12'd129 : answer = 32'd15    ;
		12'd130 : answer = 32'd14    ;
		12'd131 : answer = 32'd13    ;
		12'd132 : answer = 32'd11    ;
		12'd133 : answer = 32'd10    ;
		12'd134 : answer = 32'd9     ;
		12'd135 : answer = 32'd8     ;
		12'd136 : answer = 32'd8     ;
		12'd137 : answer = 32'd7     ;
		12'd138 : answer = 32'd6     ;
		12'd139 : answer = 32'd6     ;
		12'd140 : answer = 32'd5     ;
		12'd141 : answer = 32'd5     ;
		12'd142 : answer = 32'd5     ;
		12'd143 : answer = 32'd4     ;
		12'd144 : answer = 32'd4     ;
		12'd145 : answer = 32'd4     ;
		12'd146 : answer = 32'd4     ;
		12'd147 : answer = 32'd3     ;
		12'd148 : answer = 32'd3     ;
		12'd149 : answer = 32'd3     ;
		12'd150 : answer = 32'd3     ;
		12'd151 : answer = 32'd3     ;
		12'd152 : answer = 32'd2     ;
		12'd153 : answer = 32'd2     ;
		12'd154 : answer = 32'd2     ;
		12'd155 : answer = 32'd2     ;
		12'd156 : answer = 32'd1     ;
		12'd157 : answer = 32'd1     ;
		12'd158 : answer = 32'd1     ;
		12'd159 : answer = 32'd0     ;
		12'd160 : answer = `EndSymbol;
		endcase
	end
endmodule