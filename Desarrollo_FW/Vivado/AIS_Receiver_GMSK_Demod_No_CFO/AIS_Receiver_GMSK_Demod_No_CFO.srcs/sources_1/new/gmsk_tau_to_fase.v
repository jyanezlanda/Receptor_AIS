// ============================================================
// gmsk_tau_to_fase.v
//
// Convierte la fase que entrega el CORDIC (angulo/pi de la salida del
// correlador Goertzel, tras pasar por un cmpy si hace falta conjugar,
// y el CORDIC en modo translate) al valor de acumulador de fase que
// gmsk_symbol_strobe necesita para recargarse.
//
// tau_python = (-angulo/(2*pi)) mod 1  ->  en la convencion
// angulo/pi de 16 bits con signo del CORDIC, esto es simplemente
// invertir el signo y reinterpretar como fraccion sin signo de
// ACC_WIDTH bits (una vuelta completa = 1 simbolo).
// ============================================================

module gmsk_tau_to_fase #(
    parameter PHASE_WIDTH = 16,
    parameter ACC_WIDTH   = 32
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [2*PHASE_WIDTH-1:0] s_axis_cordic_tdata,
    input  wire        s_axis_cordic_tvalid,

    output reg  [ACC_WIDTH-1:0] m_axis_carga_tdata,
    output reg         m_axis_carga_tvalid
);
    wire signed [PHASE_WIDTH-1:0] fase = s_axis_cordic_tdata[2*PHASE_WIDTH-1:PHASE_WIDTH];
    
    localparam signed [31:0] MULT_TAU = 32'sd83443;

    localparam signed [ACC_WIDTH-1:0] TRIM_UNA_MUESTRA = 32'sd214748365;
    wire signed [ACC_WIDTH-1:0] carga = -(fase * MULT_TAU) + TRIM_UNA_MUESTRA;

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_carga_tvalid <= 1'b0;
        end else begin
            m_axis_carga_tvalid <= s_axis_cordic_tvalid;
            if (s_axis_cordic_tvalid) begin
                m_axis_carga_tdata <= carga;
            end
        end
    end
endmodule