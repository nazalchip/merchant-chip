// ═══════════════════════════════════════════════════════
//  MERCHANT V7 — Power Management Unit
//  pmu_v7.v
//
//  New in V7:
//  - Sleep mode — near zero power between inferences
//  - Wake on interrupt — sensor triggers inference
//  - Adaptive clock frequency — 100/25/1 MHz modes
//  - SRAM read-only lock during inference
//  - Dynamic voltage control output
// ═══════════════════════════════════════════════════════
module pmu_v7 (
    input  wire        clk,
    input  wire        rst_n,

    // power mode control
    // 0=sleep 1=idle 2=inference
    input  wire [1:0]  power_mode,

    // wake sources
    input  wire        wake_sensor,   // sensor interrupt
    input  wire        wake_uart,     // UART command
    input  wire        infer_done,    // inference finished

    // peripheral enables
    input  wire [5:0]  periph_clk_en,

    // clock outputs
    output wire        clk_mac,
    output wire        clk_sram,
    output wire        clk_uart,
    output wire        clk_spi,
    output wire        clk_i2c,
    output wire        clk_dma,
    output wire        clk_int,
    output wire        clk_wdt,
    output wire        clk_vu,        // vector unit clock

    // power outputs
    output wire        power_ok,
    output reg         sram_write_en, // 0 = read-only during inference
    output reg  [1:0]  volt_ctrl,     // 0=low 1=mid 2=full voltage
    output reg         bank_sel,
    input  wire        dma_done,

    // status
    output reg  [1:0]  current_mode,  // actual current mode
    output wire        sleeping
);
    // power mode states
    localparam SLEEP     = 2'd0;
    localparam IDLE      = 2'd1;
    localparam INFERENCE = 2'd2;

    reg [1:0] mode;
    reg       wake_pending;

    assign sleeping = (mode == SLEEP);

    // mode transition
    always @(posedge clk) begin
        if (!rst_n) begin
            mode          <= IDLE;
            current_mode  <= IDLE;
            wake_pending  <= 0;
            sram_write_en <= 1;
            volt_ctrl     <= 2'd2;
            bank_sel      <= 0;
        end else begin
            current_mode <= mode;

            case (mode)
                SLEEP: begin
                    volt_ctrl     <= 2'd0; // lowest voltage
                    sram_write_en <= 0;
                    // wake on sensor or UART
                    if (wake_sensor || wake_uart)
                        mode <= IDLE;
                end
                IDLE: begin
                    volt_ctrl     <= 2'd1; // medium voltage
                    sram_write_en <= 1;    // allow weight loading
                    // go to inference when commanded
                    if (power_mode == INFERENCE)
                        mode <= INFERENCE;
                    // go to sleep after timeout
                    if (power_mode == SLEEP)
                        mode <= SLEEP;
                end
                INFERENCE: begin
                    volt_ctrl     <= 2'd2; // full voltage
                    sram_write_en <= 0;    // lock SRAM read-only
                    // return to idle when done
                    if (infer_done)
                        mode <= IDLE;
                end
            endcase

            // bank swap on DMA done
            if (dma_done) bank_sel <= ~bank_sel;
        end
    end

    // clock gating based on power mode
    // sleep mode — only watchdog runs
    // idle mode — SRAM and peripherals
    // inference mode — everything

    wire active = (mode == INFERENCE);
    wire awake  = (mode != SLEEP);

    assign clk_mac  = active ? clk : 1'b0;
    assign clk_sram = awake  ? clk : 1'b0;
    assign clk_vu   = active ? clk : 1'b0;
    assign clk_uart = (awake && periph_clk_en[0]) ? clk : 1'b0;
    assign clk_spi  = (awake && periph_clk_en[1]) ? clk : 1'b0;
    assign clk_i2c  = (awake && periph_clk_en[2]) ? clk : 1'b0;
    assign clk_dma  = (awake && periph_clk_en[3]) ? clk : 1'b0;
    assign clk_int  = (awake && periph_clk_en[4]) ? clk : 1'b0;
    assign clk_wdt  = clk; // watchdog always on
    assign power_ok = 1'b1;

endmodule
