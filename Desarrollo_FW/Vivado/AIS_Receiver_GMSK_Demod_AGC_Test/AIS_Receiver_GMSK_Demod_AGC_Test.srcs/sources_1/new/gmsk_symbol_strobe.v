// ============================================================
// gmsk_symbol_strobe.v
//
// Genera un pulso de un ciclo cada ~sps muestras validas de soft[n].
// El acumulador de fase avanza INC por muestra y el strobe sale con el
// acarreo.
//
// La fase que llega por s_axis_carga (una vez por bloque del Goertzel)
// se aplica como correccion continua: se toma la diferencia mas corta
// entre la fase pedida y la actual (resta en complemento a 2), desplazada CORR_SHIFT bits a la derecha (se aplica 1/2^CORR_SHIFT de
// la diferencia; con CORR_SHIFT = 0 se aplica entera), y se suma al acumulador.
//   - Si la correccion cruza el desborde, el strobe sale en la muestra
//     siguiente (pend).
//   - Si la correccion hacia atras pasaria por un strobe ya emitido, el
//     acumulador se topa en 0.
// Asi un cambio de fase nunca saltea ni duplica un strobe.
//
// La correccion se calcula y aplica entre dos muestras (3 ciclos, con
// una muestra cada ~650 ciclos). Si llega una muestra mientras tanto,
// se recalcula despues de ella.
// ============================================================

module gmsk_symbol_strobe #(
    parameter ACC_WIDTH    = 32,
    parameter INC          = 32'd214734621,
    parameter CORR_SHIFT   = 0          // fraccion de la correccion de fase que se aplica en cada recarga: 1/2^CORR_SHIFT
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire        s_axis_soft_tvalid,

    input  wire [ACC_WIDTH-1:0] s_axis_carga_tdata,
    input  wire        s_axis_carga_tvalid,

    output wire        strobe
);
    reg  [ACC_WIDTH-1:0] acc;
    reg                  pend;                 // strobe pendiente: la correccion cruzo el desborde entre dos muestras
    wire [ACC_WIDTH:0]   suma = {1'b0, acc} + {1'b0, INC[ACC_WIDTH-1:0]};

    localparam [1:0] LIBRE = 2'd0, CALCULA = 2'd1, APLICA = 2'd2;
    reg  [1:0]                  estado;
    reg  [ACC_WIDTH-1:0]        carga_r;
    reg  signed [ACC_WIDTH-1:0] dif;           // distancia mas corta a la fase pedida

    wire signed [ACC_WIDTH+1:0] acc_ext = $signed({2'b00, acc});
    wire signed [ACC_WIDTH+1:0] dif_ext = {{2{dif[ACC_WIDTH-1]}}, dif};
    wire signed [ACC_WIDTH+1:0] corr    = acc_ext + dif_ext;

    always @(posedge clk) begin
        if (!aresetn) begin
            acc    <= {ACC_WIDTH{1'b0}};
            pend   <= 1'b0;
            estado <= LIBRE;
        end else begin
            if (s_axis_carga_tvalid) begin
                carga_r <= s_axis_carga_tdata;
                estado  <= CALCULA;
            end else begin
                case (estado)
                    CALCULA: if (!s_axis_soft_tvalid) begin
                        dif    <= $signed(carga_r - acc) >>> CORR_SHIFT;
                        estado <= APLICA;
                    end
                    APLICA: begin
                        if (s_axis_soft_tvalid) begin
                            estado <= CALCULA;                         // acc cambia con esta muestra: se recalcula
                        end else begin
                            if (corr[ACC_WIDTH+1]) begin
                                acc <= {ACC_WIDTH{1'b0}};              // hacia atras de un strobe ya emitido: tope en 0
                            end else begin
                                acc <= corr[ACC_WIDTH-1:0];
                                if (corr[ACC_WIDTH]) pend <= 1'b1;     // cruzo el desborde
                            end
                            estado <= LIBRE;
                        end
                    end
                    default: ;
                endcase
            end

            if (s_axis_soft_tvalid) begin
                acc  <= suma[ACC_WIDTH-1:0];
                pend <= 1'b0;
            end
        end
    end

    assign strobe = s_axis_soft_tvalid && (suma[ACC_WIDTH] || pend);
endmodule