module mac_unit_v6 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mac_en,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        acc_clear,
    input  wire        acc_en,
    output reg  signed [19:0] psum,
    output wire        skip_pulse
);
    wire zero_weight     = (weight     == 8'sd0);
    wire zero_activation = (activation == 8'sd0);
    wire do_skip         = zero_weight | zero_activation;
    assign skip_pulse = do_skip & acc_en & mac_en;
    wire signed [7:0] w_iso = do_skip ? 8'sd0 : weight;
    wire signed [7:0] a_iso = do_skip ? 8'sd0 : activation;
    wire signed [15:0] product = w_iso * a_iso;
    always @(posedge clk) begin
        if (!rst_n) psum <= 20'sd0;
        else if (mac_en) begin
            if (acc_clear) psum <= 20'sd0;
            else if (acc_en && !do_skip)
                psum <= psum + {{4{product[15]}}, product};
        end
    end
endmodule
