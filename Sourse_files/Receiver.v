`timescale 1ns / 1ps

module Receiver(
    input  wire sys_clk,
    input  wire reset,
    input  wire baud_clk, // tick from baud generator
    input  wire rx_in, // Serial data input
    output wire [7:0] data_out, // Received data
    output wire parity_bit, // Received parity bit
    output wire data_ready, // High for one baud tick when data is valid
    output wire busy // High while receiving a frame
);

parameter IDLE = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BITS = 3'b010;
parameter PARITY_BIT = 3'b011;
parameter STOP_BIT = 3'b100;

reg [2:0] state = IDLE;
reg [7:0] data_buffer = 0;
reg [3:0] baud_count = 0; // counts oversample ticks (0-15)
reg [3:0] bit_count = 0; // counts data bits (0-7)
reg [7:0] data_out_reg = 0;
reg parity_bit_reg = 0;
reg data_ready_reg = 0;
reg busy_reg = 0;

always @(posedge sys_clk or negedge reset) begin
    if (!reset) begin
        state <= IDLE;
        data_buffer <= 0;
        bit_count <= 0;
        baud_count <= 0;
        data_out_reg <= 0;
        parity_bit_reg <= 0;
        data_ready_reg <= 0;
        busy_reg <= 0;
    end else begin
        data_ready_reg <= 0;
        if (baud_clk) begin
            case (state)
                IDLE: begin
                    busy_reg <= 0;
                    baud_count <= 0;
                    bit_count <= 0;
                    if (!rx_in) begin
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (baud_count == 7) begin
                        if (rx_in == 0) begin
                            state <= DATA_BITS;
                            baud_count <= 0;
                            busy_reg <=1;
                        end else begin
                            state <= IDLE;  // false start
                        end
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end

                DATA_BITS: begin
                    if (baud_count == 15) begin
                        data_buffer[bit_count] <= rx_in;
                        baud_count <= 0;
                        if (bit_count == 7) state <= PARITY_BIT;
                        bit_count <= bit_count + 1;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end

                PARITY_BIT: begin
                    if (baud_count == 15) begin
                        parity_bit_reg <= rx_in;
                        baud_count <= 0;
                        state <= STOP_BIT;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end

                STOP_BIT: begin
                    if (baud_count == 15) begin
                        if (rx_in) begin
                            data_out_reg <= data_buffer;
                            data_ready_reg <= 1; // pulse ready
                            busy_reg <= 0; 
                        end
                        state <= IDLE;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            endcase
        end
    end
end

assign data_out = data_out_reg;
assign parity_bit = parity_bit_reg;
assign data_ready = data_ready_reg;
assign busy = busy_reg;

endmodule
