// ============================================================
// gmsk_axis_mux2.v
//
// Selecciona entre dos streams AXI4-Stream hacia una sola salida,
// segun 'sel' (0=A, 1=B). Pensado para elegir, en caliente desde el
// PS, si el FIFO de lectura recibe bits demodulados (operacion normal)
// o muestras de magnitud cruda (modo calibracion del squelch).
// ============================================================

module gmsk_axis_mux2 #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk,
    input  wire        aresetn,
    input  wire        sel,

    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire        s_axis_a_tvalid,

    input  wire [DATA_WIDTH-1:0] s_axis_b_tdata,
    input  wire        s_axis_b_tvalid,

    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire        m_axis_tvalid
);
    assign m_axis_tdata  = sel ? s_axis_b_tdata  : s_axis_a_tdata;
    assign m_axis_tvalid = sel ? s_axis_b_tvalid : s_axis_a_tvalid;
endmodule