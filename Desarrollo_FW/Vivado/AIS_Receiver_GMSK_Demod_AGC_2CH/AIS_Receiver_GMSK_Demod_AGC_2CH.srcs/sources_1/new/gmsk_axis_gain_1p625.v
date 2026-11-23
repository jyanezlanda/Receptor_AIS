// ============================================================
// gmsk_axis_gain_1p625.v
//
// Multiplica por 1,625 (= 1 + 1/2 + 1/8, +4,2 dB) un flujo AXI-Stream de datos con signo, con saturacion al ancho de entrada.
// Un registro de salida (latencia de un ciclo) y handshake completo: no pierde ni repite datos. Solo sumadores, sin DSP.
// ============================================================

module gmsk_axis_gain_1p625 #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,

    output reg  signed [DATA_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready
);
    localparam EW = DATA_WIDTH + 2;
    localparam signed [EW-1:0] MAXV = {3'b000, {(DATA_WIDTH-1){1'b1}}};
    localparam signed [EW-1:0] MINV = {3'b111, {(DATA_WIDTH-1){1'b0}}};

    wire signed [EW-1:0] x = s_axis_tdata;
    wire signed [EW-1:0] y = x + (x >>> 1) + (x >>> 3);

    assign s_axis_tready = m_axis_tready | ~m_axis_tvalid;

    always @(posedge clk) begin
        if (!aresetn)
            m_axis_tvalid <= 1'b0;
        else if (s_axis_tready)
            m_axis_tvalid <= s_axis_tvalid;

        if (s_axis_tready)
            m_axis_tdata <= (y > MAXV) ? MAXV[DATA_WIDTH-1:0] : (y < MINV) ? MINV[DATA_WIDTH-1:0] : y[DATA_WIDTH-1:0];
    end
endmodule