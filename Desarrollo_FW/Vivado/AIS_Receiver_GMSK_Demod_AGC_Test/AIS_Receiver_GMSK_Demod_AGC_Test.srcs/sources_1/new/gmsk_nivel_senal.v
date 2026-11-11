// ============================================================
// gmsk_nivel_senal.v
//
// Seguidor de envolvente de mag_tdata (la magnitud del discriminador, antes
// del squelch): a diferencia de gmsk_squelch_autocal, corre siempre, sin el
// "!activo" que congela el piso de ruido durante una rafaga. Da el nivel de
// senal actual para que software (via sts_data) pueda ajustar la ganancia.
//
// Ataque rapido / liberacion lenta, igual que un seguidor de envolvente de
// audio: si la magnitud sube, el nivel la sigue en pocas muestras (ataque);
// si baja, el nivel decae de a poco (liberacion), para no perder la lectura
// entre simbolos o con huecos breves dentro de la propia rafaga.
//
// El acumulador interno guarda SHIFT_LIBERACION bits fraccionarios de mas
// (igual tecnica que acum_piso en gmsk_squelch_autocal). El paso nunca se
// trunca a 0 mientras quede error: sin eso, el update de liberacion (el mas
// lento) se clava 1 cuenta por debajo del valor real y nunca termina de
// converger.
// ============================================================

module gmsk_nivel_senal #(
    parameter DATA_WIDTH       = 16,
    parameter SHIFT_ATAQUE     = 4,   // constante de tiempo ~ 2^SHIFT muestras (ataque: debe ser chico)
    parameter SHIFT_LIBERACION = 10   // liberacion: debe ser bastante mayor que SHIFT_ATAQUE
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] mag_tdata,
    input  wire        mag_tvalid,

    output wire [DATA_WIDTH-1:0] nivel
);
    reg [DATA_WIDTH+SHIFT_LIBERACION-1:0] acum;
    assign nivel = acum[DATA_WIDTH+SHIFT_LIBERACION-1:SHIFT_LIBERACION];

    wire signed [DATA_WIDTH+SHIFT_LIBERACION:0] error =
        $signed({1'b0, mag_tdata, {SHIFT_LIBERACION{1'b0}}}) - $signed({1'b0, acum});
    wire en_ataque = !error[DATA_WIDTH+SHIFT_LIBERACION];   // error >= 0: la magnitud esta en o por encima del nivel actual

    (* use_dsp = "no" *) wire signed [DATA_WIDTH+SHIFT_LIBERACION:0] paso_crudo =
        en_ataque ? (error >>> SHIFT_ATAQUE) : (error >>> SHIFT_LIBERACION);
    // paso minimo de 1 (en el signo del error) mientras el error no sea cero: sin esto el update se
    // trunca a 0 antes de llegar al valor real y queda clavado una cuenta por debajo (o por encima).
    wire signed [DATA_WIDTH+SHIFT_LIBERACION:0] paso =
        (paso_crudo == 0 && error != 0) ? (en_ataque ? {{(DATA_WIDTH+SHIFT_LIBERACION){1'b0}}, 1'b1}
                                                      : {(DATA_WIDTH+SHIFT_LIBERACION+1){1'b1}})
                                         : paso_crudo;

    always @(posedge clk) begin
        if (!aresetn) begin
            acum <= 0;
        end else if (mag_tvalid) begin
            acum <= acum + paso[DATA_WIDTH+SHIFT_LIBERACION-1:0];
        end
    end
endmodule
