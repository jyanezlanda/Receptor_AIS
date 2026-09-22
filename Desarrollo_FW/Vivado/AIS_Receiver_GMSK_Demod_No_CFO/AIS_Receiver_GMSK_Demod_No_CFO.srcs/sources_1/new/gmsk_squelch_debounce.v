// ============================================================
// gmsk_squelch_debounce.v
//
// Filtra parpadeos breves en "activo_crudo" (la salida directa de
// gmsk_squelch, que puede parpadear si la magnitud tiene ruido cerca
// de los umbrales). Solo acepta un cambio de estado si se mantiene
// estable durante N_CONFIRMACION muestras seguidas -- un blip breve
// que se revierte antes de esas N muestras NUNCA llega a propagarse
// a "activo_confirmado".
// ============================================================

module gmsk_squelch_debounce #(
    parameter N_CONFIRMACION = 8
) (
    input  wire clk,
    input  wire aresetn,

    input  wire activo_crudo,
    input  wire activo_crudo_tvalid,

    output reg  activo_confirmado
);
    reg [$clog2(N_CONFIRMACION+1)-1:0] contador;
    reg activo_crudo_anterior;

    always @(posedge clk) begin
        if (!aresetn) begin
            contador              <= 0;
            activo_confirmado     <= 1'b0;
            activo_crudo_anterior <= 1'b0;
        end else if (activo_crudo_tvalid) begin
            if (activo_crudo != activo_confirmado) begin
                if (activo_crudo == activo_crudo_anterior) begin
                    if (contador >= N_CONFIRMACION-1) begin
                        activo_confirmado <= activo_crudo;
                        contador          <= 0;
                    end else begin
                        contador <= contador + 1'b1;
                    end
                end else begin
                    contador <= 0;   // se revirtio antes de confirmar -- descartar
                end
            end else begin
                contador <= 0;
            end
            activo_crudo_anterior <= activo_crudo;
        end
    end
endmodule