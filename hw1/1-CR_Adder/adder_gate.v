`timescale 1ns/10ps
module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;

/*Write your code here*/

wire [8:0] c;

assign c[0] = 0;

full_adder full_adder_0(.x(x[0]), .y(y[0]), .cin(c[0]), .cout(c[1]), .sum(out[0]));
full_adder full_adder_1(.x(x[1]), .y(y[1]), .cin(c[1]), .cout(c[2]), .sum(out[1]));
full_adder full_adder_2(.x(x[2]), .y(y[2]), .cin(c[2]), .cout(c[3]), .sum(out[2]));
full_adder full_adder_3(.x(x[3]), .y(y[3]), .cin(c[3]), .cout(c[4]), .sum(out[3]));
full_adder full_adder_4(.x(x[4]), .y(y[4]), .cin(c[4]), .cout(c[5]), .sum(out[4]));
full_adder full_adder_5(.x(x[5]), .y(y[5]), .cin(c[5]), .cout(c[6]), .sum(out[5]));
full_adder full_adder_6(.x(x[6]), .y(y[6]), .cin(c[6]), .cout(c[7]), .sum(out[6]));
full_adder full_adder_7(.x(x[7]), .y(y[7]), .cin(c[7]), .cout(c[8]), .sum(out[7]));

assign carry = c[8];

/*End of code*/

endmodule


//// full_adder
module full_adder(input x, y, cin, output cout, sum);

wire z, w0, w1;

xor #1 x0(z, x, y);

xor #1 x1(sum, z, cin);

and #1 a0(w0, x, y);

and #1 a1(w1, z, cin);

or #1 o0(cout, w0, w1);

endmodule
//// end full_adder