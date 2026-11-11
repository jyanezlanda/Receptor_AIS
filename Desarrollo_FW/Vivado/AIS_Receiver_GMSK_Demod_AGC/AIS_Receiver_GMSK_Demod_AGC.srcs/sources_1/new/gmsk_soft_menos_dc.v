// ============================================================
// gmsk_soft_menos_dc.v
//
// Resta combinacional soft - dc, con saturacion al rango de DATA_WIDTH bits con signo. Entrega al correlador de fase de simbolo
// (Goertzel) el soft sin el DC que mete un error de frecuencia: con DC el cuadrado soft^2 tiene un termino cruzado 2*dato*DC
// que sesga la estimacion de la fase.
// ============================================================

module gmsk_soft_menos_dc #(
    parameter DATA_WIDTH = 24
) (
    input  wire signed [DATA_WIDTH-1:0] soft_tdata,
    input  wire signed [DATA_WIDTH-1:0] dc_tdata,
    output wire signed [DATA_WIDTH-1:0] dout_tdata
);
    localparam signed [DATA_WIDTH-1:0] MAXIMO = {1'b0, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [DATA_WIDTH-1:0] MINIMO = {1'b1, {(DATA_WIDTH-1){1'b0}}};

    wire signed [DATA_WIDTH:0] dif  = soft_tdata - dc_tdata;                 // 1 bit extra: la resta puede exceder DATA_WIDTH bits
    wire                       sobre = (dif[DATA_WIDTH] != dif[DATA_WIDTH-1]);

    assign dout_tdata = sobre ? (dif[DATA_WIDTH] ? MINIMO : MAXIMO) : dif[DATA_WIDTH-1:0];
endmodule