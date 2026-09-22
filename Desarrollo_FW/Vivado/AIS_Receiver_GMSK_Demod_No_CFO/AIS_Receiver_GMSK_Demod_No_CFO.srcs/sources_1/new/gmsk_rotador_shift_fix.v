// ============================================================
// gmsk_rotador_shift_fix.v
//
// Compensa el factor de escala 1/4 (2 bits) confirmado en hardware real
// en la salida de cmpy_rotador -- el Complex Multiplier de Xilinx toma
// los bits mas significativos del producto crudo sin distinguir que el
// NCO es un coeficiente de rotacion NORMALIZADO (no una senal de rango
// completo como iq_fir), igual que encontramos en el stub de
// simulacion antes de agregarle SHIFT_SALIDA=B_WIDTH-1.
//
// SHIFT_CORRECCION=2 fue medido empiricamente en la placa real
// (ratio=0.250 exacto = factor 4 = 2 bits) -- si la relacion de anchos
// A_WIDTH/B_WIDTH cambia en el futuro, este valor hay que re-medirlo,
// no asumirlo.
// ============================================================

module gmsk_rotador_shift_fix #(
    parameter DATA_WIDTH = 32,      // ancho de CADA componente (I y Q)
    parameter SHIFT_CORRECCION = 2
) (
    input  wire        clk,
    input  wire        aresetn,

    // entrada/salida empaquetadas en un solo bus, misma convencion que
    // el resto del diseño: {Q[2*DATA_WIDTH-1:DATA_WIDTH], I[DATA_WIDTH-1:0]}
    input  wire [2*DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output reg  [2*DATA_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    wire signed [DATA_WIDTH-1:0] i_in = s_axis_tdata[DATA_WIDTH-1:0];
    wire signed [DATA_WIDTH-1:0] q_in = s_axis_tdata[2*DATA_WIDTH-1:DATA_WIDTH];

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            // <<< : corrimiento aritmetico a la izquierda, preserva el signo
            m_axis_tdata  <= {q_in <<< SHIFT_CORRECCION, i_in <<< SHIFT_CORRECCION};
            m_axis_tvalid <= s_axis_tvalid;
        end
    end
endmodule