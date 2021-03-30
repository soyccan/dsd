// RTL (procedural assignment) 
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  signed [7:0] x;
    input  signed [7:0] y;
    output reg carry;
    output reg [7:0] out;
    
    always @* begin
        carry = 1'b0;
        out = 8'd0;
        case (ctrl)
            4'b0000: {carry, out} = x + y;
            4'b0001: {carry, out} = x - y;
            4'b0010: out = x & y;
            4'b0011: out = x | y;
            4'b0100: out = ~x;
            4'b0101: out = x ^ y;
            4'b0110: out = ~(x | y);
            4'b0111: out = y << x[2:0];
            4'b1000: out = y >> x[2:0];
            4'b1001: out = { x[7], x[7:1] }; // shift 1 right arithmetic
            4'b1010: out = { x[6:0], x[7] }; // rotate 1 left
            4'b1011: out = { x[0], x[7:1] }; // rotate 1 right
            4'b1100: out = (x == y) ? 8'd1 : 8'd0;
            default: out = 8'd0;
        endcase
    end

endmodule
