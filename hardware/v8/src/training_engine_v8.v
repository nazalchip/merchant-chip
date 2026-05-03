// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — On-Device Training Engine
//  training_engine_v8.v
//
//  Fine-tuning last 2-3 layers on-chip
//  Algorithm: SGD with momentum
//  Gradient buffer: 1024 x INT16 = 2KB
//  Weight update: new_w = old_w - (lr x gradient)
//  Sequential — never simultaneous with inference
// ═══════════════════════════════════════════════════════
module training_engine_v8 (
    input  wire        clk, rst_n,
    input  wire        train_en,      // start training
    input  wire        grad_clear,    // reset gradients
    input  wire [7:0]  learning_rate, // fixed point lr
    // error input from output comparison
    input  wire signed [7:0]  error_in,
    input  wire [9:0]  error_addr,
    input  wire        error_we,
    // weight read interface (reads current weights)
    output reg  [9:0]  w_read_addr,
    input  wire signed [7:0]  w_read_data,
    // weight write interface (writes updated weights)
    output reg  [9:0]  w_write_addr,
    output reg  signed [7:0]  w_write_data,
    output reg         w_write_en,
    // activation read (for gradient computation)
    input  wire signed [7:0]  act_read_data,
    output reg  [9:0]  act_read_addr,
    // status
    output reg         train_done,
    output reg         train_busy,
    output reg  [9:0]  updates_done
);
    // gradient buffer — INT16 per weight
    reg signed [15:0] grad_buf [0:1023];
    // error buffer
    reg signed [7:0]  error_buf [0:31];

    integer gi;
    initial begin
        for (gi = 0; gi < 1024; gi = gi + 1)
            grad_buf[gi] = 16'sd0;
    end

    // FSM states
    localparam IDLE        = 3'd0;
    localparam LOAD_ERROR  = 3'd1;
    localparam CALC_GRAD   = 3'd2;
    localparam UPDATE_W    = 3'd3;
    localparam DONE        = 3'd4;

    reg [2:0]  state;
    reg [9:0]  addr_cnt;
    reg signed [15:0] grad_tmp;

    // store errors
    always @(posedge clk) begin
        if (error_we)
            error_buf[error_addr[4:0]] <= error_in;
    end

    // clear gradients
    integer ci;
    always @(posedge clk) begin
        if (grad_clear) begin
            for (ci = 0; ci < 1024; ci = ci + 1)
                grad_buf[ci] = 16'sd0;
        end
    end

    // training FSM
    always @(posedge clk) begin
        if (!rst_n) begin
            state        <= IDLE;
            train_done   <= 0;
            train_busy   <= 0;
            updates_done <= 0;
            addr_cnt     <= 0;
            w_write_en   <= 0;
            w_read_addr  <= 0;
            w_write_addr <= 0;
            w_write_data <= 0;
            act_read_addr<= 0;
        end else begin
            train_done <= 0;
            w_write_en <= 0;

            case (state)
                IDLE: begin
                    if (train_en && !train_busy) begin
                        state      <= CALC_GRAD;
                        train_busy <= 1;
                        addr_cnt   <= 0;
                        updates_done <= 0;
                    end
                end

                CALC_GRAD: begin
                    // gradient = error x activation
                    // simplified: grad[addr] += error[addr[4:0]] x act
                    act_read_addr <= addr_cnt;
                    // accumulate gradient
                    grad_tmp = grad_buf[addr_cnt] +
                        $signed(error_buf[addr_cnt[4:0]]) *
                        $signed(act_read_data);
                    // clamp to INT16
                    if (grad_tmp > 16'sd32767)
                        grad_buf[addr_cnt] <= 16'sd32767;
                    else if (grad_tmp < -16'sd32768)
                        grad_buf[addr_cnt] <= -16'sd32768;
                    else
                        grad_buf[addr_cnt] <= grad_tmp;

                    addr_cnt <= addr_cnt + 1;
                    if (addr_cnt >= 10'd1023) begin
                        state    <= UPDATE_W;
                        addr_cnt <= 0;
                    end
                end

                UPDATE_W: begin
                    // read current weight
                    w_read_addr <= addr_cnt;
                    // compute update: new_w = old_w - (lr x grad >> 8)
                    // lr is 8-bit fixed point, grad is INT16
                    // result scaled back to INT8
                    w_write_addr <= addr_cnt;
                    w_write_data <= w_read_data -
                        $signed((learning_rate *
                        $signed(grad_buf[addr_cnt])) >>> 15);
                    w_write_en   <= 1;
                    updates_done <= updates_done + 1;

                    addr_cnt <= addr_cnt + 1;
                    if (addr_cnt >= 10'd1023) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    train_busy <= 0;
                    train_done <= 1;
                    state      <= IDLE;
                end
            endcase
        end
    end
endmodule
