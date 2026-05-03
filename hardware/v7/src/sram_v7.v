module sram_v7 (
    input  wire        clk, rst_n,
    input  wire [1:0]  active_bank,
    input  wire [13:0] a_addr,
    output reg  signed [7:0] a_rdata,
    input  wire [1:0]  b_bank_sel,
    input  wire [13:0] b_addr,
    input  wire signed [7:0] b_wdata,
    input  wire        b_we,
    output reg  signed [7:0] b_rdata
);
    // 4 banks x 16KB = 64KB total
    // manageable for sky130 synthesis
    reg signed [7:0] bank0 [0:16383];
    reg signed [7:0] bank1 [0:16383];
    reg signed [7:0] bank2 [0:16383];
    reg signed [7:0] bank3 [0:16383];

    integer i;
    initial begin
        for (i = 0; i < 16384; i = i + 1) begin
            bank0[i] = 8'sd0; bank1[i] = 8'sd0;
            bank2[i] = 8'sd0; bank3[i] = 8'sd0;
        end
    end

    always @(posedge clk) begin
        case (active_bank)
            2'd0: a_rdata <= bank0[a_addr];
            2'd1: a_rdata <= bank1[a_addr];
            2'd2: a_rdata <= bank2[a_addr];
            2'd3: a_rdata <= bank3[a_addr];
        endcase
    end

    always @(posedge clk) begin
        case (b_bank_sel)
            2'd0: begin
                if (b_we) bank0[b_addr] <= b_wdata;
                b_rdata <= bank0[b_addr];
            end
            2'd1: begin
                if (b_we) bank1[b_addr] <= b_wdata;
                b_rdata <= bank1[b_addr];
            end
            2'd2: begin
                if (b_we) bank2[b_addr] <= b_wdata;
                b_rdata <= bank2[b_addr];
            end
            2'd3: begin
                if (b_we) bank3[b_addr] <= b_wdata;
                b_rdata <= bank3[b_addr];
            end
        endcase
    end
endmodule
