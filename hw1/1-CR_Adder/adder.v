module adder(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;

/*Write your code here*/

assign {carry, out} = x + y;

/*End of code*/

endmodule