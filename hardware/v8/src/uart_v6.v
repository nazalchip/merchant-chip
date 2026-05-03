module uart_v6 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] baud_div,
    input  wire [7:0]  tx_data,
    input  wire        tx_start,
    output wire        tx_pin,
    output wire        tx_busy,
    input  wire        rx_pin,
    output wire [7:0]  rx_data,
    output wire        rx_ready
);
    uart_tx u_tx (
        .clk(clk), .rst_n(rst_n),
        .baud_div(baud_div),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_pin(tx_pin),
        .tx_busy(tx_busy)
    );
    uart_rx u_rx (
        .clk(clk), .rst_n(rst_n),
        .baud_div(baud_div),
        .rx_pin(rx_pin),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
endmodule

module uart_tx (
    input  wire        clk, rst_n,
    input  wire [15:0] baud_div,
    input  wire [7:0]  tx_data,
    input  wire        tx_start,
    output reg         tx_pin,
    output reg         tx_busy
);
    reg [3:0]  bit_cnt;
    reg [7:0]  shift;
    reg [15:0] cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            tx_pin<=1; tx_busy<=0; bit_cnt<=0; cnt<=0; shift<=0;
        end else if (tx_start && !tx_busy) begin
            shift<=tx_data; tx_busy<=1; bit_cnt<=0; cnt<=0; tx_pin<=0;
        end else if (tx_busy) begin
            if (cnt >= baud_div) begin
                cnt<=0;
                if (bit_cnt < 8) begin
                    tx_pin<=shift[0]; shift<={1'b0,shift[7:1]};
                    bit_cnt<=bit_cnt+1;
                end else begin tx_pin<=1; tx_busy<=0; end
            end else cnt<=cnt+1;
        end
    end
endmodule

module uart_rx (
    input  wire        clk, rst_n,
    input  wire [15:0] baud_div,
    input  wire        rx_pin,
    output reg  [7:0]  rx_data,
    output reg         rx_ready
);
    reg [3:0]  bit_cnt;
    reg [7:0]  shift;
    reg [15:0] cnt;
    reg        active;
    reg        prev;

    always @(posedge clk) begin
        if (!rst_n) begin
            rx_data<=0; rx_ready<=0; prev<=1;
            active<=0; bit_cnt<=0; cnt<=0; shift<=0;
        end else begin
            rx_ready<=0; prev<=rx_pin;
            if (!active && prev && !rx_pin) begin
                active<=1; bit_cnt<=0; cnt<=baud_div>>1;
            end else if (active) begin
                if (cnt >= baud_div) begin
                    cnt<=0;
                    if (bit_cnt < 8) begin
                        shift<={rx_pin,shift[7:1]};
                        bit_cnt<=bit_cnt+1;
                    end else begin
                        active<=0; rx_data<=shift; rx_ready<=1;
                    end
                end else cnt<=cnt+1;
            end
        end
    end
endmodule
