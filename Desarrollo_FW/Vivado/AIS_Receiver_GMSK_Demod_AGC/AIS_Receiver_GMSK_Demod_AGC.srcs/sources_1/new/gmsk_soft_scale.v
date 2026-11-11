// ============================================================
// gmsk_soft_scale.v
//
// Etapa final: recibe el TDATA completo del CORDIC (translate), aisla
// el campo de fase, y escala a soft[n] (soft = angulo_radianes / sensitivity).
// ============================================================

module gmsk_soft_scale #(
    parameter PHASE_WIDTH = 16,
    parameter SOFT_WIDTH  = 24
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [PHASE_WIDTH-1:0] s_axis_phase_tdata,
    input  wire        s_axis_phase_tvalid,

    output reg  signed [SOFT_WIDTH-1:0] m_axis_soft_tdata,
    output reg         m_axis_soft_tvalid
);
    localparam signed [15:0] MULT_ANGULO_A_SOFT = 16'sd13037;

    wire signed [PHASE_WIDTH+16-1:0] producto = s_axis_phase_tdata * MULT_ANGULO_A_SOFT;

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_soft_tvalid <= 1'b0;
        end else begin
            m_axis_soft_tdata  <= producto >>> 8;
            m_axis_soft_tvalid <= s_axis_phase_tvalid;
        end
    end
endmodule