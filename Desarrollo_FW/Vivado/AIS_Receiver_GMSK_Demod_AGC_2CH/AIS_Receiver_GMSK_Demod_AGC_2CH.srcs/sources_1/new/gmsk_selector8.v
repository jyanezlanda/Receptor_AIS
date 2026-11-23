// ============================================================
// gmsk_selector8.v
//
// Selecciona uno de 8 streams AXI4-Stream de 32 bits hacia una sola
// salida (hacia fifo_0), segun 'sel'. Pensado para probar distintos
// puntos de la cadena sin resintetizar entre uno y otro -- 'sel' se
// controla desde el PS por el mismo mecanismo que ya usa el modo de
// calibracion del squelch.
//
//   sel=0: salida normal (gmsk_bit_pack32, la de siempre)
//   sel=1: FIR (I/Q empaquetado -> gmsk_iq_unpack32)
//   sel=2: rotador (iq_corregido -> gmsk_iq_unpack32)
//   sel=3: soft[n] (gmsk_pad32, con signo)
//   sel=4: bit_crudo, antes del NRZI (gmsk_pad32, sin signo)
// ============================================================

module gmsk_selector8 #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk,
    input  wire        aresetn,
    input  wire [2:0]  sel,

    input  wire [DATA_WIDTH-1:0] s0_tdata, input wire s0_tvalid,
    input  wire [DATA_WIDTH-1:0] s1_tdata, input wire s1_tvalid,
    input  wire [DATA_WIDTH-1:0] s2_tdata, input wire s2_tvalid,
    input  wire [DATA_WIDTH-1:0] s3_tdata, input wire s3_tvalid,
    input  wire [DATA_WIDTH-1:0] s4_tdata, input wire s4_tvalid,
    input  wire [DATA_WIDTH-1:0] s5_tdata, input wire s5_tvalid,
    input  wire [DATA_WIDTH-1:0] s6_tdata, input wire s6_tvalid,
    input  wire [DATA_WIDTH-1:0] s7_tdata, input wire s7_tvalid,

    output reg  [DATA_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    always @(*) begin
        case (sel)
            3'd0: begin m_axis_tdata = s0_tdata; m_axis_tvalid = s0_tvalid; end
            3'd1: begin m_axis_tdata = s1_tdata; m_axis_tvalid = s1_tvalid; end
            3'd2: begin m_axis_tdata = s2_tdata; m_axis_tvalid = s2_tvalid; end
            3'd3: begin m_axis_tdata = s3_tdata; m_axis_tvalid = s3_tvalid; end
            3'd4: begin m_axis_tdata = s4_tdata; m_axis_tvalid = s4_tvalid; end
            3'd5: begin m_axis_tdata = s5_tdata; m_axis_tvalid = s5_tvalid; end
            3'd6: begin m_axis_tdata = s6_tdata; m_axis_tvalid = s6_tvalid; end
            3'd7: begin m_axis_tdata = s7_tdata; m_axis_tvalid = s7_tvalid; end
            default: begin m_axis_tdata = {DATA_WIDTH{1'b0}}; m_axis_tvalid = 1'b0; end
        endcase
    end
endmodule