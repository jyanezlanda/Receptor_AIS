// ============================================================
// gmsk_soft_scale.v
//
// Etapa final: recibe el TDATA completo del CORDIC (translate), aisla
// el campo de fase, y escala a soft[n] (soft = angulo_radianes / sensitivity).
//
// soft = (fase * 13037) >>> 8. La constante se descompone en siete
// terminos:
//   13037 = 2^14 - 2^12 + 2^10 - 2^8 - 2^4 - 2^2 + 1
// y se agrupan los terminos positivos y los negativos:
//   producto = (2^14 + 2^10 + 1)*x - (2^12 + 2^8 + 2^4 + 2^2)*x
// Las sumas se reparten en tres etapas con registros, una suma o resta
// de dos operandos por etapa. m_axis_soft_tvalid sale 3 ciclos despues de
// s_axis_phase_tvalid y m_axis_soft_tdata se actualiza en cada ciclo.
// ============================================================

module gmsk_soft_scale #(
    parameter PHASE_WIDTH = 16,
    parameter SOFT_WIDTH  = 24
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [PHASE_WIDTH-1:0] s_axis_phase_tdata,
    input  wire        s_axis_phase_tvalid,

    output reg  signed [SOFT_WIDTH-1:0] m_axis_soft_tdata,
    output reg         m_axis_soft_tvalid
);
    localparam PW = PHASE_WIDTH + 16;

    wire signed [PW-1:0] x = s_axis_phase_tdata;

    // Etapa 1: tres sumas parciales y el dato alineado
    reg signed [PW-1:0] p1, n1, n2, x1;
    // Etapa 2: total de positivos y total de negativos
    reg signed [PW-1:0] pp, nn;
    reg v1, v2;

    always @(posedge clk) begin
        p1 <= (x <<< 14) + (x <<< 10);
        n1 <= (x <<< 12) + (x <<< 8);
        n2 <= (x <<< 4) + (x <<< 2);
        x1 <= x;

        pp <= p1 + x1;
        nn <= n1 + n2;

        m_axis_soft_tdata <= (pp - nn) >>> 8;

        if (!aresetn) begin
            v1 <= 1'b0;
            v2 <= 1'b0;
            m_axis_soft_tvalid <= 1'b0;
        end else begin
            v1 <= s_axis_phase_tvalid;
            v2 <= v1;
            m_axis_soft_tvalid <= v2;
        end
    end
endmodule