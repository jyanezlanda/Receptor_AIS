// ============================================================
// gmsk_slicer.v
//
// Decision de bit: en cada strobe, compara (soft[n]-dc[n]) contra cero.
// Equivale a bits_crudos = (symbols - dc > 0) del Python, pero evaluado
// muestra a muestra en vez de sobre un array ya armado.
// ============================================================

module gmsk_slicer #(
    parameter DATA_WIDTH = 24
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [DATA_WIDTH-1:0] soft_tdata,
    input  wire signed [DATA_WIDTH-1:0] dc_tdata,
    input  wire        strobe,

    output reg          bit_crudo_tdata,
    output reg          bit_crudo_tvalid
);
    always @(posedge clk) begin
        if (!aresetn) begin
            bit_crudo_tvalid <= 1'b0;
        end else begin
            bit_crudo_tvalid <= strobe;
            if (strobe) begin
                bit_crudo_tdata <= (soft_tdata - dc_tdata) > 0;
            end
        end
    end
endmodule