module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
wire [7:0] alu_x;
wire [7:0] alu_y;
wire [7:0] alu_out;
wire [7:0] busW;
wire [7:0] busX;
wire [7:0] busY;
wire carry;
    
// submodule instantiation
register_file rf(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);

assign alu_x = Sel ? busX : DataIn;

assign alu_y = busY;

alu_always alu(
    Ctrl,
    alu_x,
    alu_y,
    carry,
    alu_out
);

assign busW = alu_out;



endmodule
