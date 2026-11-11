// ============================================================
// gmsk_cfo_shift_fix.v
//
// Restaura el margen (headroom) perdido por la extraccion generica de
// bits del Complex Multiplier -- confirmado con un testbench aislado
// contra las IP reales (cmpy_z2/cmpy_z4): la perdida es un numero FIJO
// de bits (GROW-OUTPUT_WIDTH de cada etapa), independiente de la
// magnitud de la señal, y se compone en cada etapa siguiente.
//
// A diferencia de gmsk_rotador_shift_fix (un factor exacto, sin riesgo
// de desborde), aca el corrimiento usa casi todo el margen disponible
// a proposito -- por eso satura en vez de recortar en silencio, para
// picos de señal por encima de lo calibrado.
// ============================================================

module gmsk_cfo_shift_fix #(
    parameter DATA_WIDTH = 24,
    parameter SHIFT_CORRECCION = 4
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [2*DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output reg  [2*DATA_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    wire signed [DATA_WIDTH-1:0] i_in = s_axis_tdata[DATA_WIDTH-1:0];
    wire signed [DATA_WIDTH-1:0] q_in = s_axis_tdata[2*DATA_WIDTH-1:DATA_WIDTH];

    function signed [DATA_WIDTH-1:0] corrimiento_saturado;
        input signed [DATA_WIDTH-1:0] valor;
        reg signed [DATA_WIDTH+SHIFT_CORRECCION-1:0] ancho;
        begin
            ancho = valor <<< SHIFT_CORRECCION;
            if (ancho > $signed({1'b0, {(DATA_WIDTH-1){1'b1}}}))
                corrimiento_saturado = {1'b0, {(DATA_WIDTH-1){1'b1}}};        // maximo positivo
            else if (ancho < $signed({1'b1, {(DATA_WIDTH-1){1'b0}}}))
                corrimiento_saturado = {1'b1, {(DATA_WIDTH-1){1'b0}}};        // minimo negativo
            else
                corrimiento_saturado = ancho[DATA_WIDTH-1:0];
        end
    endfunction

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tdata  <= {corrimiento_saturado(q_in), corrimiento_saturado(i_in)};
            m_axis_tvalid <= s_axis_tvalid;
        end
    end
endmodule