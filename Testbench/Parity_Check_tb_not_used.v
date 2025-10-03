`timescale 1ns / 1ps

module Parity_Check_tb();

reg [7:0] data_in;
reg parity_type;
wire calculated_parity;
wire parity_ok;

// Instantiate the parity_checker module
parity_checker uut (
    .data_in(data_in),
    .parity_type(parity_type), // 0 for even parity, 1 for odd parity
    .calculated_parity(calculated_parity),
    .parity_ok(parity_ok)
);

initial begin
    $display("Data_in\t\tparity_type\tcalculated_parity\tparity_ok");
    $monitor("%b\t\t\t%b\t\t\t%b\t\t\t\t\t%b", data_in, parity_type, calculated_parity, parity_ok);

    // Test 1: Even parity, even number of 1s
    data_in = 8'b00000000; parity_type = 0; 
    #10;
    // Test 2: Even parity, odd number of 1s
    data_in = 8'b00000001; parity_type = 0; 
    #10;
    // Test 3: Even parity, 4 ones
    data_in = 8'b00001111; parity_type = 0; 
    #10;
    // Test 4: Even parity, 5 ones
    data_in = 8'b00011111; parity_type = 0; 
    #10;

    // Test 5: Odd parity, even number of 1s
    data_in = 8'b00000000; parity_type = 1; 
    #10;
    // Test 6: Odd parity, odd number of 1s
    data_in = 8'b00000001; parity_type = 1; 
    #10;
    // Test 7: Odd parity, 4 ones
    data_in = 8'b00001111; parity_type = 1; 
    #10;
    // Test 8: Odd parity, 5 ones
    data_in = 8'b00011111; parity_type = 1; 
    #10;

    // Test 9: All ones, even parity
    data_in = 8'b11111111; parity_type = 0; 
    #10;
    // Test 10: All ones, odd parity
    data_in = 8'b11111111; parity_type = 1; 
    #10;

    // Test 11: Alternating bits, even parity
    data_in = 8'b10101010; parity_type = 0; 
    #10;
    // Test 12: Alternating bits, odd parity
    data_in = 8'b10101010; parity_type = 1; 
    #10;

    $finish;
end

endmodule