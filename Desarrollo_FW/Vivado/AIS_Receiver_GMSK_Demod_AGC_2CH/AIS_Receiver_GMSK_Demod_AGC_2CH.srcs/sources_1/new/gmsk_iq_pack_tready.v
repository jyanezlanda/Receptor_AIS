// ============================================================
// gmsk_iq_pack_tready.v
//
// Junta dos flujos AXI-Stream (I y Q) en uno, {Q, I}. Una transferencia de salida consume un dato de cada entrada a la vez: cada entrada
// solo se acepta cuando la otra tambien tiene dato y la salida esta lista.
// ============================================================

module gmsk_iq_pack_tready #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk, aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_i_tdata, input wire s_axis_i_tvalid, output wire s_axis_i_tready,
    input  wire signed [DATA_WIDTH-1:0] s_axis_q_tdata, input wire s_axis_q_tvalid, output wire s_axis_q_tready,

    output wire [2*DATA_WIDTH-1:0] m_axis_tdata, output wire m_axis_tvalid, input wire m_axis_tready
);
    assign m_axis_tdata    = {s_axis_q_tdata, s_axis_i_tdata};
    assign m_axis_tvalid   = s_axis_i_tvalid && s_axis_q_tvalid;
    assign s_axis_i_tready = m_axis_tready && s_axis_q_tvalid;
    assign s_axis_q_tready = m_axis_tready && s_axis_i_tvalid;
endmodule