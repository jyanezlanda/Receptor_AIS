module gmsk_nrzi_decode (
    input  wire clk, aresetn,
    input  wire bit_in, bit_in_valid,
    output reg  bit_out,
    output reg  bit_out_valid
);
    reg bit_prev;

    always @(posedge clk) begin
        if (!aresetn) begin
            bit_prev      <= 1'b1;
            bit_out_valid <= 1'b0;
        end else if (bit_in_valid) begin
            bit_out       <= (bit_in == bit_prev);
            bit_prev      <= bit_in;
            bit_out_valid <= 1'b1;
        end else begin
            bit_out_valid <= 1'b0;
        end
    end
endmodule
