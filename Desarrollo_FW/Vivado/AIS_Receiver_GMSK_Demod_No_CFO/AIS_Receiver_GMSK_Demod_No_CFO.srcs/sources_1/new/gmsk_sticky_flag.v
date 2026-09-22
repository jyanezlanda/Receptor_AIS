// ============================================================
// gmsk_sticky_flag.v
//
// Bandera "pegajosa": una vez que pulso_in sube aunque sea un solo
// ciclo, bandera se queda en 1 indefinidamente (hasta el proximo
// reset). Pensada para observar por software una señal que pulsa un
// solo ciclo de 125MHz cada ~651 ciclos (la tasa decimada) -- leer el
// pulso crudo directamente es inutil porque el sondeo por software
// nunca esta sincronizado con el momento exacto del pulso.
//
// Responde la pregunta "¿esto llego a pulsar alguna vez?", no "¿esta
// pulsando ahora?" -- para lo segundo hace falta un ILA de verdad.
// ============================================================

module gmsk_sticky_flag (
    input  wire clk,
    input  wire aresetn,
    input  wire pulso_in,

    output reg  bandera
);
    always @(posedge clk) begin
        if (!aresetn)
            bandera <= 1'b0;
        else if (pulso_in)
            bandera <= 1'b1;
    end
endmodule