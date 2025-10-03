`timescale 1ns / 1ps

module Parity_tx_tb;

    reg [7:0] data_in;
    reg parity_type;       // 0=even, 1=odd
    wire [7:0] data_out;
    wire parity_out;

    // Instantiate the TX parity module
    Parity_tx uut (
        .data_in(data_in),
        .parity_type(parity_type),
        .data_out(data_out),
        .parity_out(parity_out)
    );

    initial begin
        data_in = 8'b0;
        parity_type = 0;

        // Test 1: Even parity
        #20;
        data_in = 8'b10101010;
        parity_type = 0;
        #40;
        
        // Test 2: even parity
        data_in = 8'b11111111;
        parity_type = 0;
        #40;
        
        // Test 3: even parity
        data_in = 8'b11011111;
        parity_type = 0;
        #40;
        
        // Test 4: Odd parity
        data_in = 8'b11001100;
        parity_type = 1;
        #40;
        
        // Test 5: Odd parity
        data_in = 8'b11001110;
        parity_type = 1;
        #40;
        
        // Test 6: Odd parity
        data_in = 8'b11111111;
        parity_type = 1;
        #40;
        
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | data_in=%b | parity_type=%b | data_out=%b | parity_out=%b",
                 $time, data_in, parity_type, data_out, parity_out);
    end

endmodule

