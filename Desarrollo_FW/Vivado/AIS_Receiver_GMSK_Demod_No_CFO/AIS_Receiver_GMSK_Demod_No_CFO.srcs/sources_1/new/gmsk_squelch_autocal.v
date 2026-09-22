// ============================================================
// gmsk_squelch_autocal.v (v2 -- margen calculado, no fijo)
//
// Rastrea el piso de ruido (promedio movil) Y su dispersion (desviacion
// media respecto del promedio, una aproximacion barata de la desviacion
// estandar sin necesitar un multiplicador para elevar al cuadrado).
// Los umbrales se calculan como piso + K*dispersion -- si el ruido real
// es mas "sucio", el margen crece solo; si es mas limpio, se achica
// solo. Nada de constantes fijas elegidas a mano.
//
// K_ALTO deberia ser bastante mayor que K_BAJO, para mantener la
// histeresis (igual que en la version anterior, pero ahora expresada
// como multiplo de la dispersion real, no como offset fijo).
// ============================================================

module gmsk_squelch_autocal #(
    parameter DATA_WIDTH  = 16,
    parameter SHIFT_PISO  = 14,  // velocidad de adaptacion del promedio (mas alto = mas lento)
    parameter SHIFT_DISP  = 10,  // velocidad de adaptacion de la dispersion (tipicamente mas rapido que el piso)
    parameter K_ALTO      = 8,   // umbral_alto = piso + K_ALTO * dispersion
    parameter K_BAJO      = 3,   // umbral_bajo = piso + K_BAJO * dispersion  (K_BAJO < K_ALTO, para la histeresis)
    parameter MARGEN_MINIMO = 4  // piso minimo garantizado sobre piso_ruido, aunque
                                  // dispersion mida 0 (silencio genuino sin ruido) --
                                  // sin esto, umbral_bajo puede dar EXACTO 0, y la
                                  // condicion de desactivacion (magnitud < umbral_bajo)
                                  // se vuelve matematicamente imposible para una
                                  // magnitud sin signo
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] mag_tdata,
    input  wire        mag_tvalid,

    input  wire        activo,   // realimentacion: salida del propio squelch (post-debounce, idealmente)

    output wire [15:0] umbral_alto,
    output wire [15:0] umbral_bajo,
    output wire [15:0] piso_ruido_dbg,
    output wire [15:0] dispersion_dbg
);
    // ---- promedio movil del piso de ruido ----
    reg [DATA_WIDTH+SHIFT_PISO-1:0] acum_piso;
    wire [DATA_WIDTH-1:0] piso_ruido = acum_piso[DATA_WIDTH+SHIFT_PISO-1:SHIFT_PISO];

    // ---- desviacion media respecto del piso (proxy barato de la std) ----
    wire signed [DATA_WIDTH:0] desvio = $signed({1'b0, mag_tdata}) - $signed({1'b0, piso_ruido});
    wire [DATA_WIDTH-1:0] desvio_abs = desvio[DATA_WIDTH] ? (-desvio[DATA_WIDTH-1:0]) : desvio[DATA_WIDTH-1:0];

    reg [DATA_WIDTH+SHIFT_DISP-1:0] acum_disp;
    wire [DATA_WIDTH-1:0] dispersion = acum_disp[DATA_WIDTH+SHIFT_DISP-1:SHIFT_DISP];

    // sembrado: en la primera muestra real tras el reset, arranca el
    // piso directo en el valor real (en vez de subir desde 0 durante
    // miles de muestras) -- evita el transitorio inicial donde
    // dispersion se dispara mientras piso todavia esta muy lejos del
    // valor real
    reg primera_muestra;

    always @(posedge clk) begin
        if (!aresetn) begin
            acum_piso      <= 0;
            acum_disp      <= 0;
            primera_muestra <= 1'b1;
        end else if (mag_tvalid && !activo) begin
            if (primera_muestra) begin
                acum_piso       <= {mag_tdata, {SHIFT_PISO{1'b0}}};
                acum_disp       <= 0;
                primera_muestra <= 1'b0;
            end else begin
                acum_piso <= acum_piso - (acum_piso >> SHIFT_PISO) + mag_tdata;
                acum_disp <= acum_disp - (acum_disp >> SHIFT_DISP) + desvio_abs;
            end
        end
    end

    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] margen_alto = K_ALTO * dispersion;
    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] margen_bajo = K_BAJO * dispersion;
    assign umbral_alto = piso_ruido + margen_alto[15:0] + MARGEN_MINIMO;
    assign umbral_bajo = piso_ruido + margen_bajo[15:0] + MARGEN_MINIMO;
    assign piso_ruido_dbg = piso_ruido;
    assign dispersion_dbg = dispersion;
endmodule