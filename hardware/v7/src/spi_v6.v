module spi_v6 (
    input  wire       clk, rst_n,
    input  wire [7:0] tx_data,
    input  wire       start, cs_sel,
    output reg        spi_clk, spi_mosi,
    input  wire       spi_miso,
    output reg  [1:0] spi_cs_n,
    output reg  [7:0] rx_data,
    output reg        busy, done
);
    reg [7:0] shift_out, shift_in;
    reg [3:0] bit_cnt;
    reg [7:0] clk_div;

    always @(posedge clk) begin
        if (!rst_n) begin
            spi_clk<=1'b0; spi_mosi<=1'b0;
            spi_cs_n<=2'b11; busy<=1'b0; done<=1'b0;
            bit_cnt<=4'd0; clk_div<=8'd0;
            shift_out<=8'd0; shift_in<=8'd0; rx_data<=8'd0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                busy<=1'b1; shift_out<=tx_data;
                bit_cnt<=4'd0; clk_div<=8'd0;
                spi_cs_n<=cs_sel?2'b01:2'b10;
            end else if (busy) begin
                clk_div <= clk_div + 8'd1;
                if (clk_div == 8'd3) begin
                    clk_div  <= 8'd0;
                    spi_clk  <= ~spi_clk;
                    if (!spi_clk) begin
                        shift_in <= {shift_in[6:0],spi_miso};
                    end else begin
                        spi_mosi  <= shift_out[7];
                        shift_out <= {shift_out[6:0],1'b0};
                        bit_cnt   <= bit_cnt + 4'd1;
                        if (bit_cnt == 4'd7) begin
                            busy     <= 1'b0;
                            done     <= 1'b1;
                            rx_data  <= shift_in;
                            spi_cs_n <= 2'b11;
                        end
                    end
                end
            end
        end
    end
endmodule
