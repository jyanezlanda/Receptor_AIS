// ============================================================
// gmsk_pico_rafaga.v
//
// Registra el pico de nivel de cada rafaga y cuenta las rafagas, para que el AGC no dependa de muestrear "activo" desde software.
// Una rafaga es lo que dura "activo" en alto. Los primeros N_IGNORAR ticks de cada rafaga no cuentan para el pico: "nivel" arrastra el resto de la
// rafaga anterior (960 ticks = 5 ms a ~192 kHz). Al caer "activo" se actualizan juntos:
//   pico_cont[DATA_WIDTH-1:0]  pico de la rafaga (0 si la rafaga duro N_IGNORAR ticks o menos)
//   pico_cont[31:DATA_WIDTH]   contador de rafagas (incluye las cortas); da la vuelta al llegar al maximo
//   rafaga_info[DUR_WIDTH-1:0] duracion de la rafaga en ticks (satura)
//   rafaga_info[DUR_WIDTH]     1 si hubo al menos un tick medido (el pico es valido); es el bit 16 con DUR_WIDTH = 16
// pico_cont se lee en una sola palabra, asi que pico y contador son consistentes. Para leer tambien rafaga_info, leer pico_cont antes y despues
// y descartar la lectura si el contador cambio.
// ============================================================

module gmsk_pico_rafaga #(
    parameter DATA_WIDTH = 20,
    parameter N_IGNORAR  = 960,
    parameter DUR_WIDTH  = 16
) (
    input  wire                  clk,
    input  wire                  aresetn,

    input  wire                  tick,         // una vez por muestra de IQ (mag_tvalid)
    input  wire                  activo,       // activo_confirmado del squelch
    input  wire [DATA_WIDTH-1:0] nivel,        // salida de gmsk_nivel_senal

    output wire [31:0]           pico_cont,
    output wire [31:0]           rafaga_info,
    output reg                   fin_rafaga    // pulso de un ciclo al terminar cada rafaga
);
    localparam CONT_WIDTH = 32 - DATA_WIDTH;
    localparam [DUR_WIDTH-1:0] DUR_MAX = {DUR_WIDTH{1'b1}};

    reg                   activo_d;
    reg [DUR_WIDTH-1:0]   n_act;               // ticks de la rafaga en curso
    reg [DATA_WIDTH-1:0]  pico_run;
    reg                   valida_run;

    reg [DATA_WIDTH-1:0]  pico_l;
    reg [DUR_WIDTH-1:0]   dur_l;
    reg                   valida_l;
    reg [CONT_WIDTH-1:0]  cont;

    wire subida = activo & ~activo_d;
    wire caida  = ~activo & activo_d;

    wire [DUR_WIDTH-1:0]  n_base      = subida ? {DUR_WIDTH{1'b0}} : n_act;
    wire [DATA_WIDTH-1:0] pico_base   = subida ? {DATA_WIDTH{1'b0}} : pico_run;
    wire                  valida_base = subida ? 1'b0 : valida_run;
    wire                  medir       = (n_base >= N_IGNORAR);     // el tick actual es el numero n_base + 1 de la rafaga

    always @(posedge clk) begin
        if (!aresetn) begin
            activo_d <= 1'b0; n_act <= {DUR_WIDTH{1'b0}}; pico_run <= {DATA_WIDTH{1'b0}}; valida_run <= 1'b0;
            pico_l <= {DATA_WIDTH{1'b0}}; dur_l <= {DUR_WIDTH{1'b0}}; valida_l <= 1'b0; cont <= {CONT_WIDTH{1'b0}}; fin_rafaga <= 1'b0;
        end else begin
            activo_d   <= activo;
            fin_rafaga <= caida;

            if (activo) begin
                n_act <= n_base; pico_run <= pico_base; valida_run <= valida_base;
                if (tick) begin
                    if (n_base != DUR_MAX) n_act <= n_base + 1'b1;
                    if (medir) begin
                        valida_run <= 1'b1;
                        if (!valida_base || nivel > pico_base) pico_run <= nivel;
                    end
                end
            end

            if (caida) begin
                pico_l   <= valida_run ? pico_run : {DATA_WIDTH{1'b0}};
                valida_l <= valida_run;
                dur_l    <= n_act;
                cont     <= cont + 1'b1;
            end
        end
    end

    assign pico_cont   = {cont, pico_l};
    assign rafaga_info = {{(31 - DUR_WIDTH){1'b0}}, valida_l, dur_l};
endmodule