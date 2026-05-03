module pooling_v6 (
    input  wire        clk, rst_n,
    input  wire        pool_en, pool_mode, pool_clear,
    input  wire signed [7:0] data_in_0,  data_in_1,  data_in_2,  data_in_3,
    input  wire signed [7:0] data_in_4,  data_in_5,  data_in_6,  data_in_7,
    input  wire signed [7:0] data_in_8,  data_in_9,  data_in_10, data_in_11,
    input  wire signed [7:0] data_in_12, data_in_13, data_in_14, data_in_15,
    input  wire signed [7:0] data_in_16, data_in_17, data_in_18, data_in_19,
    input  wire signed [7:0] data_in_20, data_in_21, data_in_22, data_in_23,
    input  wire signed [7:0] data_in_24, data_in_25, data_in_26, data_in_27,
    input  wire signed [7:0] data_in_28, data_in_29, data_in_30, data_in_31,
    output reg  signed [7:0] pool_out_0,  pool_out_1,  pool_out_2,  pool_out_3,
    output reg  signed [7:0] pool_out_4,  pool_out_5,  pool_out_6,  pool_out_7,
    output reg  signed [7:0] pool_out_8,  pool_out_9,  pool_out_10, pool_out_11,
    output reg  signed [7:0] pool_out_12, pool_out_13, pool_out_14, pool_out_15,
    output reg  signed [7:0] pool_out_16, pool_out_17, pool_out_18, pool_out_19,
    output reg  signed [7:0] pool_out_20, pool_out_21, pool_out_22, pool_out_23,
    output reg  signed [7:0] pool_out_24, pool_out_25, pool_out_26, pool_out_27,
    output reg  signed [7:0] pool_out_28, pool_out_29, pool_out_30, pool_out_31
);
    function signed [7:0] mx;
        input signed [7:0] a, b;
        begin mx = (a > b) ? a : b; end
    endfunction
    always @(posedge clk) begin
        if (!rst_n || pool_clear) begin
            pool_out_0<=0; pool_out_1<=0; pool_out_2<=0; pool_out_3<=0;
            pool_out_4<=0; pool_out_5<=0; pool_out_6<=0; pool_out_7<=0;
            pool_out_8<=0; pool_out_9<=0; pool_out_10<=0; pool_out_11<=0;
            pool_out_12<=0; pool_out_13<=0; pool_out_14<=0; pool_out_15<=0;
            pool_out_16<=0; pool_out_17<=0; pool_out_18<=0; pool_out_19<=0;
            pool_out_20<=0; pool_out_21<=0; pool_out_22<=0; pool_out_23<=0;
            pool_out_24<=0; pool_out_25<=0; pool_out_26<=0; pool_out_27<=0;
            pool_out_28<=0; pool_out_29<=0; pool_out_30<=0; pool_out_31<=0;
        end else if (pool_en) begin
            if (!pool_mode) begin
                pool_out_0  <= mx(pool_out_0,  data_in_0);
                pool_out_1  <= mx(pool_out_1,  data_in_1);
                pool_out_2  <= mx(pool_out_2,  data_in_2);
                pool_out_3  <= mx(pool_out_3,  data_in_3);
                pool_out_4  <= mx(pool_out_4,  data_in_4);
                pool_out_5  <= mx(pool_out_5,  data_in_5);
                pool_out_6  <= mx(pool_out_6,  data_in_6);
                pool_out_7  <= mx(pool_out_7,  data_in_7);
                pool_out_8  <= mx(pool_out_8,  data_in_8);
                pool_out_9  <= mx(pool_out_9,  data_in_9);
                pool_out_10 <= mx(pool_out_10, data_in_10);
                pool_out_11 <= mx(pool_out_11, data_in_11);
                pool_out_12 <= mx(pool_out_12, data_in_12);
                pool_out_13 <= mx(pool_out_13, data_in_13);
                pool_out_14 <= mx(pool_out_14, data_in_14);
                pool_out_15 <= mx(pool_out_15, data_in_15);
                pool_out_16 <= mx(pool_out_16, data_in_16);
                pool_out_17 <= mx(pool_out_17, data_in_17);
                pool_out_18 <= mx(pool_out_18, data_in_18);
                pool_out_19 <= mx(pool_out_19, data_in_19);
                pool_out_20 <= mx(pool_out_20, data_in_20);
                pool_out_21 <= mx(pool_out_21, data_in_21);
                pool_out_22 <= mx(pool_out_22, data_in_22);
                pool_out_23 <= mx(pool_out_23, data_in_23);
                pool_out_24 <= mx(pool_out_24, data_in_24);
                pool_out_25 <= mx(pool_out_25, data_in_25);
                pool_out_26 <= mx(pool_out_26, data_in_26);
                pool_out_27 <= mx(pool_out_27, data_in_27);
                pool_out_28 <= mx(pool_out_28, data_in_28);
                pool_out_29 <= mx(pool_out_29, data_in_29);
                pool_out_30 <= mx(pool_out_30, data_in_30);
                pool_out_31 <= mx(pool_out_31, data_in_31);
            end else begin
                pool_out_0<=data_in_0; pool_out_1<=data_in_1;
                pool_out_2<=data_in_2; pool_out_3<=data_in_3;
                pool_out_4<=data_in_4; pool_out_5<=data_in_5;
                pool_out_6<=data_in_6; pool_out_7<=data_in_7;
                pool_out_8<=data_in_8; pool_out_9<=data_in_9;
                pool_out_10<=data_in_10; pool_out_11<=data_in_11;
                pool_out_12<=data_in_12; pool_out_13<=data_in_13;
                pool_out_14<=data_in_14; pool_out_15<=data_in_15;
                pool_out_16<=data_in_16; pool_out_17<=data_in_17;
                pool_out_18<=data_in_18; pool_out_19<=data_in_19;
                pool_out_20<=data_in_20; pool_out_21<=data_in_21;
                pool_out_22<=data_in_22; pool_out_23<=data_in_23;
                pool_out_24<=data_in_24; pool_out_25<=data_in_25;
                pool_out_26<=data_in_26; pool_out_27<=data_in_27;
                pool_out_28<=data_in_28; pool_out_29<=data_in_29;
                pool_out_30<=data_in_30; pool_out_31<=data_in_31;
            end
        end
    end
endmodule
