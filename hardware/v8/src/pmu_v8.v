// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — Power Management Unit
//  pmu_v8.v
//  4 power domains + training mode + adaptive frequency
// ═══════════════════════════════════════════════════════
module pmu_v8 (
    input  wire        clk, rst_n,
    input  wire [1:0]  power_mode,   // 0=sleep 1=idle 2=infer 3=train
    input  wire        wake_sensor,
    input  wire        wake_uart,
    input  wire        infer_done,
    input  wire        train_done,
    input  wire        dma_done,
    input  wire [5:0]  periph_clk_en,
    output wire        clk_mac,
    output wire        clk_sram,
    output wire        clk_vu,
    output wire        clk_te,       // transformer engine
    output wire        clk_tr,       // training engine
    output wire        clk_uart,
    output wire        clk_spi,
    output wire        clk_i2c,
    output wire        clk_dma,
    output wire        clk_int,
    output wire        clk_wdt,
    output wire        power_ok,
    output reg         sram_write_en,
    output reg  [1:0]  volt_ctrl,
    output reg  [1:0]  active_bank,
    output wire        sleeping
);
    localparam SLEEP     = 2'd0;
    localparam IDLE      = 2'd1;
    localparam INFERENCE = 2'd2;
    localparam TRAINING  = 2'd3;

    reg [1:0] mode;
    assign sleeping = (mode == SLEEP);

    always @(posedge clk) begin
        if (!rst_n) begin
            mode          <= IDLE;
            sram_write_en <= 1;
            volt_ctrl     <= 2'd2;
            active_bank   <= 2'd0;
        end else begin
            // bank rotation on DMA done
            if (dma_done)
                active_bank <= active_bank + 2'd1;

            case (mode)
                SLEEP: begin
                    volt_ctrl     <= 2'd0;
                    sram_write_en <= 0;
                    if (wake_sensor || wake_uart)
                        mode <= IDLE;
                end
                IDLE: begin
                    volt_ctrl     <= 2'd1;
                    sram_write_en <= 1;
                    if      (power_mode == INFERENCE) mode <= INFERENCE;
                    else if (power_mode == TRAINING)  mode <= TRAINING;
                    else if (power_mode == SLEEP)     mode <= SLEEP;
                end
                INFERENCE: begin
                    volt_ctrl     <= 2'd2;
                    sram_write_en <= 0;
                    if (infer_done) mode <= IDLE;
                end
                TRAINING: begin
                    volt_ctrl     <= 2'd2;
                    sram_write_en <= 1;
                    if (train_done) mode <= IDLE;
                end
            endcase
        end
    end

    wire active   = (mode == INFERENCE);
    wire training = (mode == TRAINING);
    wire awake    = (mode != SLEEP);

    assign clk_mac  = active   ? clk : 1'b0;
    assign clk_sram = awake    ? clk : 1'b0;
    assign clk_vu   = active   ? clk : 1'b0;
    assign clk_te   = active   ? clk : 1'b0;
    assign clk_tr   = training ? clk : 1'b0;
    assign clk_uart = (awake && periph_clk_en[0]) ? clk : 1'b0;
    assign clk_spi  = (awake && periph_clk_en[1]) ? clk : 1'b0;
    assign clk_i2c  = (awake && periph_clk_en[2]) ? clk : 1'b0;
    assign clk_dma  = (awake && periph_clk_en[3]) ? clk : 1'b0;
    assign clk_int  = (awake && periph_clk_en[4]) ? clk : 1'b0;
    assign clk_wdt  = clk;
    assign power_ok = 1'b1;
endmodule
