// ============================================================
// gmsk_cfo_to_pinc.v
//
// Convierte el error de frecuencia promediado (salida de
// gmsk_dc_tracker reusado como filtro de lazo) al formato de
// incremento de fase (PINC) que espera el puerto de fase en modo
// streaming del dds_compiler del rotador.
// ============================================================

module gmsk_cfo_to_pinc #(
    parameter IN_WIDTH    = 17,
    parameter PINC_WIDTH  = 20,
    parameter TOTAL_WIDTH = 32
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [IN_WIDTH-1:0] s_axis_err_tdata,
    input  wire        s_axis_err_tvalid,

    output reg  [TOTAL_WIDTH-1:0] m_axis_pinc_tdata,
    output reg         m_axis_pinc_tvalid
);
    localparam signed [31:0] MULT_CFO = 32'sd20861;
    localparam SHIFT_CFO = 12;

    wire signed [IN_WIDTH+32-1:0] producto = s_axis_err_tdata * MULT_CFO;
    wire signed [PINC_WIDTH-1:0] pinc = producto >>> SHIFT_CFO;

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_pinc_tdata  <= {TOTAL_WIDTH{1'b0}};
            m_axis_pinc_tvalid <= 1'b1;
        end else begin
            if (s_axis_err_tvalid)
                m_axis_pinc_tdata <= {{(TOTAL_WIDTH-PINC_WIDTH){1'b0}}, pinc};
            m_axis_pinc_tvalid <= 1'b1;
        end
    end
endmodule