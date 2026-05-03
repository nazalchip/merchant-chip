module watchdog_v6 (
    input  wire        clk, rst_n,
    input  wire [7:0]  wdt_kick,
    input  wire [15:0] wdt_timeout,
    output reg         wdt_reset
);
    reg [15:0] counter;
    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 16'd0; wdt_reset <= 1'b0;
        end else begin
            wdt_reset <= 1'b0;
            if (wdt_kick == 8'hAB) counter <= 16'd0;
            else begin
                counter <= counter + 1;
                if (counter >= wdt_timeout) begin
                    wdt_reset <= 1'b1;
                    counter   <= 16'd0;
                end
            end
        end
    end
endmodule

module interrupt_ctrl_v6 (
    input  wire       clk, rst_n,
    input  wire       int_infer_done,
    input  wire       int_dma_done,
    input  wire       int_uart_ready,
    input  wire [2:0] int_mask,
    input  wire [2:0] int_clear,
    output reg  [2:0] int_status,
    output wire       irq
);
    always @(posedge clk) begin
        if (!rst_n) int_status <= 3'b000;
        else begin
            if (int_infer_done) int_status[0] <= 1;
            if (int_dma_done)   int_status[1] <= 1;
            if (int_uart_ready) int_status[2] <= 1;
            if (int_clear[0])   int_status[0] <= 0;
            if (int_clear[1])   int_status[1] <= 0;
            if (int_clear[2])   int_status[2] <= 0;
        end
    end
    assign irq = |(int_status & ~int_mask);
endmodule

module config_regs_v6 (
    input  wire [2:0]  addr,
    output reg  [31:0] rdata
);
    always @(*) begin
        case (addr)
            3'd0: rdata = 32'h0000AB06;
            3'd1: rdata = 32'h00000600;
            3'd2: rdata = 32'd1024;
            3'd3: rdata = 32'd32;
            3'd4: rdata = 32'd32;
            3'd5: rdata = 32'd32768;
            3'd6: rdata = 32'h0000003F;
            3'd7: rdata = 32'd28;
            default: rdata = 32'd0;
        endcase
    end
endmodule

module perf_counters_v6 (
    input  wire        clk, rst_n,
    input  wire        perf_clear,
    input  wire        inc_cycle,
    input  wire        inc_mac_op,
    input  wire        inc_skip,
    input  wire        infer_done,
    input  wire [2:0]  addr,
    output reg  [31:0] rdata
);
    reg [31:0] cycle_count, mac_ops, skip_count;
    reg [31:0] infer_cycles, infer_timer;
    always @(posedge clk) begin
        if (!rst_n || perf_clear) begin
            cycle_count<=0; mac_ops<=0; skip_count<=0;
            infer_cycles<=0; infer_timer<=0;
        end else begin
            if (inc_cycle)  cycle_count <= cycle_count + 1;
            if (inc_mac_op) mac_ops     <= mac_ops + 1;
            if (inc_skip)   skip_count  <= skip_count + 1;
            infer_timer <= infer_timer + 1;
            if (infer_done) begin
                infer_cycles <= infer_timer;
                infer_timer  <= 0;
            end
        end
    end
    always @(*) begin
        case (addr)
            3'd0: rdata = cycle_count;
            3'd1: rdata = mac_ops;
            3'd2: rdata = skip_count;
            3'd3: rdata = infer_cycles;
            default: rdata = 32'd0;
        endcase
    end
endmodule
