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
//
// Cada muestra se procesa en una tuberia de 8 etapas registradas (el resultado por muestra es el de un calculo en un solo
// ciclo): los umbrales y los acumuladores quedan actualizados 8 ciclos despues de mag_tvalid. Las muestras deben llegar
// separadas por al menos 8 ciclos (en el receptor, 651).
//
// Aprende solo las muestras con activo = 0 y mag <= umbral_alto (la primera muestra tras el reset siempre, para sembrar el piso):
// una muestra por encima del umbral es señal, no piso. Si no, las muestras de la rampa previas a la confirmacion del
// antirrebote realimentan el umbral y el squelch se bloquea con ranuras adyacentes sin silencio entre ellas.
//
// Reaprendizaje: mientras activo = 1 mide el promedio de la magnitud y su desviacion media. La señal AIS tiene envolvente constante
// (desviacion/promedio chica); el ruido no (desviacion/promedio ~0,5). Si durante T_REAPRENDER muestras netas la desviacion supera
// RATIO_NUM/RATIO_DEN del promedio, el squelch esta abierto sobre ruido (el piso subio, por ejemplo al subir la ganancia): siembra el
// piso y la dispersion con esas medidas y los umbrales quedan por encima del ruido.
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
    ,
    parameter SHIFT_ACT_M   = 6,      // promedio de la magnitud mientras esta abierto (adaptacion: 2^SHIFT_ACT_M muestras)
    parameter SHIFT_ACT_D   = 7,      // desviacion media respecto de ese promedio
    parameter RATIO_NUM     = 3,      // abierto sobre ruido: desviacion/promedio > RATIO_NUM/RATIO_DEN
    parameter RATIO_DEN     = 8,
    parameter T_REAPRENDER  = 16384   // muestras netas con ese comportamiento antes de reaprender (~85 ms a 192 kHz)
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] mag_tdata,
    input  wire        mag_tvalid,

    input  wire        activo,   // realimentacion: salida del propio squelch (post-debounce, idealmente)

    output wire [DATA_WIDTH-1:0] umbral_alto,
    output wire [DATA_WIDTH-1:0] umbral_bajo,
    output wire [DATA_WIDTH-1:0] piso_ruido_dbg,
    output wire [DATA_WIDTH-1:0] dispersion_dbg
);
    localparam PW = DATA_WIDTH + SHIFT_PISO;     // ancho de acum_piso
    localparam DW = DATA_WIDTH + SHIFT_DISP;     // ancho de acum_disp

    reg  [PW-1:0] acum_piso;
    reg  [DW-1:0] acum_disp;
    wire [DATA_WIDTH-1:0] piso_ruido = acum_piso[PW-1:SHIFT_PISO];
    wire [DATA_WIDTH-1:0] dispersion = acum_disp[DW-1:SHIFT_DISP];

    // sembrado: en la primera muestra real tras el reset, arranca el
    // piso directo en el valor real (en vez de subir desde 0 durante
    // miles de muestras) -- evita el transitorio inicial donde
    // dispersion se dispara mientras piso todavia esta muy lejos del
    // valor real
    reg primera_muestra;

    // Actualizacion por error con paso minimo de 1: cada acumulador converge exacto a su entrada (x 2^SHIFT) y decae a 0 en
    // silencio. El paso minimo evita que quede clavado en un residuo que el piso y la dispersion no muestran (leen 0) y que
    // haria saltar los umbrales con la primera muestra.

    // ---- etapa 0: acepta la muestra (solo si no hay senal) ----
    reg v0, sem0;
    reg [DATA_WIDTH-1:0] mag0;

    // ---- etapa 1: errores del piso y del desvio, con el estado todavia sin actualizar ----
    reg v1, sem1;
    reg [DATA_WIDTH-1:0] mag1;
    reg signed [PW:0] err_p1;
    reg signed [DATA_WIDTH:0] desv1;
    wire signed [PW:0] err_p_w = $signed({1'b0, mag0, {SHIFT_PISO{1'b0}}}) - $signed({1'b0, acum_piso});
    wire signed [DATA_WIDTH:0] desv_w = $signed({1'b0, mag0}) - $signed({1'b0, piso_ruido});

    // ---- etapa 2: paso del piso y valor absoluto del desvio ----
    reg v2, sem2;
    reg [DATA_WIDTH-1:0] mag2, dabs2;
    reg signed [PW:0] paso_p2;
    wire signed [PW:0] paso_pc = err_p1 >>> SHIFT_PISO;
    wire signed [PW:0] paso_pw = (paso_pc == 0 && err_p1 != 0) ? (err_p1[PW] ? -1 : 1) : paso_pc;
    wire [DATA_WIDTH-1:0] dabs_w = desv1[DATA_WIDTH] ? (-desv1[DATA_WIDTH-1:0]) : desv1[DATA_WIDTH-1:0];

    // ---- etapa 3: actualiza acum_piso; error de la dispersion ----
    reg v3, sem3;
    reg signed [DW:0] err_d3;
    wire signed [DW:0] err_d_w = $signed({1'b0, dabs2, {SHIFT_DISP{1'b0}}}) - $signed({1'b0, acum_disp});

    // ---- etapa 4: paso de la dispersion ----
    reg v4, sem4;
    reg signed [DW:0] paso_d4;
    wire signed [DW:0] paso_dc = err_d3 >>> SHIFT_DISP;
    wire signed [DW:0] paso_dw = (paso_dc == 0 && err_d3 != 0) ? (err_d3[DW] ? -1 : 1) : paso_dc;

    // ---- etapa 5: actualiza acum_disp; etapas 6 y 7: umbrales ----
    reg v5, v6;
    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] margen_alto = K_ALTO * dispersion;
    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] margen_bajo = K_BAJO * dispersion;
    reg [DATA_WIDTH-1:0] malto6, mbajo6, umbral_alto_r, umbral_bajo_r;

    // ---- estadistica con activo = 1: promedio (acum_m), desviacion media (acum_d) y contador de comportamiento de ruido ----
    localparam MW = DATA_WIDTH + SHIFT_ACT_M;
    localparam NW = DATA_WIDTH + SHIFT_ACT_D;
    localparam CW = $clog2(T_REAPRENDER + 1);
    reg  [MW-1:0] acum_m;
    reg  [NW-1:0] acum_d;
    wire [DATA_WIDTH-1:0] m_int = acum_m[MW-1:SHIFT_ACT_M];
    wire [DATA_WIDTH-1:0] d_int = acum_d[NW-1:SHIFT_ACT_D];
    reg           primera_act;                              // primera muestra con activo = 1 desde que se abrio
    reg           a0v, a0s, a1v, a1s, a2v, a2s, a3v, a3s, a4v, a4s, a5v, a5s, a6v, ruidoso6;
    reg  [DATA_WIDTH-1:0] a0mag, a1mag, a2mag, a3mag, a2dabs;
    reg  signed [MW:0]    a1err_m, a2paso_m;
    reg  signed [DATA_WIDTH:0] a1desv;
    reg  signed [NW:0]    a3err_d, a4paso_d;
    reg  [CW-1:0] cuenta;
    reg           reaprende;                                // pulso: reinicia el piso y la dispersion con las medidas de esta seccion
    reg  [2:0]    rs;
    reg  [15:0]   n_reaprende;                              // solo para simulacion (sin salida: la sintesis lo elimina)
    wire signed [MW:0]         err_m_w   = $signed({1'b0, a0mag, {SHIFT_ACT_M{1'b0}}}) - $signed({1'b0, acum_m});
    wire signed [DATA_WIDTH:0] desv_a_w  = $signed({1'b0, a0mag}) - $signed({1'b0, m_int});
    wire signed [MW:0]         pm_c      = a1err_m >>> SHIFT_ACT_M;
    wire [DATA_WIDTH-1:0]      dabs_a_w  = a1desv[DATA_WIDTH] ? (-a1desv[DATA_WIDTH-1:0]) : a1desv[DATA_WIDTH-1:0];
    wire signed [NW:0]         err_d_a_w = $signed({1'b0, a2dabs, {SHIFT_ACT_D{1'b0}}}) - $signed({1'b0, acum_d});
    wire signed [NW:0]         pd_c      = a3err_d >>> SHIFT_ACT_D;
    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] lado_d = d_int * RATIO_DEN;
    (* use_dsp = "no" *) wire [DATA_WIDTH+3:0] lado_m = m_int * RATIO_NUM;

    always @(posedge clk) begin
        if (!aresetn) begin
            acum_m <= 0; acum_d <= 0; primera_act <= 1'b1; cuenta <= 0; reaprende <= 1'b0; rs <= 3'b000; n_reaprende <= 0;
            a0v <= 1'b0; a1v <= 1'b0; a2v <= 1'b0; a3v <= 1'b0; a4v <= 1'b0; a5v <= 1'b0; a6v <= 1'b0;
        end else begin
            reaprende <= 1'b0;
            rs <= {rs[1:0], reaprende};
            if (!activo) begin
                primera_act <= 1'b1;
                cuenta      <= 0;
                a0v <= 1'b0;
            end else begin
                a0v <= mag_tvalid;
                if (mag_tvalid) begin a0mag <= mag_tdata; a0s <= primera_act; primera_act <= 1'b0; end
            end
            a1v <= a0v; a1s <= a0s; a1mag <= a0mag; a1err_m <= err_m_w; a1desv <= desv_a_w;
            a2v <= a1v; a2s <= a1s; a2mag <= a1mag; a2paso_m <= (pm_c == 0 && a1err_m != 0) ? (a1err_m[MW] ? -1 : 1) : pm_c; a2dabs <= dabs_a_w;
            if (a2v) acum_m <= a2s ? {a2mag, {SHIFT_ACT_M{1'b0}}} : acum_m + a2paso_m[MW-1:0];
            a3v <= a2v; a3s <= a2s; a3err_d <= err_d_a_w;
            a4v <= a3v; a4s <= a3s; a4paso_d <= (pd_c == 0 && a3err_d != 0) ? (a3err_d[NW] ? -1 : 1) : pd_c;
            if (a4v) acum_d <= a4s ? {NW{1'b0}} : acum_d + a4paso_d[NW-1:0];
            a5v <= a4v; a5s <= a4s;
            a6v <= a5v; ruidoso6 <= (lado_d > lado_m) && !a5s;
            if (a6v) begin
                if (ruidoso6) begin
                    if (cuenta >= T_REAPRENDER - 1) begin reaprende <= 1'b1; cuenta <= 0; n_reaprende <= n_reaprende + 1'b1; end
                    else cuenta <= cuenta + 1'b1;
                end else if (cuenta != 0) cuenta <= cuenta - 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (!aresetn) begin
            acum_piso       <= 0;
            acum_disp       <= 0;
            primera_muestra <= 1'b1;
            v0 <= 1'b0; v1 <= 1'b0; v2 <= 1'b0; v3 <= 1'b0; v4 <= 1'b0; v5 <= 1'b0; v6 <= 1'b0;
            umbral_alto_r <= MARGEN_MINIMO;
            umbral_bajo_r <= MARGEN_MINIMO;
        end else begin
            v0 <= mag_tvalid && !activo && (primera_muestra || mag_tdata <= umbral_alto);
            if (mag_tvalid && !activo && (primera_muestra || mag_tdata <= umbral_alto)) begin
                mag0 <= mag_tdata;
                sem0 <= primera_muestra;
                primera_muestra <= 1'b0;
            end

            v1 <= v0; sem1 <= sem0; mag1 <= mag0; err_p1 <= err_p_w; desv1 <= desv_w;
            v2 <= v1; sem2 <= sem1; mag2 <= mag1; paso_p2 <= paso_pw; dabs2 <= dabs_w;

            if (v2) acum_piso <= sem2 ? {mag2, {SHIFT_PISO{1'b0}}} : acum_piso + paso_p2[PW-1:0];
            v3 <= v2; sem3 <= sem2; err_d3 <= err_d_w;

            v4 <= v3; sem4 <= sem3; paso_d4 <= paso_dw;

            if (v4) acum_disp <= sem4 ? {DW{1'b0}} : acum_disp + paso_d4[DW-1:0];
            v5 <= v4;

            v6 <= v5;
            malto6 <= margen_alto[DATA_WIDTH-1:0];
            mbajo6 <= margen_bajo[DATA_WIDTH-1:0];

            if (reaprende) begin
                acum_piso <= {m_int, {SHIFT_PISO{1'b0}}};
                acum_disp <= {d_int, {SHIFT_DISP{1'b0}}};
            end

            if (v6 || rs[1]) begin
                umbral_alto_r <= piso_ruido + malto6 + MARGEN_MINIMO;
                umbral_bajo_r <= piso_ruido + mbajo6 + MARGEN_MINIMO;
            end
        end
    end

    assign umbral_alto = umbral_alto_r;
    assign umbral_bajo = umbral_bajo_r;
    assign piso_ruido_dbg = piso_ruido;
    assign dispersion_dbg = dispersion;
endmodule