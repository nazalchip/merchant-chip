// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — Transformer Engine
//  transformer_engine_v8.v
//
//  Hardware QKV attention mechanism
//  States: IDLE -> QKV_PROJ -> ATTN_SCORE -> SOFTMAX
//          -> ATTN_OUT -> LAYER_NORM -> DONE
//  Uses MAC array in output-stationary mode for Q x K
// ═══════════════════════════════════════════════════════
module transformer_engine_v8 (
    input  wire        clk, rst_n,
    input  wire        attn_en,
    input  wire [7:0]  seq_len,   // sequence length 1-32
    input  wire [7:0]  attn_dim,  // embedding dimension
    // attention scores from MAC array (Q x K result)
    input  wire signed [19:0] qk_0,  qk_1,  qk_2,  qk_3,
    input  wire signed [19:0] qk_4,  qk_5,  qk_6,  qk_7,
    input  wire signed [19:0] qk_8,  qk_9,  qk_10, qk_11,
    input  wire signed [19:0] qk_12, qk_13, qk_14, qk_15,
    input  wire signed [19:0] qk_16, qk_17, qk_18, qk_19,
    input  wire signed [19:0] qk_20, qk_21, qk_22, qk_23,
    input  wire signed [19:0] qk_24, qk_25, qk_26, qk_27,
    input  wire signed [19:0] qk_28, qk_29, qk_30, qk_31,
    // scaled scores to softmax
    output wire signed [7:0]  score_0,  score_1,  score_2,  score_3,
    output wire signed [7:0]  score_4,  score_5,  score_6,  score_7,
    output wire signed [7:0]  score_8,  score_9,  score_10, score_11,
    output wire signed [7:0]  score_12, score_13, score_14, score_15,
    output wire signed [7:0]  score_16, score_17, score_18, score_19,
    output wire signed [7:0]  score_20, score_21, score_22, score_23,
    output wire signed [7:0]  score_24, score_25, score_26, score_27,
    output wire signed [7:0]  score_28, score_29, score_30, score_31,
    // control outputs
    output reg         os_mode,    // tells MAC array to use output-stationary
    output reg         sm_en,      // enable softmax unit
    output reg         ln_en,      // enable layer norm unit
    output reg         attn_done,  // attention computation complete
    // state for debugging
    output reg  [2:0]  state_out
);
    // FSM states
    localparam IDLE       = 3'd0;
    localparam QKV_PROJ   = 3'd1;
    localparam ATTN_SCORE = 3'd2;
    localparam SOFTMAX    = 3'd3;
    localparam ATTN_OUT   = 3'd4;
    localparam LAYER_NORM = 3'd5;
    localparam DONE       = 3'd6;

    reg [2:0]  state;
    reg [7:0]  cycle_count;

    // scale Q x K scores by 1/sqrt(dim)
    // approximated as right shift
    // sqrt(32) ≈ 5.66, so shift by 2 (divide by 4) is close enough
    wire [3:0] scale_shift = (attn_dim > 8'd64) ? 4'd3 :
                             (attn_dim > 8'd16) ? 4'd2 : 4'd1;

    // scale and clamp QK products to INT8 for softmax
    function signed [7:0] scale_clamp;
        input signed [19:0] val;
        input [3:0] sh;
        reg signed [19:0] scaled;
        begin
            scaled = val >>> sh;
            if (scaled > 127)  scale_clamp = 8'sd127;
            else if (scaled < -128) scale_clamp = -8'sd128;
            else scale_clamp = scaled[7:0];
        end
    endfunction

    assign score_0  = scale_clamp(qk_0,  scale_shift);
    assign score_1  = scale_clamp(qk_1,  scale_shift);
    assign score_2  = scale_clamp(qk_2,  scale_shift);
    assign score_3  = scale_clamp(qk_3,  scale_shift);
    assign score_4  = scale_clamp(qk_4,  scale_shift);
    assign score_5  = scale_clamp(qk_5,  scale_shift);
    assign score_6  = scale_clamp(qk_6,  scale_shift);
    assign score_7  = scale_clamp(qk_7,  scale_shift);
    assign score_8  = scale_clamp(qk_8,  scale_shift);
    assign score_9  = scale_clamp(qk_9,  scale_shift);
    assign score_10 = scale_clamp(qk_10, scale_shift);
    assign score_11 = scale_clamp(qk_11, scale_shift);
    assign score_12 = scale_clamp(qk_12, scale_shift);
    assign score_13 = scale_clamp(qk_13, scale_shift);
    assign score_14 = scale_clamp(qk_14, scale_shift);
    assign score_15 = scale_clamp(qk_15, scale_shift);
    assign score_16 = scale_clamp(qk_16, scale_shift);
    assign score_17 = scale_clamp(qk_17, scale_shift);
    assign score_18 = scale_clamp(qk_18, scale_shift);
    assign score_19 = scale_clamp(qk_19, scale_shift);
    assign score_20 = scale_clamp(qk_20, scale_shift);
    assign score_21 = scale_clamp(qk_21, scale_shift);
    assign score_22 = scale_clamp(qk_22, scale_shift);
    assign score_23 = scale_clamp(qk_23, scale_shift);
    assign score_24 = scale_clamp(qk_24, scale_shift);
    assign score_25 = scale_clamp(qk_25, scale_shift);
    assign score_26 = scale_clamp(qk_26, scale_shift);
    assign score_27 = scale_clamp(qk_27, scale_shift);
    assign score_28 = scale_clamp(qk_28, scale_shift);
    assign score_29 = scale_clamp(qk_29, scale_shift);
    assign score_30 = scale_clamp(qk_30, scale_shift);
    assign score_31 = scale_clamp(qk_31, scale_shift);

    // FSM — controls attention pipeline
    always @(posedge clk) begin
        if (!rst_n) begin
            state       <= IDLE;
            os_mode     <= 0;
            sm_en       <= 0;
            ln_en       <= 0;
            attn_done   <= 0;
            cycle_count <= 0;
            state_out   <= IDLE;
        end else begin
            attn_done <= 0;
            case (state)
                IDLE: begin
                    os_mode <= 0; sm_en <= 0; ln_en <= 0;
                    if (attn_en) begin
                        state <= QKV_PROJ;
                        cycle_count <= 0;
                    end
                end
                QKV_PROJ: begin
                    // MAC array computes Q K V projections
                    // weight-stationary mode — normal operation
                    os_mode <= 0;
                    cycle_count <= cycle_count + 1;
                    if (cycle_count >= seq_len) begin
                        state <= ATTN_SCORE;
                        cycle_count <= 0;
                    end
                end
                ATTN_SCORE: begin
                    // MAC array computes Q x K in output-stationary
                    os_mode <= 1;
                    cycle_count <= cycle_count + 1;
                    if (cycle_count >= attn_dim) begin
                        state <= SOFTMAX;
                        cycle_count <= 0;
                        os_mode <= 0;
                    end
                end
                SOFTMAX: begin
                    // softmax unit processes scaled scores
                    sm_en <= 1;
                    cycle_count <= cycle_count + 1;
                    if (cycle_count >= 2) begin
                        state <= ATTN_OUT;
                        cycle_count <= 0;
                        sm_en <= 0;
                    end
                end
                ATTN_OUT: begin
                    // MAC array computes attn_weights x V
                    os_mode <= 0;
                    cycle_count <= cycle_count + 1;
                    if (cycle_count >= seq_len) begin
                        state <= LAYER_NORM;
                        cycle_count <= 0;
                    end
                end
                LAYER_NORM: begin
                    // layer norm on attention output
                    ln_en <= 1;
                    cycle_count <= cycle_count + 1;
                    if (cycle_count >= 4) begin
                        state <= DONE;
                        ln_en <= 0;
                    end
                end
                DONE: begin
                    attn_done <= 1;
                    state     <= IDLE;
                end
            endcase
            state_out <= state;
        end
    end
endmodule
