module accumulator_v6 (
    input  wire        clk, rst_n,
    input  wire        acc_en, acc_clear,
    input  wire signed [19:0] psum_in_0,  psum_in_1,  psum_in_2,  psum_in_3,
    input  wire signed [19:0] psum_in_4,  psum_in_5,  psum_in_6,  psum_in_7,
    input  wire signed [19:0] psum_in_8,  psum_in_9,  psum_in_10, psum_in_11,
    input  wire signed [19:0] psum_in_12, psum_in_13, psum_in_14, psum_in_15,
    input  wire signed [19:0] psum_in_16, psum_in_17, psum_in_18, psum_in_19,
    input  wire signed [19:0] psum_in_20, psum_in_21, psum_in_22, psum_in_23,
    input  wire signed [19:0] psum_in_24, psum_in_25, psum_in_26, psum_in_27,
    input  wire signed [19:0] psum_in_28, psum_in_29, psum_in_30, psum_in_31,
    input  wire signed [31:0] bias_0,  bias_1,  bias_2,  bias_3,
    input  wire signed [31:0] bias_4,  bias_5,  bias_6,  bias_7,
    input  wire signed [31:0] bias_8,  bias_9,  bias_10, bias_11,
    input  wire signed [31:0] bias_12, bias_13, bias_14, bias_15,
    input  wire signed [31:0] bias_16, bias_17, bias_18, bias_19,
    input  wire signed [31:0] bias_20, bias_21, bias_22, bias_23,
    input  wire signed [31:0] bias_24, bias_25, bias_26, bias_27,
    input  wire signed [31:0] bias_28, bias_29, bias_30, bias_31,
    output reg  signed [31:0] acc_out_0,  acc_out_1,  acc_out_2,  acc_out_3,
    output reg  signed [31:0] acc_out_4,  acc_out_5,  acc_out_6,  acc_out_7,
    output reg  signed [31:0] acc_out_8,  acc_out_9,  acc_out_10, acc_out_11,
    output reg  signed [31:0] acc_out_12, acc_out_13, acc_out_14, acc_out_15,
    output reg  signed [31:0] acc_out_16, acc_out_17, acc_out_18, acc_out_19,
    output reg  signed [31:0] acc_out_20, acc_out_21, acc_out_22, acc_out_23,
    output reg  signed [31:0] acc_out_24, acc_out_25, acc_out_26, acc_out_27,
    output reg  signed [31:0] acc_out_28, acc_out_29, acc_out_30, acc_out_31
);
    always @(posedge clk) begin
        if (!rst_n || acc_clear) begin
            acc_out_0<=0; acc_out_1<=0; acc_out_2<=0; acc_out_3<=0;
            acc_out_4<=0; acc_out_5<=0; acc_out_6<=0; acc_out_7<=0;
            acc_out_8<=0; acc_out_9<=0; acc_out_10<=0; acc_out_11<=0;
            acc_out_12<=0; acc_out_13<=0; acc_out_14<=0; acc_out_15<=0;
            acc_out_16<=0; acc_out_17<=0; acc_out_18<=0; acc_out_19<=0;
            acc_out_20<=0; acc_out_21<=0; acc_out_22<=0; acc_out_23<=0;
            acc_out_24<=0; acc_out_25<=0; acc_out_26<=0; acc_out_27<=0;
            acc_out_28<=0; acc_out_29<=0; acc_out_30<=0; acc_out_31<=0;
        end else if (acc_en) begin
            acc_out_0  <= acc_out_0  + {{12{psum_in_0[19]}},  psum_in_0}  + bias_0;
            acc_out_1  <= acc_out_1  + {{12{psum_in_1[19]}},  psum_in_1}  + bias_1;
            acc_out_2  <= acc_out_2  + {{12{psum_in_2[19]}},  psum_in_2}  + bias_2;
            acc_out_3  <= acc_out_3  + {{12{psum_in_3[19]}},  psum_in_3}  + bias_3;
            acc_out_4  <= acc_out_4  + {{12{psum_in_4[19]}},  psum_in_4}  + bias_4;
            acc_out_5  <= acc_out_5  + {{12{psum_in_5[19]}},  psum_in_5}  + bias_5;
            acc_out_6  <= acc_out_6  + {{12{psum_in_6[19]}},  psum_in_6}  + bias_6;
            acc_out_7  <= acc_out_7  + {{12{psum_in_7[19]}},  psum_in_7}  + bias_7;
            acc_out_8  <= acc_out_8  + {{12{psum_in_8[19]}},  psum_in_8}  + bias_8;
            acc_out_9  <= acc_out_9  + {{12{psum_in_9[19]}},  psum_in_9}  + bias_9;
            acc_out_10 <= acc_out_10 + {{12{psum_in_10[19]}}, psum_in_10} + bias_10;
            acc_out_11 <= acc_out_11 + {{12{psum_in_11[19]}}, psum_in_11} + bias_11;
            acc_out_12 <= acc_out_12 + {{12{psum_in_12[19]}}, psum_in_12} + bias_12;
            acc_out_13 <= acc_out_13 + {{12{psum_in_13[19]}}, psum_in_13} + bias_13;
            acc_out_14 <= acc_out_14 + {{12{psum_in_14[19]}}, psum_in_14} + bias_14;
            acc_out_15 <= acc_out_15 + {{12{psum_in_15[19]}}, psum_in_15} + bias_15;
            acc_out_16 <= acc_out_16 + {{12{psum_in_16[19]}}, psum_in_16} + bias_16;
            acc_out_17 <= acc_out_17 + {{12{psum_in_17[19]}}, psum_in_17} + bias_17;
            acc_out_18 <= acc_out_18 + {{12{psum_in_18[19]}}, psum_in_18} + bias_18;
            acc_out_19 <= acc_out_19 + {{12{psum_in_19[19]}}, psum_in_19} + bias_19;
            acc_out_20 <= acc_out_20 + {{12{psum_in_20[19]}}, psum_in_20} + bias_20;
            acc_out_21 <= acc_out_21 + {{12{psum_in_21[19]}}, psum_in_21} + bias_21;
            acc_out_22 <= acc_out_22 + {{12{psum_in_22[19]}}, psum_in_22} + bias_22;
            acc_out_23 <= acc_out_23 + {{12{psum_in_23[19]}}, psum_in_23} + bias_23;
            acc_out_24 <= acc_out_24 + {{12{psum_in_24[19]}}, psum_in_24} + bias_24;
            acc_out_25 <= acc_out_25 + {{12{psum_in_25[19]}}, psum_in_25} + bias_25;
            acc_out_26 <= acc_out_26 + {{12{psum_in_26[19]}}, psum_in_26} + bias_26;
            acc_out_27 <= acc_out_27 + {{12{psum_in_27[19]}}, psum_in_27} + bias_27;
            acc_out_28 <= acc_out_28 + {{12{psum_in_28[19]}}, psum_in_28} + bias_28;
            acc_out_29 <= acc_out_29 + {{12{psum_in_29[19]}}, psum_in_29} + bias_29;
            acc_out_30 <= acc_out_30 + {{12{psum_in_30[19]}}, psum_in_30} + bias_30;
            acc_out_31 <= acc_out_31 + {{12{psum_in_31[19]}}, psum_in_31} + bias_31;
        end
    end
endmodule
