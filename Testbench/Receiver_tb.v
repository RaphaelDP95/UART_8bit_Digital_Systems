`timescale 1ns / 1ps

module Receiver_tb;

    reg sys_clk = 0;
    parameter SYS_CLK_PERIOD = 20; // 50 MHz
    reg reset;

    // UART signals
    reg rx_in;
    wire [7:0] data_out;
    wire parity_bit;
    wire data_ready;
    wire busy;
    reg [1:0] baud_select;

    wire baud_clk;

    // Instantiate Baud Rate Generator
    Baud_Rate_Module baud_gen (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select),
        .baud_clk(baud_clk)
    );

    // Instantiate Receiver
    Receiver uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_clk(baud_clk),
        .rx_in(rx_in),
        .data_out(data_out),
        .parity_bit(parity_bit),
        .data_ready(data_ready),
        .busy(busy)
    );

    // Generate system clock
    always #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;

    // UART transmission task (drives rx_in)
    task send_uart_byte;
        input [7:0] byte;
        input parity;
        integer i, j;
        begin
            // Start bit
            rx_in = 0;
            for (j = 0; j < 16; j = j + 1) @(posedge baud_clk);

            // Data bits LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx_in = byte[i];
                for (j = 0; j < 16; j = j + 1) @(posedge baud_clk);
            end

            // Parity bit
            rx_in = parity;
            for (j = 0; j < 16; j = j + 1) @(posedge baud_clk);

            // Stop bit
            rx_in = 1;
            for (j = 0; j < 16; j = j + 1) @(posedge baud_clk);
        end
    endtask

    initial begin
        // Initialize signals
        reset = 0;
        rx_in = 1; // idle line high
        baud_select = 2'b10; // 9600 baud
        #(SYS_CLK_PERIOD*10);
        reset = 1;
        #(SYS_CLK_PERIOD*10);

        // Send byte 10101011 with even parity
        send_uart_byte(8'b10101011, ^8'b10101011);

        // Wait until data_ready
        wait(data_ready);
        #100000
        $finish;
    end

    // Monitor signals in console
    initial begin
        $monitor("Time=%0t | rx_in=%b | busy=%b | data_out=%b | parity_bit=%b | data_ready=%b",
                 $time, rx_in, busy, data_out, parity_bit, data_ready);
    end

endmodule
