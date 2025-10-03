`timescale 1ns / 1ps

module Baud_Rate_Module (
    input wire sys_clk,
    input wire reset, // active-low reset
    input wire [1:0] baud_select, // 2-bit input to select baud rate
    output wire baud_clk
);


reg [11:0] counter = 0;
reg clk_en_reg = 0;
reg [11:0] counter_max = 0;

// Input frq = 50 MHz, div = frq/(16*baud rate)
always@(*)
begin
    case(baud_select)
    0: counter_max = 11'd1302; // Baud rate = 2400
    1: counter_max = 11'd651; // Baud rate = 4800
    2: counter_max = 11'd326; // Baud rate = 9600
    3: counter_max = 11'd163; // Baud rate = 19200
    default: counter_max = 11'd0;
    endcase
end

always @(posedge sys_clk or negedge reset) 
begin
    if (!reset) 
        begin
            counter <= 0;
            clk_en_reg <= 0;
        end
    else
        begin
            if (counter == counter_max) 
                begin
                counter <= 0;
                clk_en_reg <= 1;
            end 
            else 
                begin
                counter <= counter + 1;
                clk_en_reg <= 0;
            end
        end
end

assign baud_clk = clk_en_reg;

endmodule