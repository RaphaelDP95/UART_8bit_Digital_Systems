`timescale 1ns / 1ps

module Baude_Rate_Generator_tb();

    reg sys_clk;
    reg reset;
    reg [1:0] baud_select;
    wire baud_clk;

    // Instantiate the DUT
    Baud_Rate_Module dut (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select),
        .baud_clk(baud_clk)
    );

    // Generate system clock (20ns period = 50MHz)
    initial 
    begin 
        sys_clk = 0;
        forever #10 sys_clk = ~sys_clk;
    end

    initial 
    begin
        // Initialize signals
        reset = 1;
        baud_select = 2'b01;

        // Apply reset
        #50;
        reset = 0;
        #50;
        reset=1;

        // Test all baud rates
        baud_select = 2'b00; // 2400
        #400000;
        
        #50;
        reset = 0;
        #50;
        reset=1;
        
        baud_select = 2'b01; // 4800
        #300000;
        
        #50;
        reset = 0;
        #50;
        reset=1;
        
        baud_select = 2'b10; // 9600
        #200000;
        
        #50;
        reset = 0;
        #50;
        
        reset=1;
        baud_select = 2'b11; // 19200
        #100000;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | reset=%b | baud_select=%b | baud_clk=%b", $time, reset, baud_select, baud_clk);
    end

endmodule
