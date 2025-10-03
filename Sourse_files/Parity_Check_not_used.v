`timescale 1ns / 1ps

module parity_checker (
    input wire [7:0] data_in,
    input wire parity_type, // 0 for even parity, 1 for odd parity
    output wire calculated_parity,
    output wire parity_ok
);

reg calculated_parity_reg;
reg parity_ok_reg;

// Calculate the parity of the input data
always @(*) begin
    // XOR all bits in the data to get the parity
    calculated_parity_reg = ^data_in;
    // Check if the calculated parity matches the desired parity type
    if (parity_type == 0) // Even parity
        begin 
            parity_ok_reg = (calculated_parity_reg == 0);
        end 
    else // Odd parity
        begin 
            parity_ok_reg = (calculated_parity_reg == 1);
        end
end

assign calculated_parity = calculated_parity_reg;
assign parity_ok = parity_ok_reg;

endmodule
