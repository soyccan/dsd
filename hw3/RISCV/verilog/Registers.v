module Registers(input clk_i,
                 input rst_i,
                 input [4:0] RS1addr_i,
                 input [4:0] RS2addr_i,
                 input [4:0] RDaddr_i,
                 input [31:0] RDdata_i,
                 input RegWrite_i,
                 output [31:0] RS1data_o,
                 output [31:0] RS2data_o);

integer i;

// Register File
reg [31:0] register [0:31];

// Read Data
// assign RS1data_o = RS1addr_i == 0                      ? 0 :
//                    RS1addr_i == RDaddr_i && RegWrite_i ? RDdata_i :
//                                                          register[RS1addr_i];
// assign RS2data_o = RS2addr_i == 0                      ? 0 :
//                    RS2addr_i == RDaddr_i && RegWrite_i ? RDdata_i :
//                                                          register[RS2addr_i];
assign RS1data_o = RS1addr_i == 0 ? 32'b0 : register[RS1addr_i];
assign RS2data_o = RS2addr_i == 0 ? 32'b0 : register[RS2addr_i];

// Write Data
always @(posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i < 32; i = i + 1) begin
            register[i] <= 0;
        end
    end
    else if (RegWrite_i && RDaddr_i != 0) begin
        register[RDaddr_i] <= RDdata_i;
    end
end

endmodule
