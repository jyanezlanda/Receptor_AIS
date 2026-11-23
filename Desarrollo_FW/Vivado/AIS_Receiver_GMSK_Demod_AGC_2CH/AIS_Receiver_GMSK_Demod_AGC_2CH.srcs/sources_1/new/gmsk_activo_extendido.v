// ============================================================
// gmsk_activo_extendido.v
//
// Mantiene la salida en alto N_EXT muestras de IQ despues de que "activo" cae.
// "tick" es la cadencia de las muestras (mag_tvalid, ~192 kHz): N_EXT = 576 son 3 ms.
// Si "activo" vuelve a subir antes de agotarse la cuenta, la cuenta se recarga y la salida no cae.
// La salida sube junto con "activo" (con un ciclo de reloj de retardo).
// ============================================================

module gmsk_activo_extendido #(
    parameter N_EXT = 576
) (
    input  wire clk,
    input  wire aresetn,

    input  wire tick,          // una vez por muestra de IQ
    input  wire activo,        // activo_confirmado del squelch

    output reg  activo_ext
);
    localparam W = $clog2(N_EXT + 1);

    reg [W-1:0] resto;

    always @(posedge clk) begin
        if (!aresetn) begin
            resto      <= {W{1'b0}};
            activo_ext <= 1'b0;
        end else begin
            if (activo)
                resto <= N_EXT[W-1:0];
            else if (tick && resto != 0)
                resto <= resto - 1'b1;

            activo_ext <= activo | (resto != 0);
        end
    end
endmodule