// ============================================================
// gmsk_tau_to_fase.v
//
// Convierte la fase que entrega el CORDIC (angulo/pi de la salida del
// correlador Goertzel, tras pasar por un cmpy si hace falta conjugar,
// y el CORDIC en modo translate) al valor de acumulador de fase que
// gmsk_symbol_strobe necesita para recargarse.
//
// tau_python = (-angulo/(2*pi)) mod 1  ->  en la convencion
// angulo/pi de 16 bits con signo del CORDIC, esto es simplemente
// invertir el signo y reinterpretar como fraccion sin signo de
// ACC_WIDTH bits (una vuelta completa = 1 simbolo).
//
// carga = TRIM_UNA_MUESTRA - fase * 83443, en aritmetica modular de
// ACC_WIDTH bits. La constante se descompone en siete terminos:
//   83443 = 2^16 + 2^14 + 2^11 - 2^9 - 2^4 + 2^2 - 1
// y se agrupan los terminos positivos y los negativos:
//   carga = (TRIM + 2^9*f + 2^4*f + f) - (2^16*f + 2^14*f + 2^11*f + 2^2*f)
// Las sumas se reparten en tres etapas con registros, una suma o resta
// de dos operandos por etapa. m_axis_carga_tvalid sale 3 ciclos despues
// de s_axis_cordic_tvalid y m_axis_carga_tdata mantiene su valor
// hasta la proxima carga.
// ============================================================

module gmsk_tau_to_fase #(
    parameter PHASE_WIDTH = 16,
    parameter ACC_WIDTH   = 32
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [2*PHASE_WIDTH-1:0] s_axis_cordic_tdata,
    input  wire        s_axis_cordic_tvalid,

    output reg  [ACC_WIDTH-1:0] m_axis_carga_tdata,
    output reg         m_axis_carga_tvalid
);
    wire signed [PHASE_WIDTH-1:0] fase = s_axis_cordic_tdata[2*PHASE_WIDTH-1:PHASE_WIDTH];
    wire signed [ACC_WIDTH-1:0]   f    = fase;

    localparam signed [ACC_WIDTH-1:0] TRIM_UNA_MUESTRA = 32'sd214748365;

    // Etapa 1: cuatro sumas parciales (dos de terminos positivos, dos de negativos)
    reg signed [ACC_WIDTH-1:0] p1, p2, n1, n2;
    // Etapa 2: total de positivos y total de negativos
    reg signed [ACC_WIDTH-1:0] pp, nn;
    reg v1, v2;

    always @(posedge clk) begin
        p1 <= (f <<< 9) + (f <<< 4);
        p2 <= f + TRIM_UNA_MUESTRA;
        n1 <= (f <<< 16) + (f <<< 14);
        n2 <= (f <<< 11) + (f <<< 2);

        pp <= p1 + p2;
        nn <= n1 + n2;

        if (!aresetn) begin
            v1 <= 1'b0;
            v2 <= 1'b0;
            m_axis_carga_tvalid <= 1'b0;
        end else begin
            v1 <= s_axis_cordic_tvalid;
            v2 <= v1;
            m_axis_carga_tvalid <= v2;
            if (v2) begin
                m_axis_carga_tdata <= pp - nn;
            end
        end
    end
endmodule