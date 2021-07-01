module RegFile(input clk_i,
               input rst_i,
               input [4:0] RS1addr_i,
               input [4:0] RS2addr_i,
               input [4:0] RDaddr_i,
               input [31:0] RDdata_i,
               input RegWrite_i,
               output reg [31:0] RS1data_o,
               output reg [31:0] RS2data_o);

integer i;

// Register File
// indexed like: x4 = register[~4] so that FF for x0 is saved
reg [31:0] register [0:30];

// Read Data
always @* begin
    if (RS1addr_i) begin
        if (RegWrite_i && RDaddr_i == RS1addr_i) begin
            RS1data_o = RDdata_i;
        end
        else begin
            RS1data_o = register[~RS1addr_i];
        end
    end
    else begin
        RS1data_o = 0;
    end

    if (RS2addr_i) begin
        if (RegWrite_i && RDaddr_i == RS2addr_i) begin
            RS2data_o = RDdata_i;
        end
        else begin
            RS2data_o = register[~RS2addr_i];
        end
    end
    else begin
        RS2data_o = 0;
    end
end

// Write Data
always @(posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i <= 30; i = i + 1) begin
            register[i] <= 32'b0;
        end
    end
    else if (RegWrite_i && RDaddr_i) begin
        register[~RDaddr_i] <= RDdata_i;
    end
end

endmodule
