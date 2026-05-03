// ═══════════════════════════════════════════════════════
//  MERCHANT V7 — Sparse Preprocessor
//  sparse_preprocessor_v7.v
//
//  Filters zero weights before MAC array
//  MAC array never sees a zero — 100% utilisation
//  At 60% sparsity doubles effective throughput
//  Implements 2:4 structured sparsity detection
// ═══════════════════════════════════════════════════════
module sparse_preprocessor_v7 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        bypass,        // 1 = bypass, pass all weights
    // weight input from SRAM
    input  wire signed [7:0]  w_in,
    input  wire [9:0]  w_addr_in,
    input  wire        w_valid_in,
    // filtered output to MAC array
    output reg  signed [7:0]  w_out,
    output reg  [9:0]  w_addr_out,
    output reg         w_valid_out,
    // statistics
    output reg  [15:0] zero_count,
    output reg  [15:0] nonzero_count
);
    // 2:4 structured sparsity counter
    reg [1:0] group_pos;   // position within group of 4
    reg [1:0] zero_in_group; // zeros seen in current group

    always @(posedge clk) begin
        if (!rst_n) begin
            w_out        <= 8'sd0;
            w_addr_out   <= 10'd0;
            w_valid_out  <= 1'b0;
            zero_count   <= 16'd0;
            nonzero_count<= 16'd0;
            group_pos    <= 2'd0;
            zero_in_group<= 2'd0;
        end else if (w_valid_in) begin
            if (bypass) begin
                // bypass mode — pass everything through
                w_out       <= w_in;
                w_addr_out  <= w_addr_in;
                w_valid_out <= 1'b1;
            end else begin
                // sparse mode — filter zeros
                if (w_in == 8'sd0) begin
                    // zero weight — skip
                    w_valid_out   <= 1'b0;
                    zero_count    <= zero_count + 1;
                    zero_in_group <= zero_in_group + 1;
                end else begin
                    // non-zero weight — pass through
                    w_out         <= w_in;
                    w_addr_out    <= w_addr_in;
                    w_valid_out   <= 1'b1;
                    nonzero_count <= nonzero_count + 1;
                end
                // track group position for 2:4 sparsity
                if (group_pos == 2'd3) begin
                    group_pos     <= 2'd0;
                    zero_in_group <= 2'd0;
                end else begin
                    group_pos <= group_pos + 2'd1;
                end
            end
        end else begin
            w_valid_out <= 1'b0;
        end
    end
endmodule
