module weight_compressor_v6 (
    input  wire        clk, rst_n, bypass,
    input  wire signed [7:0] w_in,
    output wire signed [7:0] w_out,
    output wire        w_valid
);
    assign w_out   = w_in;
    assign w_valid = 1'b1;
endmodule
