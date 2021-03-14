module barrel_shifter(in, shift, out);
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


//// submodule: shift left by some amount
module shift_left(input shift, input [7:0] in, output [7:0] out);

// shift amount
parameter shamt = 1;

generate
    genvar i;

    for (i = 0; i < shamt; i = i+1)
        assign out[i] = shift ? 1'b0 : in[i];

    for (i = shamt; i < 8; i = i+1)
        assign out[i] = shift ? in[i - shamt] : in[i];

endgenerate

endmodule
//// end submodule shift_left