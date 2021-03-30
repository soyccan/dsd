module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input  Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output reg [7:0] busX, busY;
    
// write your design here, you can delcare your own wires and regs. 
// The code below is just an eaxmple template
reg [7:0] nxt_reg[0:7];
reg [7:0] _reg[0:7];

integer i;

always @* begin

    busX = _reg[RX];
    busY = _reg[RY];

    for (i = 0; i < 8; i = i + 1) begin
        nxt_reg[i] = _reg[i];
    end

    if (WEN && RW != 0) begin
        nxt_reg[RW] = busW;
    end

end

always @(posedge Clk) begin
    for (i = 0; i < 8; i = i + 1) begin
        _reg[i] <= nxt_reg[i];
    end
end 

endmodule
