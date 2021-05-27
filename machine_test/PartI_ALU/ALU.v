module ALU ( out , mode , in_a , in_b  );

input mode;
input  [7:0] in_a , in_b;
output [8:0] out;

assign out = mode ? {in_a[7], in_a} + {in_b[7], in_b} :
                    in_a + in_b;


endmodule
