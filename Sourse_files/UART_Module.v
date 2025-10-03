`timescale 1ns / 1ps

module UART_Module(
    input  wire sys_clk,
    input  wire reset,
    input  wire [1:0] baud_select, // select baud rate
    input  wire [7:0] tx_data_in,  // data to transmit
    input  wire send_data, // pulse to start transmission
    input  wire parity_type, // 0=even, 1=odd
    input  wire rx_in, // received serial line

    output wire tx_out, // transmit serial line
    output wire tx_busy, // transmitter busy
    output wire [7:0] rx_data_out, // received parallel data
    output wire rx_data_ready, // data valid pulse
    output wire rx_busy, // receiver busy
    output reg parity_error // HIGH if parity mismatch
);

    // Internal signals
    wire baud_clk;
    wire [7:0] tx_data_aligned;
    wire tx_parity_bit;
    wire [7:0] rx_data_raw;
    wire rx_parity_bit;
    wire rx_data_ready_int;
    wire parity_error_int;

    // Baud Rate Generator
    Baud_Rate_Module baud_gen_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select),
        .baud_clk(baud_clk)
    );

    // TX Parity generator
    Parity_tx parity_tx_inst (
        .data_in(tx_data_in),
        .parity_type(parity_type),
        .data_out(tx_data_aligned),  // 8-bit clean data
        .parity_out(tx_parity_bit)     // parity bit
    );

    // Transmitter 
    Transmitter tx_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .clk_en(baud_clk),         
        .data_in(tx_data_aligned),
        .send_data(send_data),
        .parity_in(tx_parity_bit),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // Receiver
    Receiver rx_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_clk(baud_clk),
        .rx_in(rx_in),
        .data_out(rx_data_raw),
        .parity_bit(rx_parity_bit),
        .data_ready(rx_data_ready_int),
        .busy(rx_busy)
    );

    // RX Parity checker
    Parity_rx parity_rx_inst (
        .data_in(rx_data_raw),
        .received_parity(rx_parity_bit),
        .parity_type(parity_type),
        .data_out(rx_data_out),
        .parity_error(parity_error_int)
    );

    // Register parity_error only when data is ready to avoid error flag instability (issues in timing simulation
    always @(posedge sys_clk or negedge reset) begin
        if (!reset)
            parity_error <= 1'b0;
        else if (rx_data_ready_int)
            parity_error <= parity_error_int;
    end

    assign rx_data_ready = rx_data_ready_int;

endmodule
