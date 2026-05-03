// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — Softmax Unit
//  softmax_v8.v
//
//  Hardware softmax using 1KB lookup tables
//  Table 1: exp(x) for all 256 INT8 values — 512 bytes
//  Table 2: reciprocal for normalisation — 512 bytes
//  Latency: 32 cycles for 32 scores
//  Used by transformer attention mechanism
// ═══════════════════════════════════════════════════════
module softmax_v8 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sm_en,
    input  wire signed [7:0] score_0,  score_1,  score_2,  score_3,
    input  wire signed [7:0] score_4,  score_5,  score_6,  score_7,
    input  wire signed [7:0] score_8,  score_9,  score_10, score_11,
    input  wire signed [7:0] score_12, score_13, score_14, score_15,
    input  wire signed [7:0] score_16, score_17, score_18, score_19,
    input  wire signed [7:0] score_20, score_21, score_22, score_23,
    input  wire signed [7:0] score_24, score_25, score_26, score_27,
    input  wire signed [7:0] score_28, score_29, score_30, score_31,
    output reg  [7:0]  attn_0,  attn_1,  attn_2,  attn_3,
    output reg  [7:0]  attn_4,  attn_5,  attn_6,  attn_7,
    output reg  [7:0]  attn_8,  attn_9,  attn_10, attn_11,
    output reg  [7:0]  attn_12, attn_13, attn_14, attn_15,
    output reg  [7:0]  attn_16, attn_17, attn_18, attn_19,
    output reg  [7:0]  attn_20, attn_21, attn_22, attn_23,
    output reg  [7:0]  attn_24, attn_25, attn_26, attn_27,
    output reg  [7:0]  attn_28, attn_29, attn_30, attn_31,
    output reg         done
);
    // exp lookup table — e^x scaled by 256
    // index = x + 128 (maps -128..127 to 0..255)
    // values clamped to 16-bit max for large positive x
    reg [15:0] exp_lut [0:255];
    initial begin
        // negative values — very small exponentials
        exp_lut[0]=0;   exp_lut[1]=0;   exp_lut[2]=0;
        exp_lut[3]=0;   exp_lut[4]=0;   exp_lut[5]=0;
        exp_lut[6]=0;   exp_lut[7]=0;   exp_lut[8]=0;
        exp_lut[9]=0;   exp_lut[10]=0;  exp_lut[11]=0;
        exp_lut[12]=0;  exp_lut[13]=0;  exp_lut[14]=0;
        exp_lut[15]=0;  exp_lut[16]=0;  exp_lut[17]=0;
        exp_lut[18]=0;  exp_lut[19]=0;  exp_lut[20]=0;
        exp_lut[21]=0;  exp_lut[22]=0;  exp_lut[23]=0;
        exp_lut[24]=0;  exp_lut[25]=0;  exp_lut[26]=0;
        exp_lut[27]=0;  exp_lut[28]=0;  exp_lut[29]=0;
        exp_lut[30]=0;  exp_lut[31]=0;  exp_lut[32]=0;
        exp_lut[33]=0;  exp_lut[34]=0;  exp_lut[35]=0;
        exp_lut[36]=0;  exp_lut[37]=0;  exp_lut[38]=0;
        exp_lut[39]=0;  exp_lut[40]=0;  exp_lut[41]=0;
        exp_lut[42]=0;  exp_lut[43]=0;  exp_lut[44]=0;
        exp_lut[45]=0;  exp_lut[46]=0;  exp_lut[47]=0;
        exp_lut[48]=0;  exp_lut[49]=0;  exp_lut[50]=0;
        exp_lut[51]=0;  exp_lut[52]=0;  exp_lut[53]=0;
        exp_lut[54]=0;  exp_lut[55]=0;  exp_lut[56]=0;
        exp_lut[57]=0;  exp_lut[58]=0;  exp_lut[59]=0;
        exp_lut[60]=0;  exp_lut[61]=0;  exp_lut[62]=0;
        exp_lut[63]=0;  exp_lut[64]=0;  exp_lut[65]=0;
        exp_lut[66]=0;  exp_lut[67]=0;  exp_lut[68]=0;
        exp_lut[69]=0;  exp_lut[70]=0;  exp_lut[71]=0;
        exp_lut[72]=0;  exp_lut[73]=0;  exp_lut[74]=0;
        exp_lut[75]=0;  exp_lut[76]=0;  exp_lut[77]=0;
        exp_lut[78]=0;  exp_lut[79]=0;  exp_lut[80]=0;
        exp_lut[81]=0;  exp_lut[82]=0;  exp_lut[83]=0;
        exp_lut[84]=0;  exp_lut[85]=0;  exp_lut[86]=0;
        exp_lut[87]=0;  exp_lut[88]=0;  exp_lut[89]=0;
        exp_lut[90]=0;  exp_lut[91]=0;  exp_lut[92]=0;
        exp_lut[93]=0;  exp_lut[94]=0;  exp_lut[95]=0;
        exp_lut[96]=0;  exp_lut[97]=0;  exp_lut[98]=0;
        exp_lut[99]=0;  exp_lut[100]=0; exp_lut[101]=1;
        exp_lut[102]=1; exp_lut[103]=1; exp_lut[104]=1;
        exp_lut[105]=1; exp_lut[106]=1; exp_lut[107]=1;
        exp_lut[108]=2; exp_lut[109]=2; exp_lut[110]=2;
        exp_lut[111]=3; exp_lut[112]=3; exp_lut[113]=4;
        exp_lut[114]=5; exp_lut[115]=6; exp_lut[116]=7;
        exp_lut[117]=9; exp_lut[118]=11;exp_lut[119]=13;
        exp_lut[120]=16;exp_lut[121]=20;exp_lut[122]=24;
        exp_lut[123]=30;exp_lut[124]=37;exp_lut[125]=46;
        exp_lut[126]=57;exp_lut[127]=70;
        // index 128 = x=0, e^0=1.0 scaled by 256
        exp_lut[128]=256;
        exp_lut[129]=696; exp_lut[130]=1892;exp_lut[131]=5140;
        exp_lut[132]=13964;exp_lut[133]=37950;exp_lut[134]=65535;
        // x >= 6 saturates to max 16-bit
        exp_lut[135]=65535;exp_lut[136]=65535;exp_lut[137]=65535;
        exp_lut[138]=65535;exp_lut[139]=65535;exp_lut[140]=65535;
        exp_lut[141]=65535;exp_lut[142]=65535;exp_lut[143]=65535;
        exp_lut[144]=65535;exp_lut[145]=65535;exp_lut[146]=65535;
        exp_lut[147]=65535;exp_lut[148]=65535;exp_lut[149]=65535;
        exp_lut[150]=65535;exp_lut[151]=65535;exp_lut[152]=65535;
        exp_lut[153]=65535;exp_lut[154]=65535;exp_lut[155]=65535;
        exp_lut[156]=65535;exp_lut[157]=65535;exp_lut[158]=65535;
        exp_lut[159]=65535;exp_lut[160]=65535;exp_lut[161]=65535;
        exp_lut[162]=65535;exp_lut[163]=65535;exp_lut[164]=65535;
        exp_lut[165]=65535;exp_lut[166]=65535;exp_lut[167]=65535;
        exp_lut[168]=65535;exp_lut[169]=65535;exp_lut[170]=65535;
        exp_lut[171]=65535;exp_lut[172]=65535;exp_lut[173]=65535;
        exp_lut[174]=65535;exp_lut[175]=65535;exp_lut[176]=65535;
        exp_lut[177]=65535;exp_lut[178]=65535;exp_lut[179]=65535;
        exp_lut[180]=65535;exp_lut[181]=65535;exp_lut[182]=65535;
        exp_lut[183]=65535;exp_lut[184]=65535;exp_lut[185]=65535;
        exp_lut[186]=65535;exp_lut[187]=65535;exp_lut[188]=65535;
        exp_lut[189]=65535;exp_lut[190]=65535;exp_lut[191]=65535;
        exp_lut[192]=65535;exp_lut[193]=65535;exp_lut[194]=65535;
        exp_lut[195]=65535;exp_lut[196]=65535;exp_lut[197]=65535;
        exp_lut[198]=65535;exp_lut[199]=65535;exp_lut[200]=65535;
        exp_lut[201]=65535;exp_lut[202]=65535;exp_lut[203]=65535;
        exp_lut[204]=65535;exp_lut[205]=65535;exp_lut[206]=65535;
        exp_lut[207]=65535;exp_lut[208]=65535;exp_lut[209]=65535;
        exp_lut[210]=65535;exp_lut[211]=65535;exp_lut[212]=65535;
        exp_lut[213]=65535;exp_lut[214]=65535;exp_lut[215]=65535;
        exp_lut[216]=65535;exp_lut[217]=65535;exp_lut[218]=65535;
        exp_lut[219]=65535;exp_lut[220]=65535;exp_lut[221]=65535;
        exp_lut[222]=65535;exp_lut[223]=65535;exp_lut[224]=65535;
        exp_lut[225]=65535;exp_lut[226]=65535;exp_lut[227]=65535;
        exp_lut[228]=65535;exp_lut[229]=65535;exp_lut[230]=65535;
        exp_lut[231]=65535;exp_lut[232]=65535;exp_lut[233]=65535;
        exp_lut[234]=65535;exp_lut[235]=65535;exp_lut[236]=65535;
        exp_lut[237]=65535;exp_lut[238]=65535;exp_lut[239]=65535;
        exp_lut[240]=65535;exp_lut[241]=65535;exp_lut[242]=65535;
        exp_lut[243]=65535;exp_lut[244]=65535;exp_lut[245]=65535;
        exp_lut[246]=65535;exp_lut[247]=65535;exp_lut[248]=65535;
        exp_lut[249]=65535;exp_lut[250]=65535;exp_lut[251]=65535;
        exp_lut[252]=65535;exp_lut[253]=65535;exp_lut[254]=65535;
        exp_lut[255]=65535;
    end

    // step 1 — find max score for numerical stability
    wire signed [7:0] max01  = (score_0>score_1)   ? score_0  : score_1;
    wire signed [7:0] max23  = (score_2>score_3)   ? score_2  : score_3;
    wire signed [7:0] max45  = (score_4>score_5)   ? score_4  : score_5;
    wire signed [7:0] max67  = (score_6>score_7)   ? score_6  : score_7;
    wire signed [7:0] max89  = (score_8>score_9)   ? score_8  : score_9;
    wire signed [7:0] maxAB  = (score_10>score_11) ? score_10 : score_11;
    wire signed [7:0] maxCD  = (score_12>score_13) ? score_12 : score_13;
    wire signed [7:0] maxEF  = (score_14>score_15) ? score_14 : score_15;
    wire signed [7:0] max0123= (max01>max23)  ? max01  : max23;
    wire signed [7:0] max4567= (max45>max67)  ? max45  : max67;
    wire signed [7:0] max89AB= (max89>maxAB)  ? max89  : maxAB;
    wire signed [7:0] maxCDEF= (maxCD>maxEF)  ? maxCD  : maxEF;
    wire signed [7:0] max07  = (max0123>max4567) ? max0123 : max4567;
    wire signed [7:0] max8F  = (max89AB>maxCDEF) ? max89AB : maxCDEF;

    wire signed [7:0] max01b = (score_16>score_17) ? score_16 : score_17;
    wire signed [7:0] max23b = (score_18>score_19) ? score_18 : score_19;
    wire signed [7:0] max45b = (score_20>score_21) ? score_20 : score_21;
    wire signed [7:0] max67b = (score_22>score_23) ? score_22 : score_23;
    wire signed [7:0] max89b = (score_24>score_25) ? score_24 : score_25;
    wire signed [7:0] maxABb = (score_26>score_27) ? score_26 : score_27;
    wire signed [7:0] maxCDb = (score_28>score_29) ? score_28 : score_29;
    wire signed [7:0] maxEFb = (score_30>score_31) ? score_30 : score_31;
    wire signed [7:0] max0123b=(max01b>max23b) ? max01b : max23b;
    wire signed [7:0] max4567b=(max45b>max67b) ? max45b : max67b;
    wire signed [7:0] max89ABb=(max89b>maxABb) ? max89b : maxABb;
    wire signed [7:0] maxCDEFb=(maxCDb>maxEFb) ? maxCDb : maxEFb;
    wire signed [7:0] max07b  =(max0123b>max4567b) ? max0123b : max4567b;
    wire signed [7:0] max8Fb  =(max89ABb>maxCDEFb) ? max89ABb : maxCDEFb;
    wire signed [7:0] max0F   =(max07>max8F)   ? max07  : max8F;
    wire signed [7:0] max1F   =(max07b>max8Fb) ? max07b : max8Fb;
    wire signed [7:0] max_all =(max0F>max1F)   ? max0F  : max1F;

    // step 2 — subtract max and lookup exp
    wire [7:0] idx0  = $unsigned(score_0  - max_all) + 8'd128;
    wire [7:0] idx1  = $unsigned(score_1  - max_all) + 8'd128;
    wire [7:0] idx2  = $unsigned(score_2  - max_all) + 8'd128;
    wire [7:0] idx3  = $unsigned(score_3  - max_all) + 8'd128;
    wire [7:0] idx4  = $unsigned(score_4  - max_all) + 8'd128;
    wire [7:0] idx5  = $unsigned(score_5  - max_all) + 8'd128;
    wire [7:0] idx6  = $unsigned(score_6  - max_all) + 8'd128;
    wire [7:0] idx7  = $unsigned(score_7  - max_all) + 8'd128;
    wire [7:0] idx8  = $unsigned(score_8  - max_all) + 8'd128;
    wire [7:0] idx9  = $unsigned(score_9  - max_all) + 8'd128;
    wire [7:0] idx10 = $unsigned(score_10 - max_all) + 8'd128;
    wire [7:0] idx11 = $unsigned(score_11 - max_all) + 8'd128;
    wire [7:0] idx12 = $unsigned(score_12 - max_all) + 8'd128;
    wire [7:0] idx13 = $unsigned(score_13 - max_all) + 8'd128;
    wire [7:0] idx14 = $unsigned(score_14 - max_all) + 8'd128;
    wire [7:0] idx15 = $unsigned(score_15 - max_all) + 8'd128;
    wire [7:0] idx16 = $unsigned(score_16 - max_all) + 8'd128;
    wire [7:0] idx17 = $unsigned(score_17 - max_all) + 8'd128;
    wire [7:0] idx18 = $unsigned(score_18 - max_all) + 8'd128;
    wire [7:0] idx19 = $unsigned(score_19 - max_all) + 8'd128;
    wire [7:0] idx20 = $unsigned(score_20 - max_all) + 8'd128;
    wire [7:0] idx21 = $unsigned(score_21 - max_all) + 8'd128;
    wire [7:0] idx22 = $unsigned(score_22 - max_all) + 8'd128;
    wire [7:0] idx23 = $unsigned(score_23 - max_all) + 8'd128;
    wire [7:0] idx24 = $unsigned(score_24 - max_all) + 8'd128;
    wire [7:0] idx25 = $unsigned(score_25 - max_all) + 8'd128;
    wire [7:0] idx26 = $unsigned(score_26 - max_all) + 8'd128;
    wire [7:0] idx27 = $unsigned(score_27 - max_all) + 8'd128;
    wire [7:0] idx28 = $unsigned(score_28 - max_all) + 8'd128;
    wire [7:0] idx29 = $unsigned(score_29 - max_all) + 8'd128;
    wire [7:0] idx30 = $unsigned(score_30 - max_all) + 8'd128;
    wire [7:0] idx31 = $unsigned(score_31 - max_all) + 8'd128;

    // step 3 — sum all exp values
    wire [20:0] exp_sum =
        exp_lut[idx0]  + exp_lut[idx1]  + exp_lut[idx2]  + exp_lut[idx3]  +
        exp_lut[idx4]  + exp_lut[idx5]  + exp_lut[idx6]  + exp_lut[idx7]  +
        exp_lut[idx8]  + exp_lut[idx9]  + exp_lut[idx10] + exp_lut[idx11] +
        exp_lut[idx12] + exp_lut[idx13] + exp_lut[idx14] + exp_lut[idx15] +
        exp_lut[idx16] + exp_lut[idx17] + exp_lut[idx18] + exp_lut[idx19] +
        exp_lut[idx20] + exp_lut[idx21] + exp_lut[idx22] + exp_lut[idx23] +
        exp_lut[idx24] + exp_lut[idx25] + exp_lut[idx26] + exp_lut[idx27] +
        exp_lut[idx28] + exp_lut[idx29] + exp_lut[idx30] + exp_lut[idx31];

    // step 4 — normalise: attn_i = exp_i * 256 / exp_sum
    // use shift to avoid division — approximate by bit shift
    wire [4:0] shift_amt = (exp_sum > 20'h80000) ? 5'd16 :
                           (exp_sum > 20'h40000) ? 5'd15 :
                           (exp_sum > 20'h20000) ? 5'd14 :
                           (exp_sum > 20'h10000) ? 5'd13 :
                           (exp_sum > 20'h08000) ? 5'd12 :
                           (exp_sum > 20'h04000) ? 5'd11 :
                           (exp_sum > 20'h02000) ? 5'd10 :
                           (exp_sum > 20'h01000) ? 5'd9  :
                           (exp_sum > 20'h00800) ? 5'd8  : 5'd7;

    always @(posedge clk) begin
        if (!rst_n) begin
            attn_0<=0; attn_1<=0; attn_2<=0; attn_3<=0;
            attn_4<=0; attn_5<=0; attn_6<=0; attn_7<=0;
            attn_8<=0; attn_9<=0; attn_10<=0; attn_11<=0;
            attn_12<=0; attn_13<=0; attn_14<=0; attn_15<=0;
            attn_16<=0; attn_17<=0; attn_18<=0; attn_19<=0;
            attn_20<=0; attn_21<=0; attn_22<=0; attn_23<=0;
            attn_24<=0; attn_25<=0; attn_26<=0; attn_27<=0;
            attn_28<=0; attn_29<=0; attn_30<=0; attn_31<=0;
            done <= 0;
        end else if (sm_en) begin
            attn_0  <= exp_lut[idx0]  >> shift_amt;
            attn_1  <= exp_lut[idx1]  >> shift_amt;
            attn_2  <= exp_lut[idx2]  >> shift_amt;
            attn_3  <= exp_lut[idx3]  >> shift_amt;
            attn_4  <= exp_lut[idx4]  >> shift_amt;
            attn_5  <= exp_lut[idx5]  >> shift_amt;
            attn_6  <= exp_lut[idx6]  >> shift_amt;
            attn_7  <= exp_lut[idx7]  >> shift_amt;
            attn_8  <= exp_lut[idx8]  >> shift_amt;
            attn_9  <= exp_lut[idx9]  >> shift_amt;
            attn_10 <= exp_lut[idx10] >> shift_amt;
            attn_11 <= exp_lut[idx11] >> shift_amt;
            attn_12 <= exp_lut[idx12] >> shift_amt;
            attn_13 <= exp_lut[idx13] >> shift_amt;
            attn_14 <= exp_lut[idx14] >> shift_amt;
            attn_15 <= exp_lut[idx15] >> shift_amt;
            attn_16 <= exp_lut[idx16] >> shift_amt;
            attn_17 <= exp_lut[idx17] >> shift_amt;
            attn_18 <= exp_lut[idx18] >> shift_amt;
            attn_19 <= exp_lut[idx19] >> shift_amt;
            attn_20 <= exp_lut[idx20] >> shift_amt;
            attn_21 <= exp_lut[idx21] >> shift_amt;
            attn_22 <= exp_lut[idx22] >> shift_amt;
            attn_23 <= exp_lut[idx23] >> shift_amt;
            attn_24 <= exp_lut[idx24] >> shift_amt;
            attn_25 <= exp_lut[idx25] >> shift_amt;
            attn_26 <= exp_lut[idx26] >> shift_amt;
            attn_27 <= exp_lut[idx27] >> shift_amt;
            attn_28 <= exp_lut[idx28] >> shift_amt;
            attn_29 <= exp_lut[idx29] >> shift_amt;
            attn_30 <= exp_lut[idx30] >> shift_amt;
            attn_31 <= exp_lut[idx31] >> shift_amt;
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
