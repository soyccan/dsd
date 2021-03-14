`timescale 1ns/10ps
module barrel_shifter_gate(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;

/*Write your code here*/

wire [7:0] w0;
wire [7:0] w1;

shift_left #(.shamt(1)) shift_left_0(.shift(shift[0]), .in(in), .out(w0));
shift_left #(.shamt(2)) shift_left_1(.shift(shift[1]), .in(w0), .out(w1));
shift_left #(.shamt(4)) shift_left_2(.shift(shift[2]), .in(w1), .out(out));

/*End of code*/
endmodule


// MODULE: shift_left {{{
// shift left by some amount
module shift_left(input shift, input [7:0] in, output [7:0] out);

// shift amount
parameter shamt = 1;

generate
    genvar i;

    for (i = 0; i < shamt; i = i+1) begin : block_label_1
        mux mux(out[i], in[i], 1'b0, shift);
    end

    for (i = shamt; i < 8; i = i+1)
        mux mux(out[i], in[i], in[i - shamt], shift);

endgenerate

endmodule
// }}}


// MODULE: mux {{{
module mux (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not #1 n0(sel_i,sel);
and #1 a1(w1,a,sel_i);
and #1 a2(w2,b,sel);
or  #1 o1(x,w1,w2);

	
endmodule
// }}}
