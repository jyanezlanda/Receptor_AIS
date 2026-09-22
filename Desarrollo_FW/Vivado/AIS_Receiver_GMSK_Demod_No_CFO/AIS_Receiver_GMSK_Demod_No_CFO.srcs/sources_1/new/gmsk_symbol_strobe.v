// ============================================================
// gmsk_symbol_strobe.v
//
// Genera un pulso de un ciclo cada ~sps muestras validas de soft[n],
// con una fase inicial configurable (para las 4 ramas candidatas).
// ============================================================

module gmsk_symbol_strobe #(
    parameter ACC_WIDTH    = 32,
    parameter INC          = 32'd214734621
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire        s_axis_soft_tvalid,

    input  wire [ACC_WIDTH-1:0] s_axis_carga_tdata,
    input  wire        s_axis_carga_tvalid,

    output wire        strobe
);
    reg [ACC_WIDTH-1:0] acc;
    wire [ACC_WIDTH:0] suma = {1'b0, acc} + {1'b0, INC[ACC_WIDTH-1:0]};

    always @(posedge clk) begin
        if (!aresetn) begin
            acc <= {ACC_WIDTH{1'b0}};
        end else if (s_axis_carga_tvalid) begin
            acc <= s_axis_carga_tdata;
        end else if (s_axis_soft_tvalid) begin
            acc <= suma[ACC_WIDTH-1:0];
        end
    end

    assign strobe = s_axis_soft_tvalid && suma[ACC_WIDTH];
endmodule
