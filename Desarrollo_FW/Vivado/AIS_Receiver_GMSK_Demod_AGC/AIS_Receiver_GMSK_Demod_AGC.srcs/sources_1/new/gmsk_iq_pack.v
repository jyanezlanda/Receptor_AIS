module gmsk_iq_pack #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk, aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_i_tdata, input wire s_axis_i_tvalid,
    input  wire signed [DATA_WIDTH-1:0] s_axis_q_tdata, input wire s_axis_q_tvalid,

    output wire [2*DATA_WIDTH-1:0] m_axis_tdata, output wire m_axis_tvalid
);
    assign m_axis_tdata  = {s_axis_q_tdata, s_axis_i_tdata};
    assign m_axis_tvalid = s_axis_i_tvalid && s_axis_q_tvalid;
endmodule