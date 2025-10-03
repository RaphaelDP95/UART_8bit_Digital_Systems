`timescale 1ns / 1ps

module Transmitter(
    input wire sys_clk,
    input wire reset,
    input wire clk_en, // Tick from Baud generator
    input wire [7:0] data_in,
    input wire send_data, // Pulse high for one clock cycle to start transmission
    input wire parity_in, // Parity bit input (calculated externally)
    output wire tx_out,
    output wire tx_busy // High when transmission is in progress
);

parameter IDLE = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BITS = 3'b010;
parameter PARITY_BIT = 3'b011;
parameter STOP_BIT = 3'b100;

reg [2:0] state = IDLE;
reg [7:0] data_buffer;
reg [3:0] bit_count = 0;
reg tx_out_reg = 1; // The line is kept high when there is no transmission
reg tx_busy_reg = 0;
reg [3:0] baud_count = 0; // Counts 0 to 15 for 16 ticks per bit

always @(posedge sys_clk or negedge reset) begin
    if (!reset) begin
        state <= IDLE;
        data_buffer <= 0;
        bit_count <= 0;
        tx_out_reg <= 1;
        tx_busy_reg <= 0;
        baud_count <= 0;
    end else begin
        case (state)
            IDLE: begin
                tx_out_reg <= 1; // Keep line high in idle
                tx_busy_reg <= 0;
                baud_count <= 0;
                if (send_data) begin
                    data_buffer <= data_in;
                    tx_busy_reg <= 1;
                    state <= START_BIT;

                end
            end

            START_BIT: begin
                if (clk_en) begin
                    tx_out_reg <= 0; // send start bit 
                    if (baud_count == 15) begin
                        state <= DATA_BITS;
                        baud_count <= 0;
                        bit_count <= 0;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            end

            DATA_BITS: begin
                if (clk_en) begin
                    tx_out_reg <= data_buffer[bit_count]; // send data bits LSB first
                    if (baud_count == 15) begin
                        baud_count <= 0;
                        if (bit_count == 7) begin
                            state <= PARITY_BIT;
                        end
                        bit_count <= bit_count + 1;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            end

            PARITY_BIT: begin
                if (clk_en) begin
                    tx_out_reg <= parity_in; // send the provided parity bit
                    if (baud_count == 15) begin
                        state <= STOP_BIT;
                        baud_count <= 0;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            end

            STOP_BIT: begin
                if (clk_en) begin
                    tx_out_reg <= 1; // send stop bit (high)
                    if (baud_count == 15) begin
                        state <= IDLE;
                        //tx_busy_reg <= 0;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            end
        endcase
    end
end

assign tx_out = tx_out_reg;
assign tx_busy = tx_busy_reg;

endmodule