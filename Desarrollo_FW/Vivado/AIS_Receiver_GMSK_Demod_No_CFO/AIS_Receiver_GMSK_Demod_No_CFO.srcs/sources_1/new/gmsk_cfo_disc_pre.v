// ============================================================
// gmsk_cfo_disc_pre.v
//
// Prepara z4[n] y conj(z4[n-1]) para el cmpy discriminador del detector
// de error de frecuencia (mismo patron que gmsk_discriminator_pre, pero
// la entrada ya viene empaquetada como salida de un cmpy -- 48 bits,
// {IMAG[47:24],REAL[23:0]} -- en vez de dos streams de 32 bits del FIR).
// ============================================================

module gmsk_cfo_disc_pre (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [47:0] s_axis_z4_tdata,
    input  wire        s_axis_z4_tvalid,

    output wire [47:0] m_axis_a_tdata,
    output wire        m_axis_a_tvalid,

    output wire [47:0] m_axis_b_tdata,
    output wire        m_axis_b_tvalid
);
    wire signed [23:0] z4_actual_I = s_axis_z4_tdata[23:0];
    wire signed [23:0] z4_actual_Q = s_axis_z4_tdata[47:24];

    reg signed [23:0] z4_prev_I, z4_prev_Q;
    reg               tiene_muestra_previa;

    always @(posedge clk) begin
        if (!aresetn) begin
            z4_prev_I <= 24'sd0; z4_prev_Q <= 24'sd0;
            tiene_muestra_previa <= 1'b0;
        end else if (s_axis_z4_tvalid) begin
            z4_prev_I <= z4_actual_I; z4_prev_Q <= z4_actual_Q;
            tiene_muestra_previa <= 1'b1;
        end
    end

    assign m_axis_a_tdata  = s_axis_z4_tdata;
    assign m_axis_a_tvalid = s_axis_z4_tvalid && tiene_muestra_previa;

    wire signed [23:0] z4_prev_Q_neg = -z4_prev_Q;
    assign m_axis_b_tdata  = {z4_prev_Q_neg, z4_prev_I};
    assign m_axis_b_tvalid = s_axis_z4_tvalid && tiene_muestra_previa;
endmodule