// ============================================================
// gmsk_integrador.v
//
// Integrador puro (sin fuga): acumula el error CRUDO sin restarle nada,
// a diferencia de gmsk_dc_tracker (que tiene ganancia de CD = 1, actua
// como promediador). Este tiene ganancia de CD INFINITA -- necesario
// para que el lazo de CFO sea Tipo 1 (error de regimen permanente CERO
// frente a una perturbacion constante, como un CFO fijo).
//
// La ganancia se aplica AL LEER (corrimiento a la salida), no al
// escribir -- si se escalara la entrada antes de sumar, un error chico
// (por ejemplo 50) truncaria a 0 con un corrimiento grande, y el
// integrador nunca terminaria de converger. Acumulando crudo en un
// registro ancho, no se pierde resolucion.
//
// GAIN_SHIFT controla que tan rapido corrige: mas alto = mas lento y
// estable, mas bajo = mas rapido pero con mas riesgo de sobrepaso dado
// el retardo de todo el pipeline del lazo -- hay que ajustarlo
// empiricamente, como cualquier ganancia de lazo.
// ============================================================

module gmsk_integrador #(
    parameter IN_WIDTH   = 16,
    parameter OUT_WIDTH  = 16,
    parameter ACC_WIDTH  = 40,
    parameter GAIN_SHIFT = 14
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [IN_WIDTH-1:0] s_axis_err_tdata,
    input  wire        s_axis_err_tvalid,

    output wire signed [OUT_WIDTH-1:0] m_axis_int_tdata,
    output reg         m_axis_int_tvalid
);
    reg signed [ACC_WIDTH-1:0] acc;

    always @(posedge clk) begin
        if (!aresetn) begin
            acc <= {ACC_WIDTH{1'b0}};
            m_axis_int_tvalid <= 1'b0;
        end else if (s_axis_err_tvalid) begin
            acc <= acc + s_axis_err_tdata;
            m_axis_int_tvalid <= 1'b1;
        end
    end

    wire signed [ACC_WIDTH-1:0] salida_escalada = acc >>> GAIN_SHIFT;
    localparam CHEQUEO = ACC_WIDTH-OUT_WIDTH+1;
    wire cabe = (&salida_escalada[ACC_WIDTH-1 -: CHEQUEO]) || (~|salida_escalada[ACC_WIDTH-1 -: CHEQUEO]);

    assign m_axis_int_tdata = cabe ? salida_escalada[OUT_WIDTH-1:0] :
                              (salida_escalada[ACC_WIDTH-1] ? {1'b1, {(OUT_WIDTH-1){1'b0}}}
                                                             : {1'b0, {(OUT_WIDTH-1){1'b1}}});

endmodule
