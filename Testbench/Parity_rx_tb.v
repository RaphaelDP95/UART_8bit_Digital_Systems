`timescale 1ns / 1ps

module Parity_rx_tb;

    reg [7:0] data_in;
    reg received_parity;
    reg parity_type;       // 0=even, 1=odd
    wire [7:0] data_out;
    wire parity_error;

    // Instantiate the RX parity module
    Parity_rx uut (
        .data_in(data_in),
        .received_parity(received_parity),
        .parity_type(parity_type),
        .data_out(data_out),
        .parity_error(parity_error)
    );

    initial begin
        data_in = 8'b0;
        received_parity = 0;
        parity_type = 0;

        // Test 1: Even parity, correct
        data_in = 8'b10101010;
        parity_type = 0;
        received_parity = ^data_in;
        #40;
        
        // Test 2: Even parity, incorrect
        data_in = 8'b11111000;
        parity_type = 0;
        received_parity = 0;
        #40;
        
        // Test 3: Odd parity, correct
        data_in = 8'b11001100;
        parity_type = 1;
        received_parity = ~^data_in;
        #40;

        // Test 4: Odd parity, incorrect
        data_in = 8'b11110000;
        parity_type = 1;
        received_parity = 0;
        #40;

        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | data_in=%b | received_parity=%b | parity_type=%b | data_out=%b | parity_error=%b",
                 $time, data_in, received_parity, parity_type, data_out, parity_error);
    end

endmodule

