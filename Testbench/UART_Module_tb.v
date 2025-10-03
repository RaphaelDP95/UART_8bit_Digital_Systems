`timescale 1ns / 1ps

module UART_Module_tb;

    reg sys_clk;
    reg reset;
    reg [1:0] baud_select;
    reg [7:0] tx_data_in;
    reg send_data;
    reg parity_type;

    wire tx_out;
    wire tx_busy;
    wire [7:0] rx_data_out;
    wire rx_data_ready;
    wire rx_busy;
    wire parity_error;
    wire rx_in;

    // Loopback: connect TX line directly to RX input
    assign rx_in = tx_out;

    // Instantiate the UART module (new version)
    UART_Module uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_select(baud_select),
        .tx_data_in(tx_data_in),
        .send_data(send_data),
        .parity_type(parity_type),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .tx_busy(tx_busy),
        .rx_data_out(rx_data_out),
        .rx_data_ready(rx_data_ready),
        .rx_busy(rx_busy),
        .parity_error(parity_error)
    );

    // Clock generation: 50 MHz -> 20 ns period
    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 0;
        reset = 0;
        baud_select = 2'b10; // 9600 baud
        send_data = 0;

        // Hold reset low
        #500000;
        reset = 1;

        // Wait a bit before first transmission
        #500000;

        // First transmission with even parity 
        tx_data_in = 8'b10101010; // first word
        parity_type = 0; // even parity
        send_data = 1;
        @(posedge tx_busy); // wait until transmitter starts
        send_data = 0;

        // Wait until RX is done
        @(posedge rx_data_ready);
        #1000; // small delay

        //Second transmission with odd parity
        tx_data_in = 8'b11001100;
        parity_type = 1; // odd parity
        #100000; // delay before next word
        send_data = 1;
        @(posedge tx_busy);
        send_data = 0;

        // Wait for RX to complete
        @(posedge rx_data_ready);
        
        #5000000;
        $finish;
    end

    // Monitor activity
    initial begin
        $monitor("T=%0t | tx_busy=%b | rx_busy=%b | tx_out=%b | rx_in=%b | rx_data_out=%b | rx_data_ready=%b | parity_error=%b",
                 $time, tx_busy, rx_busy, tx_out, rx_in, rx_data_out, rx_data_ready, parity_error);
    end

endmodule
