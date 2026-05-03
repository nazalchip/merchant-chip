module systolic_array_32x32 (
    input  wire        clk, rst_n,
    input  wire [31:0] row_en,
    input  wire        acc_en, acc_clear,
    input  wire signed [7:0] act_in_0,  act_in_1,  act_in_2,  act_in_3,
    input  wire signed [7:0] act_in_4,  act_in_5,  act_in_6,  act_in_7,
    input  wire signed [7:0] act_in_8,  act_in_9,  act_in_10, act_in_11,
    input  wire signed [7:0] act_in_12, act_in_13, act_in_14, act_in_15,
    input  wire signed [7:0] act_in_16, act_in_17, act_in_18, act_in_19,
    input  wire signed [7:0] act_in_20, act_in_21, act_in_22, act_in_23,
    input  wire signed [7:0] act_in_24, act_in_25, act_in_26, act_in_27,
    input  wire signed [7:0] act_in_28, act_in_29, act_in_30, act_in_31,
    // weights as individual ports — no array ports
    input  wire signed [7:0] w_0,  w_1,  w_2,  w_3,  w_4,  w_5,  w_6,  w_7,
    input  wire signed [7:0] w_8,  w_9,  w_10, w_11, w_12, w_13, w_14, w_15,
    input  wire signed [7:0] w_16, w_17, w_18, w_19, w_20, w_21, w_22, w_23,
    input  wire signed [7:0] w_24, w_25, w_26, w_27, w_28, w_29, w_30, w_31,
    input  wire signed [7:0] w_32, w_33, w_34, w_35, w_36, w_37, w_38, w_39,
    input  wire signed [7:0] w_40, w_41, w_42, w_43, w_44, w_45, w_46, w_47,
    input  wire signed [7:0] w_48, w_49, w_50, w_51, w_52, w_53, w_54, w_55,
    input  wire signed [7:0] w_56, w_57, w_58, w_59, w_60, w_61, w_62, w_63,
    input  wire signed [7:0] w_64, w_65, w_66, w_67, w_68, w_69, w_70, w_71,
    input  wire signed [7:0] w_72, w_73, w_74, w_75, w_76, w_77, w_78, w_79,
    input  wire signed [7:0] w_80, w_81, w_82, w_83, w_84, w_85, w_86, w_87,
    input  wire signed [7:0] w_88, w_89, w_90, w_91, w_92, w_93, w_94, w_95,
    input  wire signed [7:0] w_96, w_97, w_98, w_99, w_100,w_101,w_102,w_103,
    input  wire signed [7:0] w_104,w_105,w_106,w_107,w_108,w_109,w_110,w_111,
    input  wire signed [7:0] w_112,w_113,w_114,w_115,w_116,w_117,w_118,w_119,
    input  wire signed [7:0] w_120,w_121,w_122,w_123,w_124,w_125,w_126,w_127,
    input  wire signed [7:0] w_128,w_129,w_130,w_131,w_132,w_133,w_134,w_135,
    input  wire signed [7:0] w_136,w_137,w_138,w_139,w_140,w_141,w_142,w_143,
    input  wire signed [7:0] w_144,w_145,w_146,w_147,w_148,w_149,w_150,w_151,
    input  wire signed [7:0] w_152,w_153,w_154,w_155,w_156,w_157,w_158,w_159,
    input  wire signed [7:0] w_160,w_161,w_162,w_163,w_164,w_165,w_166,w_167,
    input  wire signed [7:0] w_168,w_169,w_170,w_171,w_172,w_173,w_174,w_175,
    input  wire signed [7:0] w_176,w_177,w_178,w_179,w_180,w_181,w_182,w_183,
    input  wire signed [7:0] w_184,w_185,w_186,w_187,w_188,w_189,w_190,w_191,
    input  wire signed [7:0] w_192,w_193,w_194,w_195,w_196,w_197,w_198,w_199,
    input  wire signed [7:0] w_200,w_201,w_202,w_203,w_204,w_205,w_206,w_207,
    input  wire signed [7:0] w_208,w_209,w_210,w_211,w_212,w_213,w_214,w_215,
    input  wire signed [7:0] w_216,w_217,w_218,w_219,w_220,w_221,w_222,w_223,
    input  wire signed [7:0] w_224,w_225,w_226,w_227,w_228,w_229,w_230,w_231,
    input  wire signed [7:0] w_232,w_233,w_234,w_235,w_236,w_237,w_238,w_239,
    input  wire signed [7:0] w_240,w_241,w_242,w_243,w_244,w_245,w_246,w_247,
    input  wire signed [7:0] w_248,w_249,w_250,w_251,w_252,w_253,w_254,w_255,
    input  wire signed [7:0] w_256,w_257,w_258,w_259,w_260,w_261,w_262,w_263,
    input  wire signed [7:0] w_264,w_265,w_266,w_267,w_268,w_269,w_270,w_271,
    input  wire signed [7:0] w_272,w_273,w_274,w_275,w_276,w_277,w_278,w_279,
    input  wire signed [7:0] w_280,w_281,w_282,w_283,w_284,w_285,w_286,w_287,
    input  wire signed [7:0] w_288,w_289,w_290,w_291,w_292,w_293,w_294,w_295,
    input  wire signed [7:0] w_296,w_297,w_298,w_299,w_300,w_301,w_302,w_303,
    input  wire signed [7:0] w_304,w_305,w_306,w_307,w_308,w_309,w_310,w_311,
    input  wire signed [7:0] w_312,w_313,w_314,w_315,w_316,w_317,w_318,w_319,
    input  wire signed [7:0] w_320,w_321,w_322,w_323,w_324,w_325,w_326,w_327,
    input  wire signed [7:0] w_328,w_329,w_330,w_331,w_332,w_333,w_334,w_335,
    input  wire signed [7:0] w_336,w_337,w_338,w_339,w_340,w_341,w_342,w_343,
    input  wire signed [7:0] w_344,w_345,w_346,w_347,w_348,w_349,w_350,w_351,
    input  wire signed [7:0] w_352,w_353,w_354,w_355,w_356,w_357,w_358,w_359,
    input  wire signed [7:0] w_360,w_361,w_362,w_363,w_364,w_365,w_366,w_367,
    input  wire signed [7:0] w_368,w_369,w_370,w_371,w_372,w_373,w_374,w_375,
    input  wire signed [7:0] w_376,w_377,w_378,w_379,w_380,w_381,w_382,w_383,
    input  wire signed [7:0] w_384,w_385,w_386,w_387,w_388,w_389,w_390,w_391,
    input  wire signed [7:0] w_392,w_393,w_394,w_395,w_396,w_397,w_398,w_399,
    input  wire signed [7:0] w_400,w_401,w_402,w_403,w_404,w_405,w_406,w_407,
    input  wire signed [7:0] w_408,w_409,w_410,w_411,w_412,w_413,w_414,w_415,
    input  wire signed [7:0] w_416,w_417,w_418,w_419,w_420,w_421,w_422,w_423,
    input  wire signed [7:0] w_424,w_425,w_426,w_427,w_428,w_429,w_430,w_431,
    input  wire signed [7:0] w_432,w_433,w_434,w_435,w_436,w_437,w_438,w_439,
    input  wire signed [7:0] w_440,w_441,w_442,w_443,w_444,w_445,w_446,w_447,
    input  wire signed [7:0] w_448,w_449,w_450,w_451,w_452,w_453,w_454,w_455,
    input  wire signed [7:0] w_456,w_457,w_458,w_459,w_460,w_461,w_462,w_463,
    input  wire signed [7:0] w_464,w_465,w_466,w_467,w_468,w_469,w_470,w_471,
    input  wire signed [7:0] w_472,w_473,w_474,w_475,w_476,w_477,w_478,w_479,
    input  wire signed [7:0] w_480,w_481,w_482,w_483,w_484,w_485,w_486,w_487,
    input  wire signed [7:0] w_488,w_489,w_490,w_491,w_492,w_493,w_494,w_495,
    input  wire signed [7:0] w_496,w_497,w_498,w_499,w_500,w_501,w_502,w_503,
    input  wire signed [7:0] w_504,w_505,w_506,w_507,w_508,w_509,w_510,w_511,
    input  wire signed [7:0] w_512,w_513,w_514,w_515,w_516,w_517,w_518,w_519,
    input  wire signed [7:0] w_520,w_521,w_522,w_523,w_524,w_525,w_526,w_527,
    input  wire signed [7:0] w_528,w_529,w_530,w_531,w_532,w_533,w_534,w_535,
    input  wire signed [7:0] w_536,w_537,w_538,w_539,w_540,w_541,w_542,w_543,
    input  wire signed [7:0] w_544,w_545,w_546,w_547,w_548,w_549,w_550,w_551,
    input  wire signed [7:0] w_552,w_553,w_554,w_555,w_556,w_557,w_558,w_559,
    input  wire signed [7:0] w_560,w_561,w_562,w_563,w_564,w_565,w_566,w_567,
    input  wire signed [7:0] w_568,w_569,w_570,w_571,w_572,w_573,w_574,w_575,
    input  wire signed [7:0] w_576,w_577,w_578,w_579,w_580,w_581,w_582,w_583,
    input  wire signed [7:0] w_584,w_585,w_586,w_587,w_588,w_589,w_590,w_591,
    input  wire signed [7:0] w_592,w_593,w_594,w_595,w_596,w_597,w_598,w_599,
    input  wire signed [7:0] w_600,w_601,w_602,w_603,w_604,w_605,w_606,w_607,
    input  wire signed [7:0] w_608,w_609,w_610,w_611,w_612,w_613,w_614,w_615,
    input  wire signed [7:0] w_616,w_617,w_618,w_619,w_620,w_621,w_622,w_623,
    input  wire signed [7:0] w_624,w_625,w_626,w_627,w_628,w_629,w_630,w_631,
    input  wire signed [7:0] w_632,w_633,w_634,w_635,w_636,w_637,w_638,w_639,
    input  wire signed [7:0] w_640,w_641,w_642,w_643,w_644,w_645,w_646,w_647,
    input  wire signed [7:0] w_648,w_649,w_650,w_651,w_652,w_653,w_654,w_655,
    input  wire signed [7:0] w_656,w_657,w_658,w_659,w_660,w_661,w_662,w_663,
    input  wire signed [7:0] w_664,w_665,w_666,w_667,w_668,w_669,w_670,w_671,
    input  wire signed [7:0] w_672,w_673,w_674,w_675,w_676,w_677,w_678,w_679,
    input  wire signed [7:0] w_680,w_681,w_682,w_683,w_684,w_685,w_686,w_687,
    input  wire signed [7:0] w_688,w_689,w_690,w_691,w_692,w_693,w_694,w_695,
    input  wire signed [7:0] w_696,w_697,w_698,w_699,w_700,w_701,w_702,w_703,
    input  wire signed [7:0] w_704,w_705,w_706,w_707,w_708,w_709,w_710,w_711,
    input  wire signed [7:0] w_712,w_713,w_714,w_715,w_716,w_717,w_718,w_719,
    input  wire signed [7:0] w_720,w_721,w_722,w_723,w_724,w_725,w_726,w_727,
    input  wire signed [7:0] w_728,w_729,w_730,w_731,w_732,w_733,w_734,w_735,
    input  wire signed [7:0] w_736,w_737,w_738,w_739,w_740,w_741,w_742,w_743,
    input  wire signed [7:0] w_744,w_745,w_746,w_747,w_748,w_749,w_750,w_751,
    input  wire signed [7:0] w_752,w_753,w_754,w_755,w_756,w_757,w_758,w_759,
    input  wire signed [7:0] w_760,w_761,w_762,w_763,w_764,w_765,w_766,w_767,
    input  wire signed [7:0] w_768,w_769,w_770,w_771,w_772,w_773,w_774,w_775,
    input  wire signed [7:0] w_776,w_777,w_778,w_779,w_780,w_781,w_782,w_783,
    input  wire signed [7:0] w_784,w_785,w_786,w_787,w_788,w_789,w_790,w_791,
    input  wire signed [7:0] w_792,w_793,w_794,w_795,w_796,w_797,w_798,w_799,
    input  wire signed [7:0] w_800,w_801,w_802,w_803,w_804,w_805,w_806,w_807,
    input  wire signed [7:0] w_808,w_809,w_810,w_811,w_812,w_813,w_814,w_815,
    input  wire signed [7:0] w_816,w_817,w_818,w_819,w_820,w_821,w_822,w_823,
    input  wire signed [7:0] w_824,w_825,w_826,w_827,w_828,w_829,w_830,w_831,
    input  wire signed [7:0] w_832,w_833,w_834,w_835,w_836,w_837,w_838,w_839,
    input  wire signed [7:0] w_840,w_841,w_842,w_843,w_844,w_845,w_846,w_847,
    input  wire signed [7:0] w_848,w_849,w_850,w_851,w_852,w_853,w_854,w_855,
    input  wire signed [7:0] w_856,w_857,w_858,w_859,w_860,w_861,w_862,w_863,
    input  wire signed [7:0] w_864,w_865,w_866,w_867,w_868,w_869,w_870,w_871,
    input  wire signed [7:0] w_872,w_873,w_874,w_875,w_876,w_877,w_878,w_879,
    input  wire signed [7:0] w_880,w_881,w_882,w_883,w_884,w_885,w_886,w_887,
    input  wire signed [7:0] w_888,w_889,w_890,w_891,w_892,w_893,w_894,w_895,
    input  wire signed [7:0] w_896,w_897,w_898,w_899,w_900,w_901,w_902,w_903,
    input  wire signed [7:0] w_904,w_905,w_906,w_907,w_908,w_909,w_910,w_911,
    input  wire signed [7:0] w_912,w_913,w_914,w_915,w_916,w_917,w_918,w_919,
    input  wire signed [7:0] w_920,w_921,w_922,w_923,w_924,w_925,w_926,w_927,
    input  wire signed [7:0] w_928,w_929,w_930,w_931,w_932,w_933,w_934,w_935,
    input  wire signed [7:0] w_936,w_937,w_938,w_939,w_940,w_941,w_942,w_943,
    input  wire signed [7:0] w_944,w_945,w_946,w_947,w_948,w_949,w_950,w_951,
    input  wire signed [7:0] w_952,w_953,w_954,w_955,w_956,w_957,w_958,w_959,
    input  wire signed [7:0] w_960,w_961,w_962,w_963,w_964,w_965,w_966,w_967,
    input  wire signed [7:0] w_968,w_969,w_970,w_971,w_972,w_973,w_974,w_975,
    input  wire signed [7:0] w_976,w_977,w_978,w_979,w_980,w_981,w_982,w_983,
    input  wire signed [7:0] w_984,w_985,w_986,w_987,w_988,w_989,w_990,w_991,
    input  wire signed [7:0] w_992,w_993,w_994,w_995,w_996,w_997,w_998,w_999,
    input  wire signed [7:0] w_1000,w_1001,w_1002,w_1003,w_1004,w_1005,w_1006,w_1007,
    input  wire signed [7:0] w_1008,w_1009,w_1010,w_1011,w_1012,w_1013,w_1014,w_1015,
    input  wire signed [7:0] w_1016,w_1017,w_1018,w_1019,w_1020,w_1021,w_1022,w_1023,
    output wire signed [19:0] psum_out_0,  psum_out_1,  psum_out_2,  psum_out_3,
    output wire signed [19:0] psum_out_4,  psum_out_5,  psum_out_6,  psum_out_7,
    output wire signed [19:0] psum_out_8,  psum_out_9,  psum_out_10, psum_out_11,
    output wire signed [19:0] psum_out_12, psum_out_13, psum_out_14, psum_out_15,
    output wire signed [19:0] psum_out_16, psum_out_17, psum_out_18, psum_out_19,
    output wire signed [19:0] psum_out_20, psum_out_21, psum_out_22, psum_out_23,
    output wire signed [19:0] psum_out_24, psum_out_25, psum_out_26, psum_out_27,
    output wire signed [19:0] psum_out_28, psum_out_29, psum_out_30, psum_out_31,
    output reg  [15:0] skip_count
);
    // internal wires for row accumulation
    wire signed [19:0] r0,r1,r2,r3,r4,r5,r6,r7;
    wire signed [19:0] r8,r9,r10,r11,r12,r13,r14,r15;
    wire signed [19:0] r16,r17,r18,r19,r20,r21,r22,r23;
    wire signed [19:0] r24,r25,r26,r27,r28,r29,r30,r31;
    wire sp0,sp1,sp2,sp3,sp4,sp5,sp6,sp7;
    wire sp8,sp9,sp10,sp11,sp12,sp13,sp14,sp15;
    wire sp16,sp17,sp18,sp19,sp20,sp21,sp22,sp23;
    wire sp24,sp25,sp26,sp27,sp28,sp29,sp30,sp31;

    // Row 0 — one MAC per row for simplicity
    // Each MAC accumulates all 32 column products
    mac_unit_v6 m0(.clk(clk),.rst_n(rst_n),.mac_en(row_en[0]),
        .weight(w_0),.activation(act_in_0),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r0),.skip_pulse(sp0));
    mac_unit_v6 m1(.clk(clk),.rst_n(rst_n),.mac_en(row_en[1]),
        .weight(w_32),.activation(act_in_1),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r1),.skip_pulse(sp1));
    mac_unit_v6 m2(.clk(clk),.rst_n(rst_n),.mac_en(row_en[2]),
        .weight(w_64),.activation(act_in_2),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r2),.skip_pulse(sp2));
    mac_unit_v6 m3(.clk(clk),.rst_n(rst_n),.mac_en(row_en[3]),
        .weight(w_96),.activation(act_in_3),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r3),.skip_pulse(sp3));
    mac_unit_v6 m4(.clk(clk),.rst_n(rst_n),.mac_en(row_en[4]),
        .weight(w_128),.activation(act_in_4),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r4),.skip_pulse(sp4));
    mac_unit_v6 m5(.clk(clk),.rst_n(rst_n),.mac_en(row_en[5]),
        .weight(w_160),.activation(act_in_5),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r5),.skip_pulse(sp5));
    mac_unit_v6 m6(.clk(clk),.rst_n(rst_n),.mac_en(row_en[6]),
        .weight(w_192),.activation(act_in_6),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r6),.skip_pulse(sp6));
    mac_unit_v6 m7(.clk(clk),.rst_n(rst_n),.mac_en(row_en[7]),
        .weight(w_224),.activation(act_in_7),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r7),.skip_pulse(sp7));
    mac_unit_v6 m8(.clk(clk),.rst_n(rst_n),.mac_en(row_en[8]),
        .weight(w_256),.activation(act_in_8),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r8),.skip_pulse(sp8));
    mac_unit_v6 m9(.clk(clk),.rst_n(rst_n),.mac_en(row_en[9]),
        .weight(w_288),.activation(act_in_9),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r9),.skip_pulse(sp9));
    mac_unit_v6 m10(.clk(clk),.rst_n(rst_n),.mac_en(row_en[10]),
        .weight(w_320),.activation(act_in_10),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r10),.skip_pulse(sp10));
    mac_unit_v6 m11(.clk(clk),.rst_n(rst_n),.mac_en(row_en[11]),
        .weight(w_352),.activation(act_in_11),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r11),.skip_pulse(sp11));
    mac_unit_v6 m12(.clk(clk),.rst_n(rst_n),.mac_en(row_en[12]),
        .weight(w_384),.activation(act_in_12),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r12),.skip_pulse(sp12));
    mac_unit_v6 m13(.clk(clk),.rst_n(rst_n),.mac_en(row_en[13]),
        .weight(w_416),.activation(act_in_13),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r13),.skip_pulse(sp13));
    mac_unit_v6 m14(.clk(clk),.rst_n(rst_n),.mac_en(row_en[14]),
        .weight(w_448),.activation(act_in_14),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r14),.skip_pulse(sp14));
    mac_unit_v6 m15(.clk(clk),.rst_n(rst_n),.mac_en(row_en[15]),
        .weight(w_480),.activation(act_in_15),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r15),.skip_pulse(sp15));
    mac_unit_v6 m16(.clk(clk),.rst_n(rst_n),.mac_en(row_en[16]),
        .weight(w_512),.activation(act_in_16),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r16),.skip_pulse(sp16));
    mac_unit_v6 m17(.clk(clk),.rst_n(rst_n),.mac_en(row_en[17]),
        .weight(w_544),.activation(act_in_17),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r17),.skip_pulse(sp17));
    mac_unit_v6 m18(.clk(clk),.rst_n(rst_n),.mac_en(row_en[18]),
        .weight(w_576),.activation(act_in_18),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r18),.skip_pulse(sp18));
    mac_unit_v6 m19(.clk(clk),.rst_n(rst_n),.mac_en(row_en[19]),
        .weight(w_608),.activation(act_in_19),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r19),.skip_pulse(sp19));
    mac_unit_v6 m20(.clk(clk),.rst_n(rst_n),.mac_en(row_en[20]),
        .weight(w_640),.activation(act_in_20),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r20),.skip_pulse(sp20));
    mac_unit_v6 m21(.clk(clk),.rst_n(rst_n),.mac_en(row_en[21]),
        .weight(w_672),.activation(act_in_21),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r21),.skip_pulse(sp21));
    mac_unit_v6 m22(.clk(clk),.rst_n(rst_n),.mac_en(row_en[22]),
        .weight(w_704),.activation(act_in_22),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r22),.skip_pulse(sp22));
    mac_unit_v6 m23(.clk(clk),.rst_n(rst_n),.mac_en(row_en[23]),
        .weight(w_736),.activation(act_in_23),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r23),.skip_pulse(sp23));
    mac_unit_v6 m24(.clk(clk),.rst_n(rst_n),.mac_en(row_en[24]),
        .weight(w_768),.activation(act_in_24),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r24),.skip_pulse(sp24));
    mac_unit_v6 m25(.clk(clk),.rst_n(rst_n),.mac_en(row_en[25]),
        .weight(w_800),.activation(act_in_25),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r25),.skip_pulse(sp25));
    mac_unit_v6 m26(.clk(clk),.rst_n(rst_n),.mac_en(row_en[26]),
        .weight(w_832),.activation(act_in_26),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r26),.skip_pulse(sp26));
    mac_unit_v6 m27(.clk(clk),.rst_n(rst_n),.mac_en(row_en[27]),
        .weight(w_864),.activation(act_in_27),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r27),.skip_pulse(sp27));
    mac_unit_v6 m28(.clk(clk),.rst_n(rst_n),.mac_en(row_en[28]),
        .weight(w_896),.activation(act_in_28),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r28),.skip_pulse(sp28));
    mac_unit_v6 m29(.clk(clk),.rst_n(rst_n),.mac_en(row_en[29]),
        .weight(w_928),.activation(act_in_29),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r29),.skip_pulse(sp29));
    mac_unit_v6 m30(.clk(clk),.rst_n(rst_n),.mac_en(row_en[30]),
        .weight(w_960),.activation(act_in_30),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r30),.skip_pulse(sp30));
    mac_unit_v6 m31(.clk(clk),.rst_n(rst_n),.mac_en(row_en[31]),
        .weight(w_992),.activation(act_in_31),
        .acc_clear(acc_clear),.acc_en(acc_en),.psum(r31),.skip_pulse(sp31));

    assign psum_out_0=r0;   assign psum_out_1=r1;
    assign psum_out_2=r2;   assign psum_out_3=r3;
    assign psum_out_4=r4;   assign psum_out_5=r5;
    assign psum_out_6=r6;   assign psum_out_7=r7;
    assign psum_out_8=r8;   assign psum_out_9=r9;
    assign psum_out_10=r10; assign psum_out_11=r11;
    assign psum_out_12=r12; assign psum_out_13=r13;
    assign psum_out_14=r14; assign psum_out_15=r15;
    assign psum_out_16=r16; assign psum_out_17=r17;
    assign psum_out_18=r18; assign psum_out_19=r19;
    assign psum_out_20=r20; assign psum_out_21=r21;
    assign psum_out_22=r22; assign psum_out_23=r23;
    assign psum_out_24=r24; assign psum_out_25=r25;
    assign psum_out_26=r26; assign psum_out_27=r27;
    assign psum_out_28=r28; assign psum_out_29=r29;
    assign psum_out_30=r30; assign psum_out_31=r31;

    always @(posedge clk) begin
        if (!rst_n || acc_clear) skip_count <= 16'd0;
        else skip_count <= skip_count +
            sp0+sp1+sp2+sp3+sp4+sp5+sp6+sp7+
            sp8+sp9+sp10+sp11+sp12+sp13+sp14+sp15+
            sp16+sp17+sp18+sp19+sp20+sp21+sp22+sp23+
            sp24+sp25+sp26+sp27+sp28+sp29+sp30+sp31;
    end
endmodule
