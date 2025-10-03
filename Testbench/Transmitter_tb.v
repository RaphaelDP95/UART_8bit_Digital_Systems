`timescale 1ns / 1ps
module Transmitter_tb;

    reg sys_clk = 0;
    parameter SYS_CLK_PERIOD = 20; // 50 MHz
    reg reset;

    // UART signals
    reg [7:0] data_in;
    reg send_data;
    reg parity_in;
    wire tx_out;
    wire tx_busy;
    reg [1:0] baud_select;

    wire clk_en;

    // Instantiate Baud Rate Generator
    Baud_Rate_Module baud_gen (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select),
        .baud_clk(clk_en)
    );

    // Instantiate Transmitter
    Transmitter uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .clk_en(clk_en),
        .data_in(data_in),
        .send_data(send_data),
        .parity_in(parity_in),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // System clock
    always #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;

    initial begin
        // Initialize signals
        reset = 0;
        send_data = 0;
        data_in = 0;
        parity_in = 0;
        baud_select = 2'b10; // 9600 baud
        #(SYS_CLK_PERIOD*10);
        reset = 1;
        #(SYS_CLK_PERIOD*10);

        // Send fixed byte 10101010
        data_in = 8'b10101010;
        parity_in = ^8'b10101010; // even parity

        // Pulse send_data aligned with baud tick
        send_data = 1;
        @(posedge clk_en);
        send_data = 0;

        // wait for transmission to finish 
        wait(!tx_busy);  // then wait until tx_busy goes low
        #100000 // wait a bit more to see the line go up to high after transmission
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | tx_out=%b | tx_busy=%b | data_in=%b | parity_in=%b",
                 $time, tx_out, tx_busy, data_in, parity_in);
    end

endmodule
