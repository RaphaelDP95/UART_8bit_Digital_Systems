`timescale 1ns / 1ps

module Parity_rx(
    input  wire [7:0] data_in, // 8-bit received data
    input  wire parity_type, // 0 = even parity, 1 = odd parity
    input  wire received_parity, // received parity bit
    output wire [7:0] data_out, // output data (same as input)
    output wire parity_error // HIGH if parity mismatch
);

assign data_out     = data_in;
assign parity_error = (parity_type == 1'b1) ? (received_parity != (~^data_in)) // odd parity check
                                             : (received_parity != (^data_in)); // even parity check

endmodule
