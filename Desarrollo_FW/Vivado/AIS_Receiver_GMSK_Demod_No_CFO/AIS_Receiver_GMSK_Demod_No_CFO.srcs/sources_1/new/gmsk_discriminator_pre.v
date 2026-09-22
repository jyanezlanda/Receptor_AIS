// ============================================================
// gmsk_discriminator_pre.v
//
// Version de UNA sola entrada empaquetada (I y Q juntos en 64 bits) --
// la que corresponde ahora que el discriminador va DESPUES del
// rotador de CFO, recibiendo iq_corregido ya empaquetado desde el
// broadcaster, no directo del FIR.
// ============================================================

module gmsk_discriminator_pre (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [63:0] s_axis_iq_tdata,
    input  wire        s_axis_iq_tvalid,

    output wire [63:0] m_axis_a_tdata,
    output wire        m_axis_a_tvalid,

    output wire [63:0] m_axis_b_tdata,
    output wire        m_axis_b_tvalid
);
    wire signed [31:0] z_actual_I = s_axis_iq_tdata[31:0];
    wire signed [31:0] z_actual_Q = s_axis_iq_tdata[63:32];

    reg signed [31:0] z_prev_I, z_prev_Q;
    reg               tiene_muestra_previa;

    always @(posedge clk) begin
        if (!aresetn) begin
            z_prev_I             <= 32'sd0;
            z_prev_Q             <= 32'sd0;
            tiene_muestra_previa <= 1'b0;
        end else if (s_axis_iq_tvalid) begin
            z_prev_I             <= z_actual_I;
            z_prev_Q             <= z_actual_Q;
            tiene_muestra_previa <= 1'b1;
        end
    end

    assign m_axis_a_tdata  = s_axis_iq_tdata;
    assign m_axis_a_tvalid = s_axis_iq_tvalid && tiene_muestra_previa;

    wire signed [31:0] z_prev_Q_neg = -z_prev_Q;
    assign m_axis_b_tdata  = {z_prev_Q_neg, z_prev_I};
    assign m_axis_b_tvalid = s_axis_iq_tvalid && tiene_muestra_previa;
endmodule