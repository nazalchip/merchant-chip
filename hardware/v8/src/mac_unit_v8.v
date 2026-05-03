// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — MAC Unit
//  mac_unit_v8.v
//
//  New in V8 vs V7:
//  - INT4 mode: two 4-bit weights per 8-bit register
//  - Output-stationary mode for transformer attention
//  - w_valid from sparse preprocessor
// ═══════════════════════════════════════════════════════
module mac_unit_v8 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mac_en,

    // precision mode
    input  wire        int4_mode,   // 0=INT8 1=INT4

    // output stationary mode for transformer
    input  wire        os_mode,     // 0=weight-stationary 1=output-stationary

    // operands
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        w_valid,     // from sparse preprocessor

    // control
    input  wire        acc_clear,
    input  wire        acc_en,

    // output
    output reg  signed [19:0] psum,
    output wire        skip_pulse
);
    // ── INT4 unpacking ────────────────────────────────
    // In INT4 mode weight register holds two 4-bit values
    // upper nibble [7:4] = even column weight
    // lower nibble [3:0] = odd column weight
    wire signed [7:0] w_int8 = int4_mode ?
        {{4{weight[7]}}, weight[7:4]} : weight;  // sign extend upper nibble

    // ── Zero skip detection ───────────────────────────
    wire zero_w = (w_int8    == 8'sd0);
    wire zero_a = (activation == 8'sd0);
    wire do_skip = (zero_w | zero_a | ~w_valid) & ~os_mode;
    // output-stationary mode never skips — both operands stream

    assign skip_pulse = do_skip & acc_en & mac_en;

    // ── Operand isolation ─────────────────────────────
    wire signed [7:0] w_iso = do_skip ? 8'sd0 : w_int8;
    wire signed [7:0] a_iso = do_skip ? 8'sd0 : activation;

    // ── Multiply ──────────────────────────────────────
    wire signed [15:0] product = w_iso * a_iso;

    // ── Accumulate ────────────────────────────────────
    always @(posedge clk) begin
        if (!rst_n) begin
            psum <= 20'sd0;
        end else if (mac_en) begin
            if (acc_clear) begin
                psum <= 20'sd0;
            end else if (acc_en) begin
                if (os_mode) begin
                    // output-stationary — always accumulate
                    // both Q and K stream through
                    psum <= psum + {{4{product[15]}}, product};
                end else if (!do_skip) begin
                    // weight-stationary — skip zeros
                    psum <= psum + {{4{product[15]}}, product};
                end
            end
        end
    end
endmodule
