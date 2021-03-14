`timescale 1ns/10ps

module adder_gate(x, y, carry, out);

    input [8:1] x, y;
    output carry;
    output [8:1] out;

    /*Write your code here*/

    // select adder
    wire [8:1] sum0, sum1;
    wire c1_0, c1_1, c2_0, c2_1;

    RippleCarryAdder4 rca0_0(sum0[4:1], c1_0, x[4:1], y[4:1], 1'b0);
    // RippleCarryAdder4 rca0_1(sum1[4:1], c1_1, x[4:1], y[4:1], 1'b1);

    assign #3 out[4:1] = sum0[4:1];

    RippleCarryAdder4 rca1_0(sum0[8:5], c2_0, x[8:5], y[8:5], 1'b0);
    RippleCarryAdder4 rca1_1(sum1[8:5], c2_1, x[8:5], y[8:5], 1'b1);

    assign #3 out[8:5] = c1_0 ? sum1[8:5] : sum0[8:5];
    assign #3 carry    = c1_0 ? c2_1      : c2_0;

    /*End of code*/

endmodule


// MODULE {{{
module RippleCarryAdder4(output [4:1] sum, 
                         output cout, 
                         input [4:1] a, b, 
                         input cin);
  
    wire [4:0] c;

    buf (c[0], cin);

    FullAdder fa[4:1](sum[4:1], c[4:1], a[4:1], b[4:1], c[3:0]);

    buf (cout, c[4]);
  
endmodule
// }}}


// MODULE {{{
module FullAdder(output sum, cout, input x, y, cin);

    wire p, g, pc;

    xor #1 (p, x, y);
    xor #1 (sum, p, cin);

    and #1 (pc, p, cin);
    and #1 (g, x, y);
    or  #1 (cout, g, pc);

endmodule
// }}}