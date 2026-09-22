// ============================================================
// gmsk_symbol_phase_accum.v
//
// Correlador de un solo bin de DFT (metodo Goertzel), equivalente en
// streaming a recuperar_fase_simbolo(): acumula y[n]=soft[n]^2 contra un
// tono local a f0=1/sps durante N_BLOQUE muestras, y entrega el
// resultado complejo acumulado (para pasar por un CORDIC externo y
// obtener el angulo -> tau), una vez por bloque.
//
// El tono local (cos/sin a f0=1/sps) se genera con un NCO externo
// (dds_compiler, modo Fixed) instanciado en el canvas -- este modulo
// solo hace la multiplicacion real y la acumulacion.
// ============================================================

module gmsk_symbol_phase_accum #(
    parameter DATA_WIDTH   = 24,
    parameter NCO_WIDTH    = 24,
    parameter N_BLOQUE     = 4000,
    parameter OUT_WIDTH    = 24,
    parameter SHIFT_SALIDA = 39
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_soft_tdata,
    input  wire        s_axis_soft_tvalid,

    input  wire [2*NCO_WIDTH-1:0] s_axis_nco_tdata,
    input  wire        s_axis_nco_tvalid,

    output reg  signed [OUT_WIDTH-1:0] m_axis_acc_i_tdata,
    output reg  signed [OUT_WIDTH-1:0] m_axis_acc_q_tdata,
    output reg         m_axis_acc_tvalid
);
    localparam PROD_WIDTH = 2*DATA_WIDTH;   // 48, y=soft^2 (siempre >=0)
    localparam ACC_WIDTH  = PROD_WIDTH + NCO_WIDTH + $clog2(N_BLOQUE) + 2;

    wire signed [NCO_WIDTH-1:0] nco_cos = s_axis_nco_tdata[NCO_WIDTH-1:0];
    wire signed [NCO_WIDTH-1:0] nco_sin = s_axis_nco_tdata[2*NCO_WIDTH-1:NCO_WIDTH];

    // ------------------------------------------------------------
    // etapa 1: registrar soft^2 (un solo multiplicador 24x24, entra
    // en un DSP48) y el NCO en paralelo
    // ------------------------------------------------------------
    reg [PROD_WIDTH-1:0]       y_reg;   // no negativo (es un cuadrado)
    reg signed [NCO_WIDTH-1:0] cos_reg, sin_reg;
    reg                        valido_e1;

    always @(posedge clk) begin
        if (!aresetn) begin
            valido_e1 <= 1'b0;
        end else begin
            y_reg     <= s_axis_soft_tdata * s_axis_soft_tdata;
            cos_reg   <= nco_cos;
            sin_reg   <= nco_sin;
            valido_e1 <= s_axis_soft_tvalid && s_axis_nco_tvalid;
        end
    end

    // ------------------------------------------------------------
    // etapa 2: partir el multiplicador ancho (48x24) en dos
    // multiplicadores angostos (24x24, cada uno entra en un DSP48)
    // -- parte alta y parte baja de y_reg por separado
    // ------------------------------------------------------------
    localparam MITAD = PROD_WIDTH/2;  // 24

    reg signed [MITAD+NCO_WIDTH-1:0] hi_cos_reg, hi_sin_reg;
    reg        [MITAD+NCO_WIDTH-1:0] lo_cos_reg, lo_sin_reg;
    reg signed [NCO_WIDTH-1:0]       cos_reg2, sin_reg2;
    reg                               valido_e2;

    always @(posedge clk) begin
        if (!aresetn) begin
            valido_e2 <= 1'b0;
        end else begin
            // y_reg[47:24] (parte alta) es con signo (siempre positivo,
            // pero se trata como magnitud); y_reg[23:0] (parte baja) sin signo
            hi_cos_reg <= $signed({1'b0, y_reg[PROD_WIDTH-1:MITAD]}) * cos_reg;
            hi_sin_reg <= $signed({1'b0, y_reg[PROD_WIDTH-1:MITAD]}) * sin_reg;
            lo_cos_reg <= y_reg[MITAD-1:0] * cos_reg;
            lo_sin_reg <= y_reg[MITAD-1:0] * sin_reg;
            valido_e2  <= valido_e1;
        end
    end

    // ------------------------------------------------------------
    // etapa 3: combinar hi<<24 + lo (un solo sumador ancho, ya sin
    // ningun multiplicador en el camino)
    // ------------------------------------------------------------
    reg signed [ACC_WIDTH-1:0] termino_i_reg, termino_q_reg;
    reg                         valido_e3;

    always @(posedge clk) begin
        if (!aresetn) begin
            valido_e3 <= 1'b0;
        end else begin
            termino_i_reg <= ($signed(hi_cos_reg) <<< MITAD) + $signed({1'b0, lo_cos_reg});
            termino_q_reg <= ($signed(hi_sin_reg) <<< MITAD) + $signed({1'b0, lo_sin_reg});
            valido_e3     <= valido_e2;
        end
    end

    // ------------------------------------------------------------
    // etapa 4: acumular (solo una suma, junto con el conteo de bloque)
    // ------------------------------------------------------------
    reg signed [ACC_WIDTH-1:0] acc_i, acc_q;
    reg [$clog2(N_BLOQUE)-1:0] contador;

    always @(posedge clk) begin
        if (!aresetn) begin
            acc_i             <= {ACC_WIDTH{1'b0}};
            acc_q             <= {ACC_WIDTH{1'b0}};
            contador          <= 0;
            m_axis_acc_tvalid <= 1'b0;
        end else begin
            m_axis_acc_tvalid <= 1'b0;

            if (valido_e3) begin
                if (contador == N_BLOQUE-1) begin
                    m_axis_acc_i_tdata <= (acc_i + termino_i_reg) >>> SHIFT_SALIDA;
                    m_axis_acc_q_tdata <= (acc_q - termino_q_reg) >>> SHIFT_SALIDA;
                    m_axis_acc_tvalid  <= 1'b1;
                    acc_i    <= {ACC_WIDTH{1'b0}};
                    acc_q    <= {ACC_WIDTH{1'b0}};
                    contador <= 0;
                end else begin
                    acc_i    <= acc_i + termino_i_reg;
                    acc_q    <= acc_q - termino_q_reg;
                    contador <= contador + 1'b1;
                end
            end
        end
    end
endmodule