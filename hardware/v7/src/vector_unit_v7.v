// ═══════════════════════════════════════════════════════
//  MERCHANT V7 — Vector Processing Unit
//  vector_unit_v7.v
//
//  32-wide vector processor alongside MAC array
//  Handles operations MAC array cannot do:
//  ADD, MAX, ABS, SHIFT, COMPARE, SIGMOID approx
//  Used for residual adds, distance calc, sensor fusion
// ═══════════════════════════════════════════════════════
module vector_unit_v7 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        vu_en,

    // operation select
    // 0=ADD 1=MAX 2=MIN 3=ABS 4=SHR 5=SHL 6=CMP 7=MUL
    input  wire [2:0]  op_code,
    input  wire [3:0]  shift_amt,

    // 32 input pairs
    input  wire signed [7:0] a_0,  a_1,  a_2,  a_3,
    input  wire signed [7:0] a_4,  a_5,  a_6,  a_7,
    input  wire signed [7:0] a_8,  a_9,  a_10, a_11,
    input  wire signed [7:0] a_12, a_13, a_14, a_15,
    input  wire signed [7:0] a_16, a_17, a_18, a_19,
    input  wire signed [7:0] a_20, a_21, a_22, a_23,
    input  wire signed [7:0] a_24, a_25, a_26, a_27,
    input  wire signed [7:0] a_28, a_29, a_30, a_31,

    input  wire signed [7:0] b_0,  b_1,  b_2,  b_3,
    input  wire signed [7:0] b_4,  b_5,  b_6,  b_7,
    input  wire signed [7:0] b_8,  b_9,  b_10, b_11,
    input  wire signed [7:0] b_12, b_13, b_14, b_15,
    input  wire signed [7:0] b_16, b_17, b_18, b_19,
    input  wire signed [7:0] b_20, b_21, b_22, b_23,
    input  wire signed [7:0] b_24, b_25, b_26, b_27,
    input  wire signed [7:0] b_28, b_29, b_30, b_31,

    // 32 outputs
    output reg  signed [7:0] r_0,  r_1,  r_2,  r_3,
    output reg  signed [7:0] r_4,  r_5,  r_6,  r_7,
    output reg  signed [7:0] r_8,  r_9,  r_10, r_11,
    output reg  signed [7:0] r_12, r_13, r_14, r_15,
    output reg  signed [7:0] r_16, r_17, r_18, r_19,
    output reg  signed [7:0] r_20, r_21, r_22, r_23,
    output reg  signed [7:0] r_24, r_25, r_26, r_27,
    output reg  signed [7:0] r_28, r_29, r_30, r_31,
    output reg         done
);
    // operation codes
    localparam OP_ADD = 3'd0;
    localparam OP_MAX = 3'd1;
    localparam OP_MIN = 3'd2;
    localparam OP_ABS = 3'd3;
    localparam OP_SHR = 3'd4;
    localparam OP_SHL = 3'd5;
    localparam OP_CMP = 3'd6;
    localparam OP_MUL = 3'd7;

    // vector operation function
    function signed [7:0] vec_op;
        input signed [7:0] a, b;
        input [2:0] op;
        input [3:0] sh;
        reg signed [15:0] tmp;
        begin
            case (op)
                OP_ADD: begin
                    tmp = a + b;
                    if (tmp > 127)  vec_op = 8'sd127;
                    else if (tmp < -128) vec_op = -8'sd128;
                    else vec_op = tmp[7:0];
                end
                OP_MAX: vec_op = (a > b) ? a : b;
                OP_MIN: vec_op = (a < b) ? a : b;
                OP_ABS: vec_op = (a < 0) ? -a : a;
                OP_SHR: vec_op = a >>> sh;
                OP_SHL: vec_op = a <<< sh;
                OP_CMP: vec_op = (a > b) ? 8'sd1 :
                                 (a < b) ? -8'sd1 : 8'sd0;
                OP_MUL: begin
                    tmp = a * b;
                    vec_op = tmp[11:4]; // scale down
                end
                default: vec_op = a;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (!rst_n) begin
            r_0<=0; r_1<=0; r_2<=0; r_3<=0;
            r_4<=0; r_5<=0; r_6<=0; r_7<=0;
            r_8<=0; r_9<=0; r_10<=0; r_11<=0;
            r_12<=0; r_13<=0; r_14<=0; r_15<=0;
            r_16<=0; r_17<=0; r_18<=0; r_19<=0;
            r_20<=0; r_21<=0; r_22<=0; r_23<=0;
            r_24<=0; r_25<=0; r_26<=0; r_27<=0;
            r_28<=0; r_29<=0; r_30<=0; r_31<=0;
            done <= 0;
        end else if (vu_en) begin
            r_0  <= vec_op(a_0,  b_0,  op_code, shift_amt);
            r_1  <= vec_op(a_1,  b_1,  op_code, shift_amt);
            r_2  <= vec_op(a_2,  b_2,  op_code, shift_amt);
            r_3  <= vec_op(a_3,  b_3,  op_code, shift_amt);
            r_4  <= vec_op(a_4,  b_4,  op_code, shift_amt);
            r_5  <= vec_op(a_5,  b_5,  op_code, shift_amt);
            r_6  <= vec_op(a_6,  b_6,  op_code, shift_amt);
            r_7  <= vec_op(a_7,  b_7,  op_code, shift_amt);
            r_8  <= vec_op(a_8,  b_8,  op_code, shift_amt);
            r_9  <= vec_op(a_9,  b_9,  op_code, shift_amt);
            r_10 <= vec_op(a_10, b_10, op_code, shift_amt);
            r_11 <= vec_op(a_11, b_11, op_code, shift_amt);
            r_12 <= vec_op(a_12, b_12, op_code, shift_amt);
            r_13 <= vec_op(a_13, b_13, op_code, shift_amt);
            r_14 <= vec_op(a_14, b_14, op_code, shift_amt);
            r_15 <= vec_op(a_15, b_15, op_code, shift_amt);
            r_16 <= vec_op(a_16, b_16, op_code, shift_amt);
            r_17 <= vec_op(a_17, b_17, op_code, shift_amt);
            r_18 <= vec_op(a_18, b_18, op_code, shift_amt);
            r_19 <= vec_op(a_19, b_19, op_code, shift_amt);
            r_20 <= vec_op(a_20, b_20, op_code, shift_amt);
            r_21 <= vec_op(a_21, b_21, op_code, shift_amt);
            r_22 <= vec_op(a_22, b_22, op_code, shift_amt);
            r_23 <= vec_op(a_23, b_23, op_code, shift_amt);
            r_24 <= vec_op(a_24, b_24, op_code, shift_amt);
            r_25 <= vec_op(a_25, b_25, op_code, shift_amt);
            r_26 <= vec_op(a_26, b_26, op_code, shift_amt);
            r_27 <= vec_op(a_27, b_27, op_code, shift_amt);
            r_28 <= vec_op(a_28, b_28, op_code, shift_amt);
            r_29 <= vec_op(a_29, b_29, op_code, shift_amt);
            r_30 <= vec_op(a_30, b_30, op_code, shift_amt);
            r_31 <= vec_op(a_31, b_31, op_code, shift_amt);
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
