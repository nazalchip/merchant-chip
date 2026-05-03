module post_processor_v6 (
    input  wire        clk, rst_n,
    input  wire [7:0]  bn_scale,
    input  wire [3:0]  bn_shift,
    input  wire        bn_en, relu_en,
    input  wire signed [31:0] acc_in_0,  acc_in_1,  acc_in_2,  acc_in_3,
    input  wire signed [31:0] acc_in_4,  acc_in_5,  acc_in_6,  acc_in_7,
    input  wire signed [31:0] acc_in_8,  acc_in_9,  acc_in_10, acc_in_11,
    input  wire signed [31:0] acc_in_12, acc_in_13, acc_in_14, acc_in_15,
    input  wire signed [31:0] acc_in_16, acc_in_17, acc_in_18, acc_in_19,
    input  wire signed [31:0] acc_in_20, acc_in_21, acc_in_22, acc_in_23,
    input  wire signed [31:0] acc_in_24, acc_in_25, acc_in_26, acc_in_27,
    input  wire signed [31:0] acc_in_28, acc_in_29, acc_in_30, acc_in_31,
    output reg  signed [7:0]  act_out_0,  act_out_1,  act_out_2,  act_out_3,
    output reg  signed [7:0]  act_out_4,  act_out_5,  act_out_6,  act_out_7,
    output reg  signed [7:0]  act_out_8,  act_out_9,  act_out_10, act_out_11,
    output reg  signed [7:0]  act_out_12, act_out_13, act_out_14, act_out_15,
    output reg  signed [7:0]  act_out_16, act_out_17, act_out_18, act_out_19,
    output reg  signed [7:0]  act_out_20, act_out_21, act_out_22, act_out_23,
    output reg  signed [7:0]  act_out_24, act_out_25, act_out_26, act_out_27,
    output reg  signed [7:0]  act_out_28, act_out_29, act_out_30, act_out_31
);
    function signed [7:0] proc;
        input signed [31:0] a;
        input [7:0] sc; input [3:0] sh;
        input do_bn, do_relu;
        reg signed [31:0] v;
        begin
            v = a;
            if (do_bn) v = (v * $signed({1'b0,sc})) >>> sh;
            if (do_relu && v < 0) v = 0;
            if (v > 127) v = 127;
            else if (v < -128) v = -128;
            proc = v[7:0];
        end
    endfunction
    always @(posedge clk) begin
        if (!rst_n) begin
            act_out_0<=0; act_out_1<=0; act_out_2<=0; act_out_3<=0;
            act_out_4<=0; act_out_5<=0; act_out_6<=0; act_out_7<=0;
            act_out_8<=0; act_out_9<=0; act_out_10<=0; act_out_11<=0;
            act_out_12<=0; act_out_13<=0; act_out_14<=0; act_out_15<=0;
            act_out_16<=0; act_out_17<=0; act_out_18<=0; act_out_19<=0;
            act_out_20<=0; act_out_21<=0; act_out_22<=0; act_out_23<=0;
            act_out_24<=0; act_out_25<=0; act_out_26<=0; act_out_27<=0;
            act_out_28<=0; act_out_29<=0; act_out_30<=0; act_out_31<=0;
        end else begin
            act_out_0  <= proc(acc_in_0,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_1  <= proc(acc_in_1,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_2  <= proc(acc_in_2,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_3  <= proc(acc_in_3,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_4  <= proc(acc_in_4,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_5  <= proc(acc_in_5,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_6  <= proc(acc_in_6,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_7  <= proc(acc_in_7,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_8  <= proc(acc_in_8,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_9  <= proc(acc_in_9,  bn_scale,bn_shift,bn_en,relu_en);
            act_out_10 <= proc(acc_in_10, bn_scale,bn_shift,bn_en,relu_en);
            act_out_11 <= proc(acc_in_11, bn_scale,bn_shift,bn_en,relu_en);
            act_out_12 <= proc(acc_in_12, bn_scale,bn_shift,bn_en,relu_en);
            act_out_13 <= proc(acc_in_13, bn_scale,bn_shift,bn_en,relu_en);
            act_out_14 <= proc(acc_in_14, bn_scale,bn_shift,bn_en,relu_en);
            act_out_15 <= proc(acc_in_15, bn_scale,bn_shift,bn_en,relu_en);
            act_out_16 <= proc(acc_in_16, bn_scale,bn_shift,bn_en,relu_en);
            act_out_17 <= proc(acc_in_17, bn_scale,bn_shift,bn_en,relu_en);
            act_out_18 <= proc(acc_in_18, bn_scale,bn_shift,bn_en,relu_en);
            act_out_19 <= proc(acc_in_19, bn_scale,bn_shift,bn_en,relu_en);
            act_out_20 <= proc(acc_in_20, bn_scale,bn_shift,bn_en,relu_en);
            act_out_21 <= proc(acc_in_21, bn_scale,bn_shift,bn_en,relu_en);
            act_out_22 <= proc(acc_in_22, bn_scale,bn_shift,bn_en,relu_en);
            act_out_23 <= proc(acc_in_23, bn_scale,bn_shift,bn_en,relu_en);
            act_out_24 <= proc(acc_in_24, bn_scale,bn_shift,bn_en,relu_en);
            act_out_25 <= proc(acc_in_25, bn_scale,bn_shift,bn_en,relu_en);
            act_out_26 <= proc(acc_in_26, bn_scale,bn_shift,bn_en,relu_en);
            act_out_27 <= proc(acc_in_27, bn_scale,bn_shift,bn_en,relu_en);
            act_out_28 <= proc(acc_in_28, bn_scale,bn_shift,bn_en,relu_en);
            act_out_29 <= proc(acc_in_29, bn_scale,bn_shift,bn_en,relu_en);
            act_out_30 <= proc(acc_in_30, bn_scale,bn_shift,bn_en,relu_en);
            act_out_31 <= proc(acc_in_31, bn_scale,bn_shift,bn_en,relu_en);
        end
    end
endmodule
