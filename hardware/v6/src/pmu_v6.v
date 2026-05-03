module pmu_v6 (
    input  wire        clk, rst_n,
    input  wire        infer_active, dma_active,
    input  wire [5:0]  periph_clk_en,
    output wire        clk_mac, clk_sram,
    output wire        clk_uart, clk_spi, clk_i2c,
    output wire        clk_dma, clk_int, clk_wdt,
    output wire        power_ok,
    output reg         bank_sel,
    input  wire        dma_done
);
    assign clk_mac  = infer_active ? clk : 1'b0;
    assign clk_sram = clk;
    assign clk_uart = periph_clk_en[0] ? clk : 1'b0;
    assign clk_spi  = periph_clk_en[1] ? clk : 1'b0;
    assign clk_i2c  = periph_clk_en[2] ? clk : 1'b0;
    assign clk_dma  = periph_clk_en[3] ? clk : 1'b0;
    assign clk_int  = periph_clk_en[4] ? clk : 1'b0;
    assign clk_wdt  = periph_clk_en[5] ? clk : 1'b0;
    assign power_ok = 1'b1;
    always @(posedge clk) begin
        if (!rst_n) bank_sel <= 1'b0;
        else if (dma_done) bank_sel <= ~bank_sel;
    end
endmodule
