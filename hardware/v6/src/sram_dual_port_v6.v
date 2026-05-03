module sram_dual_port_v6 (
    input  wire        clk, rst_n,
    input  wire        bank_sel,
    input  wire [13:0] a_addr,
    output reg  signed [7:0] a_rdata,
    input  wire [13:0] b_addr,
    input  wire signed [7:0] b_wdata,
    input  wire        b_we,
    output reg  signed [7:0] b_rdata,
    output wire        bank_a_active,
    output wire        bank_b_active
);
    reg signed [7:0] bank_a [0:16383];
    reg signed [7:0] bank_b [0:16383];
    integer i;
    initial begin
        for (i = 0; i < 16384; i = i + 1) begin
            bank_a[i] = 8'sd0;
            bank_b[i] = 8'sd0;
        end
    end
    assign bank_a_active = ~bank_sel;
    assign bank_b_active =  bank_sel;
    always @(posedge clk) begin
        if (!bank_sel) a_rdata <= bank_a[a_addr];
        else           a_rdata <= bank_b[a_addr];
    end
    always @(posedge clk) begin
        if (!bank_sel) begin
            if (b_we) bank_b[b_addr] <= b_wdata;
            b_rdata <= bank_b[b_addr];
        end else begin
            if (b_we) bank_a[b_addr] <= b_wdata;
            b_rdata <= bank_a[b_addr];
        end
    end
endmodule
