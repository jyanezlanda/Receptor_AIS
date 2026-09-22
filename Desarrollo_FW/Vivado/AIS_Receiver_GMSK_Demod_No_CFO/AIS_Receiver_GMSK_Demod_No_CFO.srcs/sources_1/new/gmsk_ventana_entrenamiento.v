// ============================================================
// gmsk_ventana_entrenamiento.v
//
// Deja pasar "pulso_lazo" (lo que hoy alimenta al lazo de CFO) SOLO
// durante las primeras UMBRAL_MUESTRAS veces que pulsa despues de
// cada flanco de subida de "activo" (arranque de una rafaga nueva,
// segun el squelch). Pasado ese margen, corta el paso hasta la
// proxima rafaga.
//
// ============================================================

module gmsk_ventana_entrenamiento #(
    parameter UMBRAL_MUESTRAS = 640
) (
    input  wire clk,
    input  wire aresetn,

    input  wire activo,        // señal cruda del squelch (detecta arranque de rafaga)
    input  wire pulso_lazo,    // el pulso que ya alimenta hoy a dc_tracker/integrador

    output wire habilitado     // PULSO final ya calificado -- conectar directo
);
    reg        activo_anterior;
    reg [31:0] contador;
    reg        ventana_abierta;

    always @(posedge clk) begin
        if (!aresetn) begin
            activo_anterior <= 1'b0;
            contador        <= 32'd0;
            ventana_abierta <= 1'b0;
        end else begin
            activo_anterior <= activo;

            if (activo && !activo_anterior) begin
                // flanco de subida de activo: arranca una rafaga nueva
                contador        <= 32'd0;
                ventana_abierta <= 1'b1;
            end else if (pulso_lazo && ventana_abierta) begin
                if (contador < UMBRAL_MUESTRAS - 1) begin
                    contador <= contador + 1'b1;
                end else begin
                    ventana_abierta <= 1'b0;
                end
            end
        end
    end

    assign habilitado = pulso_lazo && ventana_abierta;
endmodule