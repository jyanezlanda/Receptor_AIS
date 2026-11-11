// ============================================================
// gmsk_dc_tracker.v
//
// Seguidor de DC: filtro IIR de un polo, dc <- dc + (soft - dc) / 2^S, una vez por muestra valida.
//
// Tras cada reset usa S = SHIFT_RAPIDO durante las primeras N_RAPIDO muestras validas y despues S = SHIFT. Asi el DC
// (por ejemplo el que mete un error de frecuencia de la portadora) se estima rapido al comienzo de la rafaga y luego
// se sigue lento. Con N_RAPIDO = 0 usa siempre SHIFT.
//
// dc_tdata es la estimacion previa a la muestra actual.
// ============================================================

module gmsk_dc_tracker #(
    parameter DATA_WIDTH   = 24,
    parameter SHIFT        = 5,
    parameter SHIFT_RAPIDO = 5,        // 1 <= SHIFT_RAPIDO <= SHIFT
    parameter N_RAPIDO     = 0         // muestras validas con SHIFT_RAPIDO despues del reset
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_soft_tdata,
    input  wire        s_axis_soft_tvalid,

    output reg  signed [DATA_WIDTH-1:0] dc_tdata,
    output reg         dc_tvalid
);
    localparam DIF = SHIFT - SHIFT_RAPIDO;
    localparam CW  = $clog2(N_RAPIDO + 1);

    reg signed [DATA_WIDTH+SHIFT-1:0] acc;
    reg [(CW > 0 ? CW : 1)-1:0]       cuenta;

    wire signed [DATA_WIDTH-1:0] dc_actual = acc[DATA_WIDTH+SHIFT-1:SHIFT];
    wire signed [DATA_WIDTH:0]   error     = s_axis_soft_tdata - dc_actual;   // 1 bit extra: soft-dc puede exceder DATA_WIDTH bits
    wire                         rapido    = (cuenta < N_RAPIDO);
    wire signed [DATA_WIDTH+SHIFT:0] error_ext = error;
    wire signed [DATA_WIDTH+SHIFT:0] paso      = rapido ? (error_ext <<< DIF) : error_ext;

    always @(posedge clk) begin
        if (!aresetn) begin
            acc       <= {(DATA_WIDTH+SHIFT){1'b0}};
            cuenta    <= 0;
            dc_tvalid <= 1'b0;
        end else if (s_axis_soft_tvalid) begin
            acc       <= acc + paso;
            if (rapido) cuenta <= cuenta + 1'b1;
            dc_tdata  <= dc_actual;
            dc_tvalid <= 1'b1;
        end else begin
            dc_tvalid <= 1'b0;
        end
    end

endmodule