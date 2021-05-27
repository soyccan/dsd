/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP2
// Date      : Thu May 27 15:33:50 2021
/////////////////////////////////////////////////////////////


module ALU_0_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_0_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_0 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_0_DW01_add_0 add_7_2 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_0_DW01_add_1 add_7 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), 
        .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U6 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U7 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U8 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U9 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  AO22X1 U10 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U11 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_3_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_3_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_3 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_3_DW01_add_0 add_7_2 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_3_DW01_add_1 add_7 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), 
        .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U4 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  AO22X1 U5 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U6 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U7 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  AO22X1 U8 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U9 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U10 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U11 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_2_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_2_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_2 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_2_DW01_add_0 add_7_2 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_2_DW01_add_1 add_7 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), 
        .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U6 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U7 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U8 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U9 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  AO22X1 U10 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U11 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_1_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_1_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_1 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_1_DW01_add_0 add_7_2 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_1_DW01_add_1 add_7 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), 
        .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U6 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U7 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U8 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U9 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  AO22X1 U10 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U11 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module DFC ( clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy
 );
  input [7:0] datain;
  input [1:0] cmd;
  output [8:0] dataout;
  input clk, reset, cmd_valid;
  output output_valid, busy;
  wire   n217, n218, n219, n220, n221, n222, n223, n224, n225, n226, n227,
         \y[0][8] , \y[0][7] , \y[0][6] , \y[0][5] , \y[0][4] , \y[0][3] ,
         \y[0][2] , \y[0][1] , \y[0][0] , \y[1][8] , \y[1][7] , \y[1][6] ,
         \y[1][5] , \y[1][4] , \y[1][3] , \y[1][2] , \y[1][1] , \y[1][0] ,
         \y[2][8] , \y[2][7] , \y[2][6] , \y[2][5] , \y[2][4] , \y[2][3] ,
         \y[2][2] , \y[2][1] , \y[2][0] , \y[3][8] , \y[3][7] , \y[3][6] ,
         \y[3][5] , \y[3][4] , \y[3][3] , \y[3][2] , \y[3][1] , \y[3][0] ,
         \a[0][7] , \a[0][6] , \a[0][5] , \a[0][4] , \a[0][3] , \a[0][2] ,
         \a[0][1] , \a[0][0] , \a[1][7] , \a[1][6] , \a[1][5] , \a[1][4] ,
         \a[1][3] , \a[1][2] , \a[1][1] , \a[1][0] , \a[2][7] , \a[2][6] ,
         \a[2][5] , \a[2][4] , \a[2][3] , \a[2][2] , \a[2][1] , \a[2][0] ,
         \a[3][7] , \a[3][6] , \a[3][5] , \a[3][4] , \a[3][3] , \a[3][2] ,
         \a[3][1] , \a[3][0] , \b[0][7] , \b[0][6] , \b[0][5] , \b[0][4] ,
         \b[0][3] , \b[0][2] , \b[0][1] , \b[0][0] , \b[1][7] , \b[1][6] ,
         \b[1][5] , \b[1][4] , \b[1][3] , \b[1][2] , \b[1][1] , \b[1][0] ,
         \b[2][7] , \b[2][6] , \b[2][5] , \b[2][4] , \b[2][3] , \b[2][2] ,
         \b[2][1] , \b[2][0] , \b[3][7] , \b[3][6] , \b[3][5] , \b[3][4] ,
         \b[3][3] , \b[3][2] , \b[3][1] , \b[3][0] , \a_nxt[1][7] ,
         \a_nxt[1][6] , \a_nxt[1][5] , \a_nxt[1][4] , \a_nxt[1][3] ,
         \a_nxt[1][2] , \a_nxt[1][1] , \a_nxt[1][0] , \a_nxt[2][7] ,
         \a_nxt[2][6] , \a_nxt[2][5] , \a_nxt[2][4] , \a_nxt[2][3] ,
         \a_nxt[2][2] , \a_nxt[2][1] , \a_nxt[2][0] , \a_nxt[3][7] ,
         \a_nxt[3][6] , \a_nxt[3][5] , \a_nxt[3][4] , \a_nxt[3][3] ,
         \a_nxt[3][2] , \a_nxt[3][1] , \a_nxt[3][0] , \b_nxt[0][7] ,
         \b_nxt[0][6] , \b_nxt[0][5] , \b_nxt[0][4] , \b_nxt[0][3] ,
         \b_nxt[0][2] , \b_nxt[0][1] , \b_nxt[0][0] , \b_nxt[1][7] ,
         \b_nxt[1][6] , \b_nxt[1][5] , \b_nxt[1][4] , \b_nxt[1][3] ,
         \b_nxt[1][2] , \b_nxt[1][1] , \b_nxt[1][0] , \b_nxt[2][7] ,
         \b_nxt[2][6] , \b_nxt[2][5] , \b_nxt[2][4] , \b_nxt[2][3] ,
         \b_nxt[2][2] , \b_nxt[2][1] , \b_nxt[2][0] , \b_nxt[3][7] ,
         \b_nxt[3][6] , \b_nxt[3][5] , \b_nxt[3][4] , \b_nxt[3][3] ,
         \b_nxt[3][2] , \b_nxt[3][1] , \b_nxt[3][0] , n1, n11, n12, n13, n14,
         n16, n18, n19, n20, n23, n24, n25, n29, n30, n31, n32, n33, n35, n38,
         n39, n42, n43, n44, n46, n47, n48, n51, n52, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n76, n77,
         n78, n79, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n154, n155, n156, n157, n158, n159, n160, n161,
         n173, n174, n175, n176, n177, n178, n179, n180, n181, n182, n183,
         n184, n185, n186, n187, n188, n189, n190, n191, n192, n193, n194,
         n195, n196, n197, n198, n199, n200, n201, n202, n203, n204, n205,
         n206, n207, n208, n209, n210, n211, n212, n213, n214, n215, n216;
  wire   [4:0] state;

  ALU_0 A0 ( .out({\y[0][8] , \y[0][7] , \y[0][6] , \y[0][5] , \y[0][4] , 
        \y[0][3] , \y[0][2] , \y[0][1] , \y[0][0] }), .mode(1'b1), .in_a({
        \a[0][7] , \a[0][6] , \a[0][5] , \a[0][4] , \a[0][3] , \a[0][2] , 
        \a[0][1] , \a[0][0] }), .in_b({\b[0][7] , \b[0][6] , \b[0][5] , 
        \b[0][4] , \b[0][3] , \b[0][2] , \b[0][1] , \b[0][0] }) );
  ALU_3 A1 ( .out({\y[1][8] , \y[1][7] , \y[1][6] , \y[1][5] , \y[1][4] , 
        \y[1][3] , \y[1][2] , \y[1][1] , \y[1][0] }), .mode(1'b1), .in_a({
        \a[1][7] , \a[1][6] , \a[1][5] , \a[1][4] , \a[1][3] , \a[1][2] , 
        \a[1][1] , \a[1][0] }), .in_b({\b[1][7] , \b[1][6] , \b[1][5] , 
        \b[1][4] , \b[1][3] , \b[1][2] , \b[1][1] , \b[1][0] }) );
  ALU_2 A2 ( .out({\y[2][8] , \y[2][7] , \y[2][6] , \y[2][5] , \y[2][4] , 
        \y[2][3] , \y[2][2] , \y[2][1] , \y[2][0] }), .mode(1'b1), .in_a({
        \a[2][7] , \a[2][6] , \a[2][5] , \a[2][4] , \a[2][3] , \a[2][2] , 
        \a[2][1] , \a[2][0] }), .in_b({\b[2][7] , \b[2][6] , \b[2][5] , 
        \b[2][4] , \b[2][3] , \b[2][2] , \b[2][1] , \b[2][0] }) );
  ALU_1 A3 ( .out({\y[3][8] , \y[3][7] , \y[3][6] , \y[3][5] , \y[3][4] , 
        \y[3][3] , \y[3][2] , \y[3][1] , \y[3][0] }), .mode(1'b1), .in_a({
        \a[3][7] , \a[3][6] , \a[3][5] , \a[3][4] , \a[3][3] , \a[3][2] , 
        \a[3][1] , \a[3][0] }), .in_b({\b[3][7] , \b[3][6] , \b[3][5] , 
        \b[3][4] , \b[3][3] , \b[3][2] , \b[3][1] , \b[3][0] }) );
  DFFRX1 \state_reg[2]  ( .D(n155), .CK(clk), .RN(n188), .Q(state[2]), .QN(
        n159) );
  DFFRX1 \a_reg[0][6]  ( .D(n151), .CK(clk), .RN(n186), .Q(\a[0][6] ), .QN(
        n143) );
  DFFRX1 \a_reg[0][5]  ( .D(n150), .CK(clk), .RN(n186), .Q(\a[0][5] ), .QN(
        n142) );
  DFFRX1 \a_reg[0][4]  ( .D(n149), .CK(clk), .RN(n186), .Q(\a[0][4] ), .QN(
        n141) );
  DFFRX1 \a_reg[0][3]  ( .D(n148), .CK(clk), .RN(n186), .Q(\a[0][3] ), .QN(
        n140) );
  DFFRX1 \a_reg[0][2]  ( .D(n147), .CK(clk), .RN(n186), .Q(\a[0][2] ), .QN(
        n139) );
  DFFRX1 \a_reg[0][1]  ( .D(n146), .CK(clk), .RN(n186), .Q(\a[0][1] ), .QN(
        n138) );
  DFFRX1 \a_reg[1][6]  ( .D(\a_nxt[1][6] ), .CK(clk), .RN(n185), .Q(\a[1][6] ), 
        .QN(n87) );
  DFFRX1 \a_reg[1][5]  ( .D(\a_nxt[1][5] ), .CK(clk), .RN(n185), .Q(\a[1][5] ), 
        .QN(n86) );
  DFFRX1 \a_reg[1][4]  ( .D(\a_nxt[1][4] ), .CK(clk), .RN(n185), .Q(\a[1][4] ), 
        .QN(n85) );
  DFFRX1 \a_reg[1][3]  ( .D(\a_nxt[1][3] ), .CK(clk), .RN(n185), .Q(\a[1][3] ), 
        .QN(n84) );
  DFFRX1 \a_reg[1][2]  ( .D(\a_nxt[1][2] ), .CK(clk), .RN(n185), .Q(\a[1][2] ), 
        .QN(n83) );
  DFFRX1 \a_reg[1][1]  ( .D(\a_nxt[1][1] ), .CK(clk), .RN(n185), .Q(\a[1][1] ), 
        .QN(n82) );
  DFFRX1 \a_reg[2][6]  ( .D(\a_nxt[2][6] ), .CK(clk), .RN(n185), .Q(\a[2][6] ), 
        .QN(n95) );
  DFFRX1 \a_reg[2][5]  ( .D(\a_nxt[2][5] ), .CK(clk), .RN(n185), .Q(\a[2][5] ), 
        .QN(n94) );
  DFFRX1 \a_reg[2][4]  ( .D(\a_nxt[2][4] ), .CK(clk), .RN(n185), .Q(\a[2][4] ), 
        .QN(n93) );
  DFFRX1 \a_reg[2][3]  ( .D(\a_nxt[2][3] ), .CK(clk), .RN(n184), .Q(\a[2][3] ), 
        .QN(n92) );
  DFFRX1 \a_reg[2][2]  ( .D(\a_nxt[2][2] ), .CK(clk), .RN(n184), .Q(\a[2][2] ), 
        .QN(n91) );
  DFFRX1 \a_reg[2][1]  ( .D(\a_nxt[2][1] ), .CK(clk), .RN(n184), .Q(\a[2][1] ), 
        .QN(n90) );
  DFFRX1 \a_reg[3][6]  ( .D(\a_nxt[3][6] ), .CK(clk), .RN(n184), .Q(\a[3][6] ), 
        .QN(n103) );
  DFFRX1 \a_reg[3][5]  ( .D(\a_nxt[3][5] ), .CK(clk), .RN(n184), .Q(\a[3][5] ), 
        .QN(n102) );
  DFFRX1 \a_reg[3][4]  ( .D(\a_nxt[3][4] ), .CK(clk), .RN(n184), .Q(\a[3][4] ), 
        .QN(n101) );
  DFFRX1 \a_reg[3][3]  ( .D(\a_nxt[3][3] ), .CK(clk), .RN(n184), .Q(\a[3][3] ), 
        .QN(n100) );
  DFFRX1 \a_reg[3][2]  ( .D(\a_nxt[3][2] ), .CK(clk), .RN(n184), .Q(\a[3][2] ), 
        .QN(n99) );
  DFFRX1 \a_reg[3][1]  ( .D(\a_nxt[3][1] ), .CK(clk), .RN(n184), .Q(\a[3][1] ), 
        .QN(n98) );
  DFFRX1 \a_reg[0][7]  ( .D(n152), .CK(clk), .RN(n186), .Q(\a[0][7] ), .QN(
        n144) );
  DFFRX1 \a_reg[1][7]  ( .D(\a_nxt[1][7] ), .CK(clk), .RN(n185), .Q(\a[1][7] ), 
        .QN(n88) );
  DFFRX1 \a_reg[2][7]  ( .D(\a_nxt[2][7] ), .CK(clk), .RN(n185), .Q(\a[2][7] ), 
        .QN(n96) );
  DFFRX1 \a_reg[3][7]  ( .D(\a_nxt[3][7] ), .CK(clk), .RN(n184), .Q(\a[3][7] ), 
        .QN(n104) );
  DFFRX1 \b_reg[0][6]  ( .D(\b_nxt[0][6] ), .CK(clk), .RN(n185), .Q(\b[0][6] ), 
        .QN(n111) );
  DFFRX1 \b_reg[0][5]  ( .D(\b_nxt[0][5] ), .CK(clk), .RN(n184), .Q(\b[0][5] ), 
        .QN(n110) );
  DFFRX1 \b_reg[0][4]  ( .D(\b_nxt[0][4] ), .CK(clk), .RN(n188), .Q(\b[0][4] ), 
        .QN(n109) );
  DFFRX1 \b_reg[0][3]  ( .D(\b_nxt[0][3] ), .CK(clk), .RN(n187), .Q(\b[0][3] ), 
        .QN(n108) );
  DFFRX1 \b_reg[0][2]  ( .D(\b_nxt[0][2] ), .CK(clk), .RN(n185), .Q(\b[0][2] ), 
        .QN(n107) );
  DFFRX1 \b_reg[0][1]  ( .D(\b_nxt[0][1] ), .CK(clk), .RN(n184), .Q(\b[0][1] ), 
        .QN(n106) );
  DFFRX1 \b_reg[1][6]  ( .D(\b_nxt[1][6] ), .CK(clk), .RN(n186), .Q(\b[1][6] ), 
        .QN(n119) );
  DFFRX1 \b_reg[1][5]  ( .D(\b_nxt[1][5] ), .CK(clk), .RN(n187), .Q(\b[1][5] ), 
        .QN(n118) );
  DFFRX1 \b_reg[1][4]  ( .D(\b_nxt[1][4] ), .CK(clk), .RN(n185), .Q(\b[1][4] ), 
        .QN(n117) );
  DFFRX1 \b_reg[1][3]  ( .D(\b_nxt[1][3] ), .CK(clk), .RN(n184), .Q(\b[1][3] ), 
        .QN(n116) );
  DFFRX1 \b_reg[1][2]  ( .D(\b_nxt[1][2] ), .CK(clk), .RN(n186), .Q(\b[1][2] ), 
        .QN(n115) );
  DFFRX1 \b_reg[1][1]  ( .D(\b_nxt[1][1] ), .CK(clk), .RN(n187), .Q(\b[1][1] ), 
        .QN(n114) );
  DFFRX1 \b_reg[2][6]  ( .D(\b_nxt[2][6] ), .CK(clk), .RN(n187), .Q(\b[2][6] ), 
        .QN(n127) );
  DFFRX1 \b_reg[2][5]  ( .D(\b_nxt[2][5] ), .CK(clk), .RN(n187), .Q(\b[2][5] ), 
        .QN(n126) );
  DFFRX1 \b_reg[2][4]  ( .D(\b_nxt[2][4] ), .CK(clk), .RN(n187), .Q(\b[2][4] ), 
        .QN(n125) );
  DFFRX1 \b_reg[2][3]  ( .D(\b_nxt[2][3] ), .CK(clk), .RN(n187), .Q(\b[2][3] ), 
        .QN(n124) );
  DFFRX1 \b_reg[2][2]  ( .D(\b_nxt[2][2] ), .CK(clk), .RN(n187), .Q(\b[2][2] ), 
        .QN(n123) );
  DFFRX1 \b_reg[2][1]  ( .D(\b_nxt[2][1] ), .CK(clk), .RN(n187), .Q(\b[2][1] ), 
        .QN(n122) );
  DFFRX1 \b_reg[3][6]  ( .D(\b_nxt[3][6] ), .CK(clk), .RN(n187), .Q(\b[3][6] ), 
        .QN(n135) );
  DFFRX1 \b_reg[3][5]  ( .D(\b_nxt[3][5] ), .CK(clk), .RN(n187), .Q(\b[3][5] ), 
        .QN(n134) );
  DFFRX1 \b_reg[3][4]  ( .D(\b_nxt[3][4] ), .CK(clk), .RN(n187), .Q(\b[3][4] ), 
        .QN(n133) );
  DFFRX1 \b_reg[3][3]  ( .D(\b_nxt[3][3] ), .CK(clk), .RN(n186), .Q(\b[3][3] ), 
        .QN(n132) );
  DFFRX1 \b_reg[3][2]  ( .D(\b_nxt[3][2] ), .CK(clk), .RN(n186), .Q(\b[3][2] ), 
        .QN(n131) );
  DFFRX1 \b_reg[3][1]  ( .D(\b_nxt[3][1] ), .CK(clk), .RN(n186), .Q(\b[3][1] ), 
        .QN(n130) );
  DFFRX1 \b_reg[0][0]  ( .D(\b_nxt[0][0] ), .CK(clk), .RN(n185), .Q(\b[0][0] ), 
        .QN(n105) );
  DFFRX1 \b_reg[1][0]  ( .D(\b_nxt[1][0] ), .CK(clk), .RN(n184), .Q(\b[1][0] ), 
        .QN(n113) );
  DFFRX1 \b_reg[2][0]  ( .D(\b_nxt[2][0] ), .CK(clk), .RN(n187), .Q(\b[2][0] ), 
        .QN(n121) );
  DFFRX1 \b_reg[3][0]  ( .D(\b_nxt[3][0] ), .CK(clk), .RN(n186), .Q(\b[3][0] ), 
        .QN(n129) );
  DFFRX1 \a_reg[0][0]  ( .D(n145), .CK(clk), .RN(n186), .Q(\a[0][0] ), .QN(
        n137) );
  DFFRX1 \a_reg[1][0]  ( .D(\a_nxt[1][0] ), .CK(clk), .RN(n185), .Q(\a[1][0] ), 
        .QN(n81) );
  DFFRX1 \a_reg[2][0]  ( .D(\a_nxt[2][0] ), .CK(clk), .RN(n184), .Q(\a[2][0] ), 
        .QN(n89) );
  DFFRX1 \a_reg[3][0]  ( .D(\a_nxt[3][0] ), .CK(clk), .RN(n184), .Q(\a[3][0] ), 
        .QN(n97) );
  DFFRX1 \b_reg[0][7]  ( .D(\b_nxt[0][7] ), .CK(clk), .RN(n187), .Q(\b[0][7] ), 
        .QN(n112) );
  DFFRX1 \b_reg[1][7]  ( .D(\b_nxt[1][7] ), .CK(clk), .RN(n187), .Q(\b[1][7] ), 
        .QN(n120) );
  DFFRX1 \b_reg[2][7]  ( .D(\b_nxt[2][7] ), .CK(clk), .RN(n187), .Q(\b[2][7] ), 
        .QN(n128) );
  DFFRX1 \b_reg[3][7]  ( .D(\b_nxt[3][7] ), .CK(clk), .RN(n187), .Q(\b[3][7] ), 
        .QN(n136) );
  DFFRX1 \state_reg[4]  ( .D(n157), .CK(clk), .RN(n186), .Q(state[4]), .QN(
        n160) );
  DFFRX1 \state_reg[3]  ( .D(n154), .CK(clk), .RN(n185), .Q(state[3]), .QN(
        n161) );
  DFFRX1 \state_reg[1]  ( .D(n156), .CK(clk), .RN(n184), .Q(state[1]), .QN(
        n216) );
  DFFRX2 \state_reg[0]  ( .D(n158), .CK(clk), .RN(n186), .Q(state[0]), .QN(
        n208) );
  NOR3X1 U164 ( .A(state[3]), .B(state[4]), .C(state[1]), .Y(n46) );
  CLKINVX1 U165 ( .A(n227), .Y(n204) );
  AOI22X1 U166 ( .A0(\y[1][0] ), .A1(n180), .B0(\y[2][0] ), .B1(n211), .Y(n69)
         );
  AOI22X1 U167 ( .A0(\y[1][1] ), .A1(n180), .B0(\y[2][1] ), .B1(n211), .Y(n67)
         );
  AOI22X1 U168 ( .A0(\y[1][2] ), .A1(n180), .B0(\y[2][2] ), .B1(n211), .Y(n65)
         );
  AOI22X1 U169 ( .A0(\y[1][3] ), .A1(n180), .B0(\y[2][3] ), .B1(n211), .Y(n63)
         );
  AOI22X1 U170 ( .A0(\y[1][4] ), .A1(n180), .B0(\y[2][4] ), .B1(n211), .Y(n61)
         );
  AOI22X1 U171 ( .A0(\y[0][5] ), .A1(n210), .B0(\y[3][5] ), .B1(n182), .Y(n60)
         );
  AOI22X1 U172 ( .A0(\y[0][6] ), .A1(n210), .B0(\y[3][6] ), .B1(n182), .Y(n58)
         );
  AOI22X1 U173 ( .A0(\y[0][8] ), .A1(n210), .B0(\y[3][8] ), .B1(n182), .Y(n52)
         );
  AND2X2 U174 ( .A(n51), .B(n52), .Y(n217) );
  INVX12 U175 ( .A(n217), .Y(dataout[8]) );
  AOI22X1 U176 ( .A0(\y[1][8] ), .A1(n180), .B0(\y[2][8] ), .B1(n211), .Y(n51)
         );
  AND2X2 U177 ( .A(n55), .B(n56), .Y(n218) );
  INVX12 U178 ( .A(n218), .Y(dataout[7]) );
  AOI22XL U179 ( .A0(\y[0][7] ), .A1(n210), .B0(\y[3][7] ), .B1(n182), .Y(n56)
         );
  AOI22X1 U180 ( .A0(\y[1][7] ), .A1(n180), .B0(\y[2][7] ), .B1(n211), .Y(n55)
         );
  AND2X2 U181 ( .A(n57), .B(n58), .Y(n219) );
  INVX12 U182 ( .A(n219), .Y(dataout[6]) );
  AOI22X1 U183 ( .A0(\y[1][6] ), .A1(n180), .B0(\y[2][6] ), .B1(n211), .Y(n57)
         );
  AND2X2 U184 ( .A(n59), .B(n60), .Y(n220) );
  INVX12 U185 ( .A(n220), .Y(dataout[5]) );
  AOI22X1 U186 ( .A0(\y[1][5] ), .A1(n180), .B0(\y[2][5] ), .B1(n211), .Y(n59)
         );
  AND2X2 U187 ( .A(n61), .B(n62), .Y(n221) );
  INVX12 U188 ( .A(n221), .Y(dataout[4]) );
  AOI22XL U189 ( .A0(\y[0][4] ), .A1(n210), .B0(\y[3][4] ), .B1(n182), .Y(n62)
         );
  AND2X2 U190 ( .A(n63), .B(n64), .Y(n222) );
  INVX12 U191 ( .A(n222), .Y(dataout[3]) );
  AOI22XL U192 ( .A0(\y[0][3] ), .A1(n210), .B0(\y[3][3] ), .B1(n182), .Y(n64)
         );
  AND2X2 U193 ( .A(n65), .B(n66), .Y(n223) );
  INVX12 U194 ( .A(n223), .Y(dataout[2]) );
  AOI22XL U195 ( .A0(\y[0][2] ), .A1(n210), .B0(\y[3][2] ), .B1(n182), .Y(n66)
         );
  AND2X2 U196 ( .A(n67), .B(n68), .Y(n224) );
  INVX12 U197 ( .A(n224), .Y(dataout[1]) );
  AOI22XL U198 ( .A0(\y[0][1] ), .A1(n210), .B0(\y[3][1] ), .B1(n182), .Y(n68)
         );
  AND2X2 U199 ( .A(n69), .B(n70), .Y(n225) );
  INVX12 U200 ( .A(n225), .Y(dataout[0]) );
  AOI22XL U201 ( .A0(\y[0][0] ), .A1(n210), .B0(\y[3][0] ), .B1(n182), .Y(n70)
         );
  AND4X1 U202 ( .A(n201), .B(n47), .C(n20), .D(n24), .Y(n226) );
  INVX12 U203 ( .A(n226), .Y(output_valid) );
  INVX12 U204 ( .A(n204), .Y(busy) );
  NAND2X1 U205 ( .A(n46), .B(n207), .Y(n227) );
  NOR4X1 U206 ( .A(n160), .B(n33), .C(state[1]), .D(state[3]), .Y(n16) );
  NOR3X1 U207 ( .A(state[1]), .B(state[4]), .C(n161), .Y(n71) );
  NAND2X1 U208 ( .A(state[0]), .B(n215), .Y(n24) );
  NAND2X1 U209 ( .A(n71), .B(state[0]), .Y(n20) );
  CLKBUFX3 U210 ( .A(n1), .Y(n181) );
  NOR3X1 U211 ( .A(state[3]), .B(state[4]), .C(n216), .Y(n76) );
  CLKBUFX3 U212 ( .A(n30), .Y(n176) );
  CLKBUFX3 U213 ( .A(n42), .Y(n174) );
  CLKBUFX3 U214 ( .A(n19), .Y(n178) );
  CLKINVX1 U215 ( .A(n33), .Y(n207) );
  CLKINVX1 U216 ( .A(n180), .Y(n201) );
  CLKBUFX3 U217 ( .A(n199), .Y(n182) );
  CLKINVX1 U218 ( .A(n47), .Y(n199) );
  CLKINVX1 U219 ( .A(n18), .Y(n200) );
  INVX3 U220 ( .A(n179), .Y(n205) );
  INVX3 U221 ( .A(n173), .Y(n206) );
  INVX3 U222 ( .A(n177), .Y(n202) );
  INVX3 U223 ( .A(n175), .Y(n203) );
  CLKBUFX3 U224 ( .A(n188), .Y(n184) );
  CLKBUFX3 U225 ( .A(n188), .Y(n185) );
  CLKBUFX3 U226 ( .A(n188), .Y(n186) );
  CLKBUFX3 U227 ( .A(n188), .Y(n187) );
  AOI31X1 U228 ( .A0(n71), .A1(n208), .A2(n183), .B0(n16), .Y(n47) );
  NAND2X1 U229 ( .A(n159), .B(n208), .Y(n33) );
  INVX3 U230 ( .A(n24), .Y(n211) );
  INVX3 U231 ( .A(n20), .Y(n210) );
  NAND3X1 U232 ( .A(n215), .B(n208), .C(n183), .Y(n23) );
  CLKINVX1 U233 ( .A(n32), .Y(n215) );
  CLKBUFX3 U234 ( .A(n48), .Y(n180) );
  OAI21XL U235 ( .A0(n32), .A1(n33), .B0(n23), .Y(n48) );
  OAI32XL U236 ( .A0(n197), .A1(n227), .A2(n11), .B0(n160), .B1(n18), .Y(n157)
         );
  NOR2X1 U237 ( .A(n11), .B(n12), .Y(n154) );
  NOR4X1 U238 ( .A(n13), .B(n14), .C(n211), .D(n16), .Y(n12) );
  OAI21XL U239 ( .A0(n161), .A1(n18), .B0(n178), .Y(n14) );
  OAI221XL U240 ( .A0(n183), .A1(n20), .B0(n227), .B1(n198), .C0(n201), .Y(n13) );
  NAND4X1 U241 ( .A(n176), .B(n174), .C(n179), .D(n44), .Y(n18) );
  NOR3XL U242 ( .A(n212), .B(output_valid), .C(n209), .Y(n44) );
  NAND4BX1 U243 ( .AN(n16), .B(n23), .C(n24), .D(n25), .Y(n155) );
  AOI211X1 U244 ( .A0(n200), .A1(n183), .B0(n214), .C0(n213), .Y(n25) );
  NOR3X1 U245 ( .A(n206), .B(n16), .C(n202), .Y(n35) );
  CLKBUFX3 U246 ( .A(n77), .Y(n177) );
  NAND3X1 U247 ( .A(n183), .B(n208), .C(n76), .Y(n77) );
  CLKBUFX3 U248 ( .A(n78), .Y(n175) );
  NAND3X1 U249 ( .A(n183), .B(n208), .C(n46), .Y(n78) );
  CLKBUFX3 U250 ( .A(n79), .Y(n173) );
  NAND2X1 U251 ( .A(n76), .B(n207), .Y(n79) );
  INVX3 U252 ( .A(n178), .Y(n212) );
  INVX3 U253 ( .A(n181), .Y(n209) );
  CLKBUFX3 U254 ( .A(n43), .Y(n179) );
  NAND2X1 U255 ( .A(n71), .B(n207), .Y(n43) );
  INVX3 U256 ( .A(n176), .Y(n213) );
  INVX3 U257 ( .A(n174), .Y(n214) );
  NAND3X1 U258 ( .A(state[1]), .B(n160), .C(state[3]), .Y(n32) );
  CLKBUFX3 U259 ( .A(state[2]), .Y(n183) );
  INVX3 U260 ( .A(datain[0]), .Y(n196) );
  INVX3 U261 ( .A(datain[1]), .Y(n195) );
  INVX3 U262 ( .A(datain[2]), .Y(n194) );
  INVX3 U263 ( .A(datain[3]), .Y(n193) );
  INVX3 U264 ( .A(datain[4]), .Y(n192) );
  INVX3 U265 ( .A(datain[5]), .Y(n191) );
  INVX3 U266 ( .A(datain[6]), .Y(n190) );
  INVX3 U267 ( .A(datain[7]), .Y(n189) );
  AOI31X1 U268 ( .A0(n35), .A1(n201), .A2(n38), .B0(n11), .Y(n158) );
  AOI221XL U269 ( .A0(n204), .A1(n197), .B0(n200), .B1(state[0]), .C0(n203), 
        .Y(n38) );
  OAI22XL U270 ( .A0(n97), .A1(n203), .B0(n196), .B1(n175), .Y(\a_nxt[3][0] )
         );
  OAI22XL U271 ( .A0(n98), .A1(n203), .B0(n195), .B1(n175), .Y(\a_nxt[3][1] )
         );
  OAI22XL U272 ( .A0(n99), .A1(n203), .B0(n194), .B1(n175), .Y(\a_nxt[3][2] )
         );
  OAI22XL U273 ( .A0(n100), .A1(n203), .B0(n193), .B1(n175), .Y(\a_nxt[3][3] )
         );
  OAI22XL U274 ( .A0(n101), .A1(n203), .B0(n192), .B1(n175), .Y(\a_nxt[3][4] )
         );
  OAI22XL U275 ( .A0(n102), .A1(n203), .B0(n191), .B1(n175), .Y(\a_nxt[3][5] )
         );
  OAI22XL U276 ( .A0(n103), .A1(n203), .B0(n190), .B1(n175), .Y(\a_nxt[3][6] )
         );
  OAI22XL U277 ( .A0(n104), .A1(n203), .B0(n189), .B1(n175), .Y(\a_nxt[3][7] )
         );
  OAI22XL U278 ( .A0(n89), .A1(n214), .B0(n196), .B1(n174), .Y(\a_nxt[2][0] )
         );
  OAI22XL U279 ( .A0(n90), .A1(n214), .B0(n195), .B1(n174), .Y(\a_nxt[2][1] )
         );
  OAI22XL U280 ( .A0(n91), .A1(n214), .B0(n194), .B1(n174), .Y(\a_nxt[2][2] )
         );
  OAI22XL U281 ( .A0(n92), .A1(n214), .B0(n193), .B1(n174), .Y(\a_nxt[2][3] )
         );
  OAI22XL U282 ( .A0(n93), .A1(n214), .B0(n192), .B1(n174), .Y(\a_nxt[2][4] )
         );
  OAI22XL U283 ( .A0(n94), .A1(n214), .B0(n191), .B1(n174), .Y(\a_nxt[2][5] )
         );
  OAI22XL U284 ( .A0(n95), .A1(n214), .B0(n190), .B1(n174), .Y(\a_nxt[2][6] )
         );
  OAI22XL U285 ( .A0(n96), .A1(n214), .B0(n189), .B1(n174), .Y(\a_nxt[2][7] )
         );
  OAI22XL U286 ( .A0(n81), .A1(n206), .B0(n196), .B1(n173), .Y(\a_nxt[1][0] )
         );
  OAI22XL U287 ( .A0(n82), .A1(n206), .B0(n195), .B1(n173), .Y(\a_nxt[1][1] )
         );
  OAI22XL U288 ( .A0(n83), .A1(n206), .B0(n194), .B1(n173), .Y(\a_nxt[1][2] )
         );
  OAI22XL U289 ( .A0(n84), .A1(n206), .B0(n193), .B1(n173), .Y(\a_nxt[1][3] )
         );
  OAI22XL U290 ( .A0(n85), .A1(n206), .B0(n192), .B1(n173), .Y(\a_nxt[1][4] )
         );
  OAI22XL U291 ( .A0(n86), .A1(n206), .B0(n191), .B1(n173), .Y(\a_nxt[1][5] )
         );
  OAI22XL U292 ( .A0(n87), .A1(n206), .B0(n190), .B1(n173), .Y(\a_nxt[1][6] )
         );
  OAI22XL U293 ( .A0(n88), .A1(n206), .B0(n189), .B1(n173), .Y(\a_nxt[1][7] )
         );
  OAI22XL U294 ( .A0(n129), .A1(n205), .B0(n196), .B1(n179), .Y(\b_nxt[3][0] )
         );
  OAI22XL U295 ( .A0(n130), .A1(n205), .B0(n195), .B1(n179), .Y(\b_nxt[3][1] )
         );
  OAI22XL U296 ( .A0(n131), .A1(n205), .B0(n194), .B1(n179), .Y(\b_nxt[3][2] )
         );
  OAI22XL U297 ( .A0(n132), .A1(n205), .B0(n193), .B1(n179), .Y(\b_nxt[3][3] )
         );
  OAI22XL U298 ( .A0(n133), .A1(n205), .B0(n192), .B1(n179), .Y(\b_nxt[3][4] )
         );
  OAI22XL U299 ( .A0(n134), .A1(n205), .B0(n191), .B1(n179), .Y(\b_nxt[3][5] )
         );
  OAI22XL U300 ( .A0(n135), .A1(n205), .B0(n190), .B1(n179), .Y(\b_nxt[3][6] )
         );
  OAI22XL U301 ( .A0(n136), .A1(n205), .B0(n189), .B1(n179), .Y(\b_nxt[3][7] )
         );
  OAI22XL U302 ( .A0(n121), .A1(n212), .B0(n196), .B1(n178), .Y(\b_nxt[2][0] )
         );
  OAI22XL U303 ( .A0(n122), .A1(n212), .B0(n195), .B1(n178), .Y(\b_nxt[2][1] )
         );
  OAI22XL U304 ( .A0(n123), .A1(n212), .B0(n194), .B1(n178), .Y(\b_nxt[2][2] )
         );
  OAI22XL U305 ( .A0(n124), .A1(n212), .B0(n193), .B1(n178), .Y(\b_nxt[2][3] )
         );
  OAI22XL U306 ( .A0(n125), .A1(n212), .B0(n192), .B1(n178), .Y(\b_nxt[2][4] )
         );
  OAI22XL U307 ( .A0(n126), .A1(n212), .B0(n191), .B1(n178), .Y(\b_nxt[2][5] )
         );
  OAI22XL U308 ( .A0(n127), .A1(n212), .B0(n190), .B1(n178), .Y(\b_nxt[2][6] )
         );
  OAI22XL U309 ( .A0(n128), .A1(n212), .B0(n189), .B1(n178), .Y(\b_nxt[2][7] )
         );
  OAI22XL U310 ( .A0(n113), .A1(n202), .B0(n196), .B1(n177), .Y(\b_nxt[1][0] )
         );
  OAI22XL U311 ( .A0(n114), .A1(n202), .B0(n195), .B1(n177), .Y(\b_nxt[1][1] )
         );
  OAI22XL U312 ( .A0(n115), .A1(n202), .B0(n194), .B1(n177), .Y(\b_nxt[1][2] )
         );
  OAI22XL U313 ( .A0(n116), .A1(n202), .B0(n193), .B1(n177), .Y(\b_nxt[1][3] )
         );
  OAI22XL U314 ( .A0(n117), .A1(n202), .B0(n192), .B1(n177), .Y(\b_nxt[1][4] )
         );
  OAI22XL U315 ( .A0(n118), .A1(n202), .B0(n191), .B1(n177), .Y(\b_nxt[1][5] )
         );
  OAI22XL U316 ( .A0(n119), .A1(n202), .B0(n190), .B1(n177), .Y(\b_nxt[1][6] )
         );
  OAI22XL U317 ( .A0(n120), .A1(n202), .B0(n189), .B1(n177), .Y(\b_nxt[1][7] )
         );
  OAI22XL U318 ( .A0(n105), .A1(n213), .B0(n196), .B1(n176), .Y(\b_nxt[0][0] )
         );
  OAI22XL U319 ( .A0(n106), .A1(n213), .B0(n195), .B1(n176), .Y(\b_nxt[0][1] )
         );
  OAI22XL U320 ( .A0(n107), .A1(n213), .B0(n194), .B1(n176), .Y(\b_nxt[0][2] )
         );
  OAI22XL U321 ( .A0(n108), .A1(n213), .B0(n193), .B1(n176), .Y(\b_nxt[0][3] )
         );
  OAI22XL U322 ( .A0(n109), .A1(n213), .B0(n192), .B1(n176), .Y(\b_nxt[0][4] )
         );
  OAI22XL U323 ( .A0(n110), .A1(n213), .B0(n191), .B1(n176), .Y(\b_nxt[0][5] )
         );
  OAI22XL U324 ( .A0(n111), .A1(n213), .B0(n190), .B1(n176), .Y(\b_nxt[0][6] )
         );
  OAI22XL U325 ( .A0(n112), .A1(n213), .B0(n189), .B1(n176), .Y(\b_nxt[0][7] )
         );
  OAI22XL U326 ( .A0(n181), .A1(n196), .B0(n137), .B1(n209), .Y(n145) );
  OAI22XL U327 ( .A0(n181), .A1(n195), .B0(n138), .B1(n209), .Y(n146) );
  OAI22XL U328 ( .A0(n181), .A1(n194), .B0(n139), .B1(n209), .Y(n147) );
  OAI22XL U329 ( .A0(n181), .A1(n193), .B0(n140), .B1(n209), .Y(n148) );
  OAI22XL U330 ( .A0(n181), .A1(n192), .B0(n141), .B1(n209), .Y(n149) );
  OAI22XL U331 ( .A0(n181), .A1(n191), .B0(n142), .B1(n209), .Y(n150) );
  OAI22XL U332 ( .A0(n181), .A1(n190), .B0(n143), .B1(n209), .Y(n151) );
  OAI22XL U333 ( .A0(n181), .A1(n189), .B0(n144), .B1(n209), .Y(n152) );
  AND2X2 U334 ( .A(n39), .B(n204), .Y(n11) );
  OAI21XL U335 ( .A0(n198), .A1(n197), .B0(cmd_valid), .Y(n39) );
  CLKINVX1 U336 ( .A(cmd[1]), .Y(n197) );
  CLKINVX1 U337 ( .A(cmd[0]), .Y(n198) );
  NAND4BX1 U338 ( .AN(n29), .B(n176), .C(n181), .D(n31), .Y(n156) );
  OAI221XL U339 ( .A0(n20), .A1(n183), .B0(n24), .B1(n159), .C0(n35), .Y(n29)
         );
  AOI2BB2X1 U340 ( .B0(n200), .B1(state[1]), .A0N(n32), .A1N(n33), .Y(n31) );
  NAND3X1 U341 ( .A(n183), .B(state[0]), .C(n46), .Y(n30) );
  NAND3X1 U342 ( .A(state[0]), .B(n159), .C(n76), .Y(n42) );
  NAND3X1 U343 ( .A(state[0]), .B(n159), .C(n46), .Y(n1) );
  NAND3X1 U344 ( .A(n183), .B(state[0]), .C(n76), .Y(n19) );
  CLKINVX1 U345 ( .A(reset), .Y(n188) );
endmodule

