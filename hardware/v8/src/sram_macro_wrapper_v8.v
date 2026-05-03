// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — SRAM Macro Wrapper
//  sram_macro_wrapper_v8.v
//
//  Wrapper for foundry 2MB SRAM macro
//  On sky130 prototype: uses 4 x 16KB banks = 64KB
//  On 28nm production: replace with foundry 2MB macro
//  Same interface either way — top level unchanged
// ═══════════════════════════════════════════════════════
module sram_macro_wrapper_v8 (
    input  wire        clk, rst_n,
    input  wire        mem_mode,     // 0=inference 1=training
    input  wire [1:0]  active_bank,
    // Port A read — compute chiplet reads
    input  wire [13:0] a_addr,
    output reg  signed [7:0] a_rdata,
    // Port B write — DMA loads weights
    input  wire [1:0]  b_bank_sel,
    input  wire [13:0] b_addr,
    input  wire signed [7:0] b_wdata,
    input  wire        b_we,
    output reg  signed [7:0] b_rdata,
    // training partition ports
    input  wire [13:0] grad_addr,
    input  wire signed [15:0] grad_wdata,
    input  wire        grad_we,
    output reg  signed [15:0] grad_rdata
);
    // 4 x 16KB banks = 64KB for sky130 prototype
    reg signed [7:0] bank0 [0:16383];
    reg signed [7:0] bank1 [0:16383];
    reg signed [7:0] bank2 [0:16383];
    reg signed [7:0] bank3 [0:16383];
    // gradient buffer — 1024 x INT16 = 2KB
    reg signed [15:0] grad_buf [0:1023];

    integer i;
    initial begin
        for (i=0; i<16384; i=i+1) begin
            bank0[i]=0; bank1[i]=0;
            bank2[i]=0; bank3[i]=0;
        end
        for (i=0; i<1024; i=i+1)
            grad_buf[i]=0;
    end

    // Port A — compute reads active bank
    always @(posedge clk) begin
        case (active_bank)
            2'd0: a_rdata <= bank0[a_addr];
            2'd1: a_rdata <= bank1[a_addr];
            2'd2: a_rdata <= bank2[a_addr];
            2'd3: a_rdata <= bank3[a_addr];
        endcase
    end

    // Port B — DMA writes inactive bank
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

    // gradient buffer port
    always @(posedge clk) begin
        if (grad_we) grad_buf[grad_addr[9:0]] <= grad_wdata;
        grad_rdata <= grad_buf[grad_addr[9:0]];
    end
endmodule
