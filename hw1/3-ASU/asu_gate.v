`timescale 1ns/10ps
module asu_gate (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/

wire [7:0] adder_out;
wire [7:0] shifter_out;

adder_gate adder_gate(.x(x), .y(y), .carry(carry), .out(adder_out));

barrel_shifter_gate barrel_shifter_gate(.in(x), .shift(y[2:0]), .out(shifter_out));

assign #2.5 out = mode ? adder_out : shifter_out;

/*End of code*/

endmodule