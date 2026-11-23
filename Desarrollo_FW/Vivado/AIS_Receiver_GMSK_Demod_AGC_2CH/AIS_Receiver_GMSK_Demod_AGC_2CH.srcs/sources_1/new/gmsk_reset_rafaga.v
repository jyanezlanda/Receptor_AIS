// ============================================================
// gmsk_reset_rafaga.v
//
// Genera un ARESETn (activo en bajo) para la recuperacion de simbolo
// (dc_tracker_symb, y opcionalmente el resto del bloque) que se
// dispara solo, sin intervencion de software, cada vez que "activo"
// (senal cruda del squelch) sube. Arranca de una rafaga nueva.
// Mantiene el reset bajo durante N_CICLOS_RESET ciclos (no solo uno),
// para ser compatible con cualquier IP que necesite el reset
// sostenido un minimo de ciclos. 
// ============================================================

module gmsk_reset_rafaga #(
    parameter N_CICLOS_RESET = 8
) (
    input  wire clk,
    input  wire aresetn_global,   // reset general del sistema

    input  wire activo,           // señal cruda del squelch

    output wire aresetn_simbolo   // reset para dc_tracker_symb (y el
                                   // resto de la recuperacion de simbolo)
);
    reg       activo_anterior;
    reg [3:0] contador_reset;
    reg       en_reset_rafaga;

    always @(posedge clk) begin
        if (!aresetn_global) begin
            activo_anterior  <= 1'b0;
            contador_reset   <= 4'd0;
            en_reset_rafaga  <= 1'b0;
        end else begin
            activo_anterior <= activo;

            if (activo && !activo_anterior) begin
                // flanco de subida: arranca una rafaga nueva
                contador_reset  <= N_CICLOS_RESET[3:0] - 4'd1;
                en_reset_rafaga <= 1'b1;
            end else if (en_reset_rafaga) begin
                if (contador_reset == 4'd0)
                    en_reset_rafaga <= 1'b0;
                else
                    contador_reset <= contador_reset - 4'd1;
            end
        end
    end

    assign aresetn_simbolo = aresetn_global && !en_reset_rafaga;
endmodule