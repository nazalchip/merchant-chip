// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — Layer Normalisation Unit
//  layer_norm_v8.v
//
//  Normalises 32 values using their own statistics
//  Steps: mean -> variance -> rsqrt LUT -> scale+shift
//  Latency: 4 pipeline stages
//  256-byte reciprocal sqrt lookup table
// ═══════════════════════════════════════════════════════
module layer_norm_v8 (
    input  wire        clk, rst_n,
    input  wire        ln_en,
    input  wire signed [7:0]  gamma,  // scale parameter
    input  wire signed [7:0]  beta,   // shift parameter
    input  wire signed [7:0] x_0,  x_1,  x_2,  x_3,
    input  wire signed [7:0] x_4,  x_5,  x_6,  x_7,
    input  wire signed [7:0] x_8,  x_9,  x_10, x_11,
    input  wire signed [7:0] x_12, x_13, x_14, x_15,
    input  wire signed [7:0] x_16, x_17, x_18, x_19,
    input  wire signed [7:0] x_20, x_21, x_22, x_23,
    input  wire signed [7:0] x_24, x_25, x_26, x_27,
    input  wire signed [7:0] x_28, x_29, x_30, x_31,
    output reg  signed [7:0] y_0,  y_1,  y_2,  y_3,
    output reg  signed [7:0] y_4,  y_5,  y_6,  y_7,
    output reg  signed [7:0] y_8,  y_9,  y_10, y_11,
    output reg  signed [7:0] y_12, y_13, y_14, y_15,
    output reg  signed [7:0] y_16, y_17, y_18, y_19,
    output reg  signed [7:0] y_20, y_21, y_22, y_23,
    output reg  signed [7:0] y_24, y_25, y_26, y_27,
    output reg  signed [7:0] y_28, y_29, y_30, y_31,
    output reg         done
);
    // reciprocal sqrt lookup table
    // rsqrt_lut[i] = 128 / sqrt(i+1) as 8-bit
    reg [7:0] rsqrt_lut [0:255];
    initial begin
        rsqrt_lut[0]=128; rsqrt_lut[1]=91;  rsqrt_lut[2]=74;
        rsqrt_lut[3]=64;  rsqrt_lut[4]=57;  rsqrt_lut[5]=52;
        rsqrt_lut[6]=48;  rsqrt_lut[7]=45;  rsqrt_lut[8]=43;
        rsqrt_lut[9]=40;  rsqrt_lut[10]=39; rsqrt_lut[11]=37;
        rsqrt_lut[12]=35; rsqrt_lut[13]=34; rsqrt_lut[14]=33;
        rsqrt_lut[15]=32; rsqrt_lut[16]=31; rsqrt_lut[17]=30;
        rsqrt_lut[18]=29; rsqrt_lut[19]=29; rsqrt_lut[20]=28;
        rsqrt_lut[21]=27; rsqrt_lut[22]=27; rsqrt_lut[23]=26;
        rsqrt_lut[24]=26; rsqrt_lut[25]=25; rsqrt_lut[26]=25;
        rsqrt_lut[27]=24; rsqrt_lut[28]=24; rsqrt_lut[29]=23;
        rsqrt_lut[30]=23; rsqrt_lut[31]=23; rsqrt_lut[32]=22;
        rsqrt_lut[33]=22; rsqrt_lut[34]=22; rsqrt_lut[35]=21;
        rsqrt_lut[36]=21; rsqrt_lut[37]=21; rsqrt_lut[38]=20;
        rsqrt_lut[39]=20; rsqrt_lut[40]=20; rsqrt_lut[41]=20;
        rsqrt_lut[42]=19; rsqrt_lut[43]=19; rsqrt_lut[44]=19;
        rsqrt_lut[45]=19; rsqrt_lut[46]=18; rsqrt_lut[47]=18;
        rsqrt_lut[48]=18; rsqrt_lut[49]=18; rsqrt_lut[50]=18;
        rsqrt_lut[51]=17; rsqrt_lut[52]=17; rsqrt_lut[53]=17;
        rsqrt_lut[54]=17; rsqrt_lut[55]=17; rsqrt_lut[56]=17;
        rsqrt_lut[57]=16; rsqrt_lut[58]=16; rsqrt_lut[59]=16;
        rsqrt_lut[60]=16; rsqrt_lut[61]=16; rsqrt_lut[62]=16;
        rsqrt_lut[63]=16; rsqrt_lut[64]=15; rsqrt_lut[65]=15;
        rsqrt_lut[66]=15; rsqrt_lut[67]=15; rsqrt_lut[68]=15;
        rsqrt_lut[69]=15; rsqrt_lut[70]=15; rsqrt_lut[71]=15;
        rsqrt_lut[72]=15; rsqrt_lut[73]=14; rsqrt_lut[74]=14;
        rsqrt_lut[75]=14; rsqrt_lut[76]=14; rsqrt_lut[77]=14;
        rsqrt_lut[78]=14; rsqrt_lut[79]=14; rsqrt_lut[80]=14;
        rsqrt_lut[81]=14; rsqrt_lut[82]=14; rsqrt_lut[83]=14;
        rsqrt_lut[84]=13; rsqrt_lut[85]=13; rsqrt_lut[86]=13;
        rsqrt_lut[87]=13; rsqrt_lut[88]=13; rsqrt_lut[89]=13;
        rsqrt_lut[90]=13; rsqrt_lut[91]=13; rsqrt_lut[92]=13;
        rsqrt_lut[93]=13; rsqrt_lut[94]=13; rsqrt_lut[95]=13;
        rsqrt_lut[96]=13; rsqrt_lut[97]=12; rsqrt_lut[98]=12;
        rsqrt_lut[99]=12; rsqrt_lut[100]=12;rsqrt_lut[101]=12;
        rsqrt_lut[102]=12;rsqrt_lut[103]=12;rsqrt_lut[104]=12;
        rsqrt_lut[105]=12;rsqrt_lut[106]=12;rsqrt_lut[107]=12;
        rsqrt_lut[108]=12;rsqrt_lut[109]=12;rsqrt_lut[110]=12;
        rsqrt_lut[111]=12;rsqrt_lut[112]=12;rsqrt_lut[113]=11;
        rsqrt_lut[114]=11;rsqrt_lut[115]=11;rsqrt_lut[116]=11;
        rsqrt_lut[117]=11;rsqrt_lut[118]=11;rsqrt_lut[119]=11;
        rsqrt_lut[120]=11;rsqrt_lut[121]=11;rsqrt_lut[122]=11;
        rsqrt_lut[123]=11;rsqrt_lut[124]=11;rsqrt_lut[125]=11;
        rsqrt_lut[126]=11;rsqrt_lut[127]=11;rsqrt_lut[128]=11;
        rsqrt_lut[129]=11;rsqrt_lut[130]=11;rsqrt_lut[131]=11;
        rsqrt_lut[132]=11;rsqrt_lut[133]=10;rsqrt_lut[134]=10;
        rsqrt_lut[135]=10;rsqrt_lut[136]=10;rsqrt_lut[137]=10;
        rsqrt_lut[138]=10;rsqrt_lut[139]=10;rsqrt_lut[140]=10;
        rsqrt_lut[141]=10;rsqrt_lut[142]=10;rsqrt_lut[143]=10;
        rsqrt_lut[144]=10;rsqrt_lut[145]=10;rsqrt_lut[146]=10;
        rsqrt_lut[147]=10;rsqrt_lut[148]=10;rsqrt_lut[149]=10;
        rsqrt_lut[150]=10;rsqrt_lut[151]=10;rsqrt_lut[152]=10;
        rsqrt_lut[153]=10;rsqrt_lut[154]=9; rsqrt_lut[155]=9;
        rsqrt_lut[156]=9; rsqrt_lut[157]=9; rsqrt_lut[158]=9;
        rsqrt_lut[159]=9; rsqrt_lut[160]=9; rsqrt_lut[161]=9;
        rsqrt_lut[162]=9; rsqrt_lut[163]=9; rsqrt_lut[164]=9;
        rsqrt_lut[165]=9; rsqrt_lut[166]=9; rsqrt_lut[167]=9;
        rsqrt_lut[168]=9; rsqrt_lut[169]=9; rsqrt_lut[170]=9;
        rsqrt_lut[171]=9; rsqrt_lut[172]=9; rsqrt_lut[173]=9;
        rsqrt_lut[174]=9; rsqrt_lut[175]=9; rsqrt_lut[176]=9;
        rsqrt_lut[177]=9; rsqrt_lut[178]=9; rsqrt_lut[179]=8;
        rsqrt_lut[180]=8; rsqrt_lut[181]=8; rsqrt_lut[182]=8;
        rsqrt_lut[183]=8; rsqrt_lut[184]=8; rsqrt_lut[185]=8;
        rsqrt_lut[186]=8; rsqrt_lut[187]=8; rsqrt_lut[188]=8;
        rsqrt_lut[189]=8; rsqrt_lut[190]=8; rsqrt_lut[191]=8;
        rsqrt_lut[192]=8; rsqrt_lut[193]=8; rsqrt_lut[194]=8;
        rsqrt_lut[195]=8; rsqrt_lut[196]=8; rsqrt_lut[197]=8;
        rsqrt_lut[198]=8; rsqrt_lut[199]=8; rsqrt_lut[200]=8;
        rsqrt_lut[201]=8; rsqrt_lut[202]=8; rsqrt_lut[203]=8;
        rsqrt_lut[204]=8; rsqrt_lut[205]=8; rsqrt_lut[206]=8;
        rsqrt_lut[207]=8; rsqrt_lut[208]=8; rsqrt_lut[209]=8;
        rsqrt_lut[210]=8; rsqrt_lut[211]=8; rsqrt_lut[212]=8;
        rsqrt_lut[213]=8; rsqrt_lut[214]=7; rsqrt_lut[215]=7;
        rsqrt_lut[216]=7; rsqrt_lut[217]=7; rsqrt_lut[218]=7;
        rsqrt_lut[219]=7; rsqrt_lut[220]=7; rsqrt_lut[221]=7;
        rsqrt_lut[222]=7; rsqrt_lut[223]=7; rsqrt_lut[224]=7;
        rsqrt_lut[225]=7; rsqrt_lut[226]=7; rsqrt_lut[227]=7;
        rsqrt_lut[228]=7; rsqrt_lut[229]=7; rsqrt_lut[230]=7;
        rsqrt_lut[231]=7; rsqrt_lut[232]=7; rsqrt_lut[233]=7;
        rsqrt_lut[234]=7; rsqrt_lut[235]=7; rsqrt_lut[236]=7;
        rsqrt_lut[237]=7; rsqrt_lut[238]=7; rsqrt_lut[239]=7;
        rsqrt_lut[240]=7; rsqrt_lut[241]=7; rsqrt_lut[242]=7;
        rsqrt_lut[243]=7; rsqrt_lut[244]=7; rsqrt_lut[245]=7;
        rsqrt_lut[246]=7; rsqrt_lut[247]=7; rsqrt_lut[248]=7;
        rsqrt_lut[249]=7; rsqrt_lut[250]=7; rsqrt_lut[251]=7;
        rsqrt_lut[252]=7; rsqrt_lut[253]=7; rsqrt_lut[254]=7;
        rsqrt_lut[255]=7;
    end

    // step 1 — compute mean
    wire signed [12:0] sum_all =
        x_0+x_1+x_2+x_3+x_4+x_5+x_6+x_7+
        x_8+x_9+x_10+x_11+x_12+x_13+x_14+x_15+
        x_16+x_17+x_18+x_19+x_20+x_21+x_22+x_23+
        x_24+x_25+x_26+x_27+x_28+x_29+x_30+x_31;
    wire signed [7:0] mean = sum_all >>> 5; // divide by 32

    // step 2 — compute differences from mean
    wire signed [7:0] d0=x_0-mean;   wire signed [7:0] d1=x_1-mean;
    wire signed [7:0] d2=x_2-mean;   wire signed [7:0] d3=x_3-mean;
    wire signed [7:0] d4=x_4-mean;   wire signed [7:0] d5=x_5-mean;
    wire signed [7:0] d6=x_6-mean;   wire signed [7:0] d7=x_7-mean;
    wire signed [7:0] d8=x_8-mean;   wire signed [7:0] d9=x_9-mean;
    wire signed [7:0] d10=x_10-mean; wire signed [7:0] d11=x_11-mean;
    wire signed [7:0] d12=x_12-mean; wire signed [7:0] d13=x_13-mean;
    wire signed [7:0] d14=x_14-mean; wire signed [7:0] d15=x_15-mean;
    wire signed [7:0] d16=x_16-mean; wire signed [7:0] d17=x_17-mean;
    wire signed [7:0] d18=x_18-mean; wire signed [7:0] d19=x_19-mean;
    wire signed [7:0] d20=x_20-mean; wire signed [7:0] d21=x_21-mean;
    wire signed [7:0] d22=x_22-mean; wire signed [7:0] d23=x_23-mean;
    wire signed [7:0] d24=x_24-mean; wire signed [7:0] d25=x_25-mean;
    wire signed [7:0] d26=x_26-mean; wire signed [7:0] d27=x_27-mean;
    wire signed [7:0] d28=x_28-mean; wire signed [7:0] d29=x_29-mean;
    wire signed [7:0] d30=x_30-mean; wire signed [7:0] d31=x_31-mean;

    // step 3 — compute variance
    wire [17:0] var_sum =
        d0*d0+d1*d1+d2*d2+d3*d3+d4*d4+d5*d5+d6*d6+d7*d7+
        d8*d8+d9*d9+d10*d10+d11*d11+d12*d12+d13*d13+d14*d14+d15*d15+
        d16*d16+d17*d17+d18*d18+d19*d19+d20*d20+d21*d21+d22*d22+d23*d23+
        d24*d24+d25*d25+d26*d26+d27*d27+d28*d28+d29*d29+d30*d30+d31*d31;
    wire [12:0] variance = var_sum >> 5; // divide by 32

    // step 4 — reciprocal sqrt lookup
    wire [7:0] inv_std = rsqrt_lut[variance[7:0]];

    // helper function to clamp to INT8
    function signed [7:0] clamp8;
        input signed [15:0] val;
        begin
            if (val > 127)  clamp8 = 8'sd127;
            else if (val < -128) clamp8 = -8'sd128;
            else clamp8 = val[7:0];
        end
    endfunction

    // step 5 — normalise scale and shift
    always @(posedge clk) begin
        if (!rst_n) begin
            y_0<=0; y_1<=0; y_2<=0; y_3<=0;
            y_4<=0; y_5<=0; y_6<=0; y_7<=0;
            y_8<=0; y_9<=0; y_10<=0; y_11<=0;
            y_12<=0; y_13<=0; y_14<=0; y_15<=0;
            y_16<=0; y_17<=0; y_18<=0; y_19<=0;
            y_20<=0; y_21<=0; y_22<=0; y_23<=0;
            y_24<=0; y_25<=0; y_26<=0; y_27<=0;
            y_28<=0; y_29<=0; y_30<=0; y_31<=0;
            done <= 0;
        end else if (ln_en) begin
            y_0  <= clamp8((d0  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_1  <= clamp8((d1  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_2  <= clamp8((d2  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_3  <= clamp8((d3  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_4  <= clamp8((d4  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_5  <= clamp8((d5  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_6  <= clamp8((d6  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_7  <= clamp8((d7  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_8  <= clamp8((d8  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_9  <= clamp8((d9  * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_10 <= clamp8((d10 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_11 <= clamp8((d11 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_12 <= clamp8((d12 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_13 <= clamp8((d13 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_14 <= clamp8((d14 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_15 <= clamp8((d15 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_16 <= clamp8((d16 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_17 <= clamp8((d17 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_18 <= clamp8((d18 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_19 <= clamp8((d19 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_20 <= clamp8((d20 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_21 <= clamp8((d21 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_22 <= clamp8((d22 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_23 <= clamp8((d23 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_24 <= clamp8((d24 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_25 <= clamp8((d25 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_26 <= clamp8((d26 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_27 <= clamp8((d27 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_28 <= clamp8((d28 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_29 <= clamp8((d29 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_30 <= clamp8((d30 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            y_31 <= clamp8((d31 * $signed({1'b0,inv_std}) >>> 7) * gamma + beta);
            done <= 1;
        end else done <= 0;
    end
endmodule
