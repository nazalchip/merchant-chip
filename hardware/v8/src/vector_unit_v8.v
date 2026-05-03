// ═══════════════════════════════════════════════════════
//  MERCHANT V8 — Vector Processing Unit
//  vector_unit_v8.v
//
//  32-wide vector processor
//  New in V8 vs V7: SIGMOID and TANH approximations
//  Uses lookup tables — same approach as softmax
//  SIGMOID: 1/(1+e^-x) — used in LSTM gates
//  TANH: (e^x-e^-x)/(e^x+e^-x) — used in LSTM output
// ═══════════════════════════════════════════════════════
module vector_unit_v8 (
    input  wire        clk, rst_n,
    input  wire        vu_en,
    input  wire [2:0]  op_code,
    input  wire [3:0]  shift_amt,
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
    localparam OP_ADD     = 3'd0;
    localparam OP_MAX     = 3'd1;
    localparam OP_MIN     = 3'd2;
    localparam OP_ABS     = 3'd3;
    localparam OP_SHR     = 3'd4;
    localparam OP_MUL     = 3'd5;
    localparam OP_SIGMOID = 3'd6;  // new in V8
    localparam OP_TANH    = 3'd7;  // new in V8

    // sigmoid lookup table
    // sigmoid(x) = 1/(1+e^-x) scaled to INT8 0-127
    reg [7:0] sigmoid_lut [0:255];
    initial begin
        // negative inputs — sigmoid approaches 0
        sigmoid_lut[0]=0;   sigmoid_lut[1]=0;
        sigmoid_lut[2]=0;   sigmoid_lut[3]=0;
        sigmoid_lut[4]=0;   sigmoid_lut[5]=0;
        sigmoid_lut[6]=0;   sigmoid_lut[7]=0;
        sigmoid_lut[8]=0;   sigmoid_lut[9]=0;
        sigmoid_lut[10]=0;  sigmoid_lut[11]=0;
        sigmoid_lut[12]=0;  sigmoid_lut[13]=0;
        sigmoid_lut[14]=0;  sigmoid_lut[15]=0;
        sigmoid_lut[16]=0;  sigmoid_lut[17]=0;
        sigmoid_lut[18]=0;  sigmoid_lut[19]=0;
        sigmoid_lut[20]=0;  sigmoid_lut[21]=0;
        sigmoid_lut[22]=0;  sigmoid_lut[23]=0;
        sigmoid_lut[24]=0;  sigmoid_lut[25]=0;
        sigmoid_lut[26]=0;  sigmoid_lut[27]=0;
        sigmoid_lut[28]=0;  sigmoid_lut[29]=0;
        sigmoid_lut[30]=0;  sigmoid_lut[31]=0;
        sigmoid_lut[32]=0;  sigmoid_lut[33]=0;
        sigmoid_lut[34]=0;  sigmoid_lut[35]=0;
        sigmoid_lut[36]=0;  sigmoid_lut[37]=0;
        sigmoid_lut[38]=0;  sigmoid_lut[39]=0;
        sigmoid_lut[40]=0;  sigmoid_lut[41]=0;
        sigmoid_lut[42]=0;  sigmoid_lut[43]=0;
        sigmoid_lut[44]=0;  sigmoid_lut[45]=0;
        sigmoid_lut[46]=0;  sigmoid_lut[47]=0;
        sigmoid_lut[48]=0;  sigmoid_lut[49]=0;
        sigmoid_lut[50]=0;  sigmoid_lut[51]=0;
        sigmoid_lut[52]=0;  sigmoid_lut[53]=0;
        sigmoid_lut[54]=0;  sigmoid_lut[55]=0;
        sigmoid_lut[56]=0;  sigmoid_lut[57]=0;
        sigmoid_lut[58]=0;  sigmoid_lut[59]=0;
        sigmoid_lut[60]=0;  sigmoid_lut[61]=0;
        sigmoid_lut[62]=0;  sigmoid_lut[63]=0;
        sigmoid_lut[64]=0;  sigmoid_lut[65]=0;
        sigmoid_lut[66]=0;  sigmoid_lut[67]=0;
        sigmoid_lut[68]=0;  sigmoid_lut[69]=0;
        sigmoid_lut[70]=0;  sigmoid_lut[71]=0;
        sigmoid_lut[72]=0;  sigmoid_lut[73]=0;
        sigmoid_lut[74]=0;  sigmoid_lut[75]=0;
        sigmoid_lut[76]=0;  sigmoid_lut[77]=0;
        sigmoid_lut[78]=0;  sigmoid_lut[79]=0;
        sigmoid_lut[80]=0;  sigmoid_lut[81]=0;
        sigmoid_lut[82]=0;  sigmoid_lut[83]=0;
        sigmoid_lut[84]=0;  sigmoid_lut[85]=0;
        sigmoid_lut[86]=0;  sigmoid_lut[87]=0;
        sigmoid_lut[88]=0;  sigmoid_lut[89]=0;
        sigmoid_lut[90]=0;  sigmoid_lut[91]=0;
        sigmoid_lut[92]=0;  sigmoid_lut[93]=0;
        sigmoid_lut[94]=0;  sigmoid_lut[95]=0;
        sigmoid_lut[96]=0;  sigmoid_lut[97]=0;
        sigmoid_lut[98]=0;  sigmoid_lut[99]=0;
        sigmoid_lut[100]=0; sigmoid_lut[101]=1;
        sigmoid_lut[102]=1; sigmoid_lut[103]=1;
        sigmoid_lut[104]=1; sigmoid_lut[105]=1;
        sigmoid_lut[106]=2; sigmoid_lut[107]=2;
        sigmoid_lut[108]=3; sigmoid_lut[109]=3;
        sigmoid_lut[110]=4; sigmoid_lut[111]=5;
        sigmoid_lut[112]=6; sigmoid_lut[113]=8;
        sigmoid_lut[114]=10;sigmoid_lut[115]=12;
        sigmoid_lut[116]=15;sigmoid_lut[117]=18;
        sigmoid_lut[118]=22;sigmoid_lut[119]=27;
        sigmoid_lut[120]=32;sigmoid_lut[121]=38;
        sigmoid_lut[122]=44;sigmoid_lut[123]=50;
        sigmoid_lut[124]=56;sigmoid_lut[125]=61;
        sigmoid_lut[126]=64;
        // index 128 = x=0, sigmoid(0)=0.5 = 64 scaled
        sigmoid_lut[127]=64; sigmoid_lut[128]=64;
        sigmoid_lut[129]=67; sigmoid_lut[130]=71;
        sigmoid_lut[131]=76; sigmoid_lut[132]=81;
        sigmoid_lut[133]=86; sigmoid_lut[134]=90;
        sigmoid_lut[135]=95; sigmoid_lut[136]=99;
        sigmoid_lut[137]=103;sigmoid_lut[138]=106;
        sigmoid_lut[139]=109;sigmoid_lut[140]=112;
        sigmoid_lut[141]=114;sigmoid_lut[142]=117;
        sigmoid_lut[143]=119;sigmoid_lut[144]=120;
        sigmoid_lut[145]=122;sigmoid_lut[146]=123;
        sigmoid_lut[147]=124;sigmoid_lut[148]=125;
        sigmoid_lut[149]=126;sigmoid_lut[150]=126;
        sigmoid_lut[151]=127;sigmoid_lut[152]=127;
        sigmoid_lut[153]=127;sigmoid_lut[154]=127;
        // positive values — sigmoid approaches 1 = 127
        sigmoid_lut[155]=127;sigmoid_lut[156]=127;
        sigmoid_lut[157]=127;sigmoid_lut[158]=127;
        sigmoid_lut[159]=127;sigmoid_lut[160]=127;
        sigmoid_lut[161]=127;sigmoid_lut[162]=127;
        sigmoid_lut[163]=127;sigmoid_lut[164]=127;
        sigmoid_lut[165]=127;sigmoid_lut[166]=127;
        sigmoid_lut[167]=127;sigmoid_lut[168]=127;
        sigmoid_lut[169]=127;sigmoid_lut[170]=127;
        sigmoid_lut[171]=127;sigmoid_lut[172]=127;
        sigmoid_lut[173]=127;sigmoid_lut[174]=127;
        sigmoid_lut[175]=127;sigmoid_lut[176]=127;
        sigmoid_lut[177]=127;sigmoid_lut[178]=127;
        sigmoid_lut[179]=127;sigmoid_lut[180]=127;
        sigmoid_lut[181]=127;sigmoid_lut[182]=127;
        sigmoid_lut[183]=127;sigmoid_lut[184]=127;
        sigmoid_lut[185]=127;sigmoid_lut[186]=127;
        sigmoid_lut[187]=127;sigmoid_lut[188]=127;
        sigmoid_lut[189]=127;sigmoid_lut[190]=127;
        sigmoid_lut[191]=127;sigmoid_lut[192]=127;
        sigmoid_lut[193]=127;sigmoid_lut[194]=127;
        sigmoid_lut[195]=127;sigmoid_lut[196]=127;
        sigmoid_lut[197]=127;sigmoid_lut[198]=127;
        sigmoid_lut[199]=127;sigmoid_lut[200]=127;
        sigmoid_lut[201]=127;sigmoid_lut[202]=127;
        sigmoid_lut[203]=127;sigmoid_lut[204]=127;
        sigmoid_lut[205]=127;sigmoid_lut[206]=127;
        sigmoid_lut[207]=127;sigmoid_lut[208]=127;
        sigmoid_lut[209]=127;sigmoid_lut[210]=127;
        sigmoid_lut[211]=127;sigmoid_lut[212]=127;
        sigmoid_lut[213]=127;sigmoid_lut[214]=127;
        sigmoid_lut[215]=127;sigmoid_lut[216]=127;
        sigmoid_lut[217]=127;sigmoid_lut[218]=127;
        sigmoid_lut[219]=127;sigmoid_lut[220]=127;
        sigmoid_lut[221]=127;sigmoid_lut[222]=127;
        sigmoid_lut[223]=127;sigmoid_lut[224]=127;
        sigmoid_lut[225]=127;sigmoid_lut[226]=127;
        sigmoid_lut[227]=127;sigmoid_lut[228]=127;
        sigmoid_lut[229]=127;sigmoid_lut[230]=127;
        sigmoid_lut[231]=127;sigmoid_lut[232]=127;
        sigmoid_lut[233]=127;sigmoid_lut[234]=127;
        sigmoid_lut[235]=127;sigmoid_lut[236]=127;
        sigmoid_lut[237]=127;sigmoid_lut[238]=127;
        sigmoid_lut[239]=127;sigmoid_lut[240]=127;
        sigmoid_lut[241]=127;sigmoid_lut[242]=127;
        sigmoid_lut[243]=127;sigmoid_lut[244]=127;
        sigmoid_lut[245]=127;sigmoid_lut[246]=127;
        sigmoid_lut[247]=127;sigmoid_lut[248]=127;
        sigmoid_lut[249]=127;sigmoid_lut[250]=127;
        sigmoid_lut[251]=127;sigmoid_lut[252]=127;
        sigmoid_lut[253]=127;sigmoid_lut[254]=127;
        sigmoid_lut[255]=127;
    end

    // tanh lookup table
    // tanh(x) scaled to INT8 -127 to 127
    reg signed [7:0] tanh_lut [0:255];
    initial begin
        tanh_lut[0]=-127; tanh_lut[1]=-127; tanh_lut[2]=-127;
        tanh_lut[3]=-127; tanh_lut[4]=-127; tanh_lut[5]=-127;
        tanh_lut[6]=-127; tanh_lut[7]=-127; tanh_lut[8]=-127;
        tanh_lut[9]=-127; tanh_lut[10]=-127;tanh_lut[11]=-127;
        tanh_lut[12]=-127;tanh_lut[13]=-127;tanh_lut[14]=-127;
        tanh_lut[15]=-127;tanh_lut[16]=-127;tanh_lut[17]=-127;
        tanh_lut[18]=-127;tanh_lut[19]=-127;tanh_lut[20]=-127;
        tanh_lut[21]=-127;tanh_lut[22]=-127;tanh_lut[23]=-127;
        tanh_lut[24]=-127;tanh_lut[25]=-127;tanh_lut[26]=-127;
        tanh_lut[27]=-127;tanh_lut[28]=-127;tanh_lut[29]=-127;
        tanh_lut[30]=-127;tanh_lut[31]=-127;tanh_lut[32]=-127;
        tanh_lut[33]=-127;tanh_lut[34]=-127;tanh_lut[35]=-127;
        tanh_lut[36]=-127;tanh_lut[37]=-127;tanh_lut[38]=-127;
        tanh_lut[39]=-127;tanh_lut[40]=-127;tanh_lut[41]=-127;
        tanh_lut[42]=-127;tanh_lut[43]=-127;tanh_lut[44]=-127;
        tanh_lut[45]=-127;tanh_lut[46]=-127;tanh_lut[47]=-127;
        tanh_lut[48]=-127;tanh_lut[49]=-127;tanh_lut[50]=-127;
        tanh_lut[51]=-127;tanh_lut[52]=-127;tanh_lut[53]=-127;
        tanh_lut[54]=-127;tanh_lut[55]=-127;tanh_lut[56]=-127;
        tanh_lut[57]=-127;tanh_lut[58]=-127;tanh_lut[59]=-127;
        tanh_lut[60]=-127;tanh_lut[61]=-127;tanh_lut[62]=-127;
        tanh_lut[63]=-127;tanh_lut[64]=-127;tanh_lut[65]=-127;
        tanh_lut[66]=-127;tanh_lut[67]=-127;tanh_lut[68]=-127;
        tanh_lut[69]=-127;tanh_lut[70]=-127;tanh_lut[71]=-127;
        tanh_lut[72]=-127;tanh_lut[73]=-127;tanh_lut[74]=-127;
        tanh_lut[75]=-127;tanh_lut[76]=-127;tanh_lut[77]=-127;
        tanh_lut[78]=-127;tanh_lut[79]=-127;tanh_lut[80]=-127;
        tanh_lut[81]=-127;tanh_lut[82]=-127;tanh_lut[83]=-127;
        tanh_lut[84]=-127;tanh_lut[85]=-127;tanh_lut[86]=-127;
        tanh_lut[87]=-127;tanh_lut[88]=-127;tanh_lut[89]=-127;
        tanh_lut[90]=-127;tanh_lut[91]=-127;tanh_lut[92]=-127;
        tanh_lut[93]=-127;tanh_lut[94]=-127;tanh_lut[95]=-127;
        tanh_lut[96]=-127;tanh_lut[97]=-127;tanh_lut[98]=-127;
        tanh_lut[99]=-127;tanh_lut[100]=-127;tanh_lut[101]=-126;
        tanh_lut[102]=-125;tanh_lut[103]=-124;tanh_lut[104]=-122;
        tanh_lut[105]=-120;tanh_lut[106]=-117;tanh_lut[107]=-113;
        tanh_lut[108]=-108;tanh_lut[109]=-102;tanh_lut[110]=-95;
        tanh_lut[111]=-87; tanh_lut[112]=-77; tanh_lut[113]=-66;
        tanh_lut[114]=-54; tanh_lut[115]=-41; tanh_lut[116]=-28;
        tanh_lut[117]=-15; tanh_lut[118]=-2;  tanh_lut[119]=10;
        tanh_lut[120]=22;  tanh_lut[121]=33;  tanh_lut[122]=43;
        tanh_lut[123]=52;  tanh_lut[124]=60;  tanh_lut[125]=67;
        tanh_lut[126]=73;
        // index 128 = x=0, tanh(0)=0
        tanh_lut[127]=0; tanh_lut[128]=0;
        tanh_lut[129]=8;  tanh_lut[130]=15; tanh_lut[131]=22;
        tanh_lut[132]=29; tanh_lut[133]=35; tanh_lut[134]=41;
        tanh_lut[135]=46; tanh_lut[136]=51; tanh_lut[137]=56;
        tanh_lut[138]=60; tanh_lut[139]=63; tanh_lut[140]=67;
        tanh_lut[141]=70; tanh_lut[142]=72; tanh_lut[143]=75;
        tanh_lut[144]=77; tanh_lut[145]=79; tanh_lut[146]=80;
        tanh_lut[147]=82; tanh_lut[148]=83; tanh_lut[149]=84;
        tanh_lut[150]=85; tanh_lut[151]=86; tanh_lut[152]=87;
        tanh_lut[153]=88; tanh_lut[154]=89; tanh_lut[155]=90;
        tanh_lut[156]=90; tanh_lut[157]=91; tanh_lut[158]=91;
        tanh_lut[159]=92; tanh_lut[160]=92; tanh_lut[161]=93;
        tanh_lut[162]=93; tanh_lut[163]=93; tanh_lut[164]=94;
        tanh_lut[165]=94; tanh_lut[166]=94; tanh_lut[167]=95;
        tanh_lut[168]=95; tanh_lut[169]=95; tanh_lut[170]=95;
        tanh_lut[171]=96; tanh_lut[172]=96; tanh_lut[173]=96;
        tanh_lut[174]=96; tanh_lut[175]=96; tanh_lut[176]=96;
        tanh_lut[177]=97; tanh_lut[178]=97; tanh_lut[179]=97;
        tanh_lut[180]=127;tanh_lut[181]=127;tanh_lut[182]=127;
        tanh_lut[183]=127;tanh_lut[184]=127;tanh_lut[185]=127;
        tanh_lut[186]=127;tanh_lut[187]=127;tanh_lut[188]=127;
        tanh_lut[189]=127;tanh_lut[190]=127;tanh_lut[191]=127;
        tanh_lut[192]=127;tanh_lut[193]=127;tanh_lut[194]=127;
        tanh_lut[195]=127;tanh_lut[196]=127;tanh_lut[197]=127;
        tanh_lut[198]=127;tanh_lut[199]=127;tanh_lut[200]=127;
        tanh_lut[201]=127;tanh_lut[202]=127;tanh_lut[203]=127;
        tanh_lut[204]=127;tanh_lut[205]=127;tanh_lut[206]=127;
        tanh_lut[207]=127;tanh_lut[208]=127;tanh_lut[209]=127;
        tanh_lut[210]=127;tanh_lut[211]=127;tanh_lut[212]=127;
        tanh_lut[213]=127;tanh_lut[214]=127;tanh_lut[215]=127;
        tanh_lut[216]=127;tanh_lut[217]=127;tanh_lut[218]=127;
        tanh_lut[219]=127;tanh_lut[220]=127;tanh_lut[221]=127;
        tanh_lut[222]=127;tanh_lut[223]=127;tanh_lut[224]=127;
        tanh_lut[225]=127;tanh_lut[226]=127;tanh_lut[227]=127;
        tanh_lut[228]=127;tanh_lut[229]=127;tanh_lut[230]=127;
        tanh_lut[231]=127;tanh_lut[232]=127;tanh_lut[233]=127;
        tanh_lut[234]=127;tanh_lut[235]=127;tanh_lut[236]=127;
        tanh_lut[237]=127;tanh_lut[238]=127;tanh_lut[239]=127;
        tanh_lut[240]=127;tanh_lut[241]=127;tanh_lut[242]=127;
        tanh_lut[243]=127;tanh_lut[244]=127;tanh_lut[245]=127;
        tanh_lut[246]=127;tanh_lut[247]=127;tanh_lut[248]=127;
        tanh_lut[249]=127;tanh_lut[250]=127;tanh_lut[251]=127;
        tanh_lut[252]=127;tanh_lut[253]=127;tanh_lut[254]=127;
        tanh_lut[255]=127;
    end

    // vector operation function
    function signed [7:0] vec_op;
        input signed [7:0] a, b;
        input [2:0] op;
        input [3:0] sh;
        reg signed [15:0] tmp;
        reg [7:0] idx;
        begin
            case (op)
                OP_ADD: begin
                    tmp = a + b;
                    if (tmp>127) vec_op=8'sd127;
                    else if(tmp<-128) vec_op=-8'sd128;
                    else vec_op=tmp[7:0];
                end
                OP_MAX:     vec_op = (a>b) ? a : b;
                OP_MIN:     vec_op = (a<b) ? a : b;
                OP_ABS:     vec_op = (a<0) ? -a : a;
                OP_SHR:     vec_op = a >>> sh;
                OP_MUL: begin
                    tmp = a * b;
                    vec_op = tmp[11:4];
                end
                OP_SIGMOID: begin
                    idx = $unsigned(a) + 8'd128;
                    vec_op = $signed({1'b0, sigmoid_lut[idx]});
                end
                OP_TANH: begin
                    idx = $unsigned(a) + 8'd128;
                    vec_op = tanh_lut[idx];
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
        end else done <= 0;
    end
endmodule
