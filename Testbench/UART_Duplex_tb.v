`timescale 1ns / 1ps

module UART_Duplex_tb();

    // System clock
    reg sys_clk;
    reg reset;

    // UART A signals
    reg [1:0] baud_select_A;
    reg [7:0] tx_data_in_A;
    reg send_data_A;
    reg parity_type_A;
    wire tx_out_A;
    wire tx_busy_A;
    wire [7:0] rx_data_out_A;
    wire rx_data_ready_A;
    wire rx_busy_A;
    wire parity_error_A;
    wire rx_in_A;

    // UART B signals
    reg [1:0] baud_select_B;
    reg [7:0] tx_data_in_B;
    reg send_data_B;
    reg parity_type_B;
    wire tx_out_B;
    wire tx_busy_B;
    wire [7:0] rx_data_out_B;
    wire rx_data_ready_B;
    wire rx_busy_B;
    wire parity_error_B;
    wire rx_in_B;

    // Connect TX of each UART to RX of the other
    assign rx_in_A = tx_out_B;
    assign rx_in_B = tx_out_A;

    // Instantiate UART A
    UART_Module uart_A (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select_A),
        .tx_data_in(tx_data_in_A),
        .send_data(send_data_A),
        .parity_type(parity_type_A),
        .rx_in(rx_in_A),
        .tx_out(tx_out_A),
        .tx_busy(tx_busy_A),
        .rx_data_out(rx_data_out_A),
        .rx_data_ready(rx_data_ready_A),
        .rx_busy(rx_busy_A),
        .parity_error(parity_error_A)
    );

    // Instantiate UART B
    UART_Module uart_B (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select_B),
        .tx_data_in(tx_data_in_B),
        .send_data(send_data_B),
        .parity_type(parity_type_B),
        .rx_in(rx_in_B),
        .tx_out(tx_out_B),
        .tx_busy(tx_busy_B),
        .rx_data_out(rx_data_out_B),
        .rx_data_ready(rx_data_ready_B),
        .rx_busy(rx_busy_B),
        .parity_error(parity_error_B)
    );

    // Clock generation: 50 MHz
    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 0;
        reset = 0;

        baud_select_A = 2'b10; // 9600
        tx_data_in_A = 8'b10101010;
        send_data_A = 0;
        parity_type_A = 0;

        baud_select_B = 2'b10; // 9600
        tx_data_in_B = 8'b01010101;
        send_data_B = 0;
        parity_type_B = 0;

        // Reset pulse
        #5000;
        reset = 1;

        // 1st transmission: simultaneous
        #1000000;
        send_data_A = 1;
        send_data_B = 1;
        @(posedge sys_clk);
        @(posedge sys_clk);
        //@(posedge tx_busy_A && tx_busy_B); // this also works but it glitches the wave form and doesn't show the send data for the next transmission
        // when using the above the send_data_A and send_data_b remain active for 1 sys_clk.
        send_data_A = 0;
        send_data_B = 0;

        // 2nd transmission: TX A only
        #2000000;
        tx_data_in_A = 8'b11110000;
        send_data_A = 1;
                @(posedge sys_clk);
        @(posedge sys_clk);
        //@(posedge tx_busy_A); // this also works but it glitches the wave form and doesn't show the send data for the next transmission
        send_data_A = 0;

        // 3rd transmission: TX B only
        #2000000;
        tx_data_in_B = 8'b00001111;
        send_data_B = 1;
        @(posedge sys_clk);
        @(posedge sys_clk);
        //@(posedge tx_busy_B); // this also works but it glitches the wave form and doesn't show the send data for the next transmission
        send_data_B = 0;

        // Let simulation run
        #50000000;
        $finish;
    end

    // Monitor key signals
    initial begin
        $monitor("Time=%0t | A: tx=%b rx=%b rx_data=%h ready=%b busy=%b err=%b | B: tx=%b rx=%b rx_data=%h ready=%b busy=%b err=%b | send_data A=%b, send_data_B=%b",
                 $time,
                 tx_out_A, rx_in_A, rx_data_out_A, rx_data_ready_A, rx_busy_A, parity_error_A,
                 tx_out_B, rx_in_B, rx_data_out_B, rx_data_ready_B, rx_busy_B, parity_error_B,
                 send_data_A, send_data_B);
    end

endmodule
