// ============================================================
// gmsk_pad32.v
//
// Rellena una señal angosta (soft[n], bit_crudo, etc.) a 32 bits con
// ceros/signo, para poder mandarla al FIFO de 32 bits como punto de
// prueba temporal. Generico -- sirve para cualquier ancho de entrada.
// ============================================================

module gmsk_pad32 #(
    parameter IN_WIDTH = 24,
    parameter CON_SIGNO = 1   // 1 = extender signo, 0 = rellenar con cero
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [IN_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    wire relleno_bit = CON_SIGNO ? s_axis_tdata[IN_WIDTH-1] : 1'b0;

    always @(posedge clk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tdata  <= {{(32-IN_WIDTH){relleno_bit}}, s_axis_tdata};
            m_axis_tvalid <= s_axis_tvalid;
        end
    end
endmodule