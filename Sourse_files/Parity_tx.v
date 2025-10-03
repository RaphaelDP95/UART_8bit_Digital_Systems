`timescale 1ns / 1ps

module Parity_tx(
    input  wire [7:0] data_in, // 8-bit input data
    input  wire       parity_type, // 0 = even parity, 1 = odd parity
    output wire [7:0] data_out, // 8-bit output (same as input)
    output wire       parity_out // parity bit output
);

assign data_out   = data_in;
assign parity_out = (parity_type == 1'b1) ? ~^data_in : ^data_in; // Odd parity: ~^data_in, Even parity: ^data_in

endmodule
