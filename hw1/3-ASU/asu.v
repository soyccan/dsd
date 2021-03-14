module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/

wire [7:0] adder_out;
wire [7:0] shifter_out;

adder adder(.x(x), .y(y), .carry(carry), .out(adder_out));

barrel_shifter barrel_shifter(.in(x), .shift(y[2:0]), .out(shifter_out));

assign out = mode ? adder_out : shifter_out;

/*End of code*/


endmodule