module barrel_shifter_gate(in, shift, out);
    input  [7:0] in;
    input  [2:0] shift;
    output [7:0] out;

    /*Write your code here*/

    generate 
        genvar i;

        for (i = 0; i < 8; i = i+1) begin
            ShiftGen #(.off(i)) ShiftGen_0(out[i], in, shift);
        end
    endgenerate

    /*End of code*/
endmodule


module ShiftGen(output out, 
                input [7:0] in, 
                input [2:0] shift);
    parameter off = 0;

    wire [7:0] w;

    generate 
        genvar i;

        for (i = 0; i < off; i = i+1) begin
            buf (w[i], in[off-i]);
        end

        for (i = off; i < 8; i = i+1) begin
            buf (w[i], 1'b0);
        end

    endgenerate

    Mux8 Mux8_0(out, w, shift);

endmodule


module Mux8(output out, 
            input [7:0] in,
            input [2:0] sel);

    wire [7:0] sel_inv;  // select inversed
    wire [7:0] dec;      // decoded value
    wire [7:0] w0;

    not #1 n0[2:0](sel_inv[2:0], sel[2:0]);

    and #1 (w0[0], in[0], sel_inv[2], sel_inv[1], sel_inv[0]);
    and #1 (w0[1], in[1], sel_inv[2], sel_inv[1], sel    [0]);
    and #1 (w0[2], in[2], sel_inv[2], sel    [1], sel_inv[0]);
    and #1 (w0[3], in[3], sel_inv[2], sel    [1], sel    [0]);
    and #1 (w0[4], in[4], sel    [2], sel_inv[1], sel_inv[0]);
    and #1 (w0[5], in[5], sel    [2], sel_inv[1], sel    [0]);
    and #1 (w0[6], in[6], sel    [2], sel    [1], sel_inv[0]);
    and #1 (w0[7], in[7], sel    [2], sel    [1], sel    [0]);

    or #1 o0(out, w0[0], w0[1], w0[2], w0[3], w0[4], w0[5], w0[6], w0[7]);

endmodule
