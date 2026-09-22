// ============================================================
// gmsk_axis_add2.v
//
// Suma dos streams AXI4-Stream, ciclo a ciclo. Asume que las dos
// entradas ya llegan sincronizadas (mismo tvalid, en el mismo ciclo) --
// valido para el caso de uso previsto (gmsk_dc_tracker + gmsk_integrador,
// alimentados por la misma fuente, con la misma latencia de 1 ciclo
// cada uno). Si en algun momento se usa con dos fuentes de latencia
// distinta, hace falta igualarlas primero (ver gmsk_delay_line) --
// este modulo no resincroniza nada por su cuenta.
// ============================================================

module gmsk_axis_add2 #(
    parameter IN_WIDTH  = 16,
    parameter OUT_WIDTH = 17   // 1 bit extra para no recortar la suma en silencio
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [IN_WIDTH-1:0] s_axis_a_tdata,
    input  wire        s_axis_a_tvalid,

    input  wire signed [IN_WIDTH-1:0] s_axis_b_tdata,
    input  wire        s_axis_b_tvalid,

    output reg  signed [OUT_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tdata  <= s_axis_a_tdata + s_axis_b_tdata;
            m_axis_tvalid <= s_axis_a_tvalid && s_axis_b_tvalid;
        end
    end
endmodule