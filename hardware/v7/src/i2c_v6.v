module i2c_v6 (
    input  wire       clk, rst_n,
    input  wire [6:0] dev_addr,
    input  wire [7:0] tx_data,
    input  wire       rw, start,
    inout  wire       sda,
    output reg        scl,
    output reg  [7:0] rx_data,
    output reg        busy, done, ack
);
    localparam IDLE=3'd0, START=3'd1, ADDR=3'd2,
               DATA=3'd3, STOP=3'd4;
    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift, clk_div;
    reg       sda_out, sda_oe;

    assign sda = sda_oe ? sda_out : 1'bz;

    always @(posedge clk) begin
        if (!rst_n) begin
            state<=IDLE; scl<=1'b1;
            sda_out<=1'b1; sda_oe<=1'b1;
            busy<=1'b0; done<=1'b0;
            clk_div<=8'd0; bit_cnt<=4'd0;
            shift<=8'd0; rx_data<=8'd0; ack<=1'b0;
        end else begin
            done <= 1'b0;
            clk_div <= clk_div + 8'd1;
            if (clk_div == 8'd63) begin
                clk_div <= 8'd0;
                case (state)
                    IDLE: if (start) begin
                        state   <= START;
                        busy    <= 1'b1;
                        sda_out <= 1'b0;
                    end
                    START: begin
                        scl     <= 1'b0;
                        shift   <= {dev_addr, rw};
                        bit_cnt <= 4'd7;
                        state   <= ADDR;
                    end
                    ADDR: begin
                        scl <= ~scl;
                        if (scl) begin
                            sda_out <= shift[7];
                            shift   <= {shift[6:0], 1'b0};
                            if (bit_cnt == 4'd0)
                                state <= DATA;
                            else
                                bit_cnt <= bit_cnt - 4'd1;
                        end
                    end
                    DATA: begin
                        scl <= ~scl;
                        if (scl) begin
                            done  <= 1'b1;
                            busy  <= 1'b0;
                            state <= STOP;
                        end
                    end
                    STOP: begin
                        sda_out <= 1'b1;
                        scl     <= 1'b1;
                        state   <= IDLE;
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
