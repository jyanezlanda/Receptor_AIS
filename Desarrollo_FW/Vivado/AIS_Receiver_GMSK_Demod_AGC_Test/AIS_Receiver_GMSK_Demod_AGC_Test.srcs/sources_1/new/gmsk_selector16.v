// ============================================================
// gmsk_selector16.v
//
// Selecciona uno de 16 streams AXI4-Stream de 32 bits hacia una sola
// salida (hacia fifo_0), segun 'sel' (4 bits). Cada entrada es un
// stream AXI-Stream normal, ya empaquetado a 32 bits del lado de quien
// lo alimenta (gmsk_pad32, gmsk_iq_unpack32, o conexion directa cuando
// el ancho ya coincide) -- este modulo no concatena ni interpreta
// nada, solo elige cual de los 16 pasa.
// ============================================================

module gmsk_selector16 #(
    parameter DATA_WIDTH = 32
) (
    input  wire        clk,
    input  wire        aresetn,
    input  wire [3:0]  sel,

    input  wire [DATA_WIDTH-1:0]  s0_tdata, input wire  s0_tvalid,
    input  wire [DATA_WIDTH-1:0]  s1_tdata, input wire  s1_tvalid,
    input  wire [DATA_WIDTH-1:0]  s2_tdata, input wire  s2_tvalid,
    input  wire [DATA_WIDTH-1:0]  s3_tdata, input wire  s3_tvalid,
    input  wire [DATA_WIDTH-1:0]  s4_tdata, input wire  s4_tvalid,
    input  wire [DATA_WIDTH-1:0]  s5_tdata, input wire  s5_tvalid,
    input  wire [DATA_WIDTH-1:0]  s6_tdata, input wire  s6_tvalid,
    input  wire [DATA_WIDTH-1:0]  s7_tdata, input wire  s7_tvalid,
    input  wire [DATA_WIDTH-1:0]  s8_tdata, input wire  s8_tvalid,
    input  wire [DATA_WIDTH-1:0]  s9_tdata, input wire  s9_tvalid,
    input  wire [DATA_WIDTH-1:0] s10_tdata, input wire s10_tvalid,
    input  wire [DATA_WIDTH-1:0] s11_tdata, input wire s11_tvalid,
    input  wire [DATA_WIDTH-1:0] s12_tdata, input wire s12_tvalid,
    input  wire [DATA_WIDTH-1:0] s13_tdata, input wire s13_tvalid,
    input  wire [DATA_WIDTH-1:0] s14_tdata, input wire s14_tvalid,
    input  wire [DATA_WIDTH-1:0] s15_tdata, input wire s15_tvalid,

    output reg  [DATA_WIDTH-1:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    always @(*) begin
        case (sel)
            4'd0:  begin m_axis_tdata =  s0_tdata; m_axis_tvalid =  s0_tvalid; end
            4'd1:  begin m_axis_tdata =  s1_tdata; m_axis_tvalid =  s1_tvalid; end
            4'd2:  begin m_axis_tdata =  s2_tdata; m_axis_tvalid =  s2_tvalid; end
            4'd3:  begin m_axis_tdata =  s3_tdata; m_axis_tvalid =  s3_tvalid; end
            4'd4:  begin m_axis_tdata =  s4_tdata; m_axis_tvalid =  s4_tvalid; end
            4'd5:  begin m_axis_tdata =  s5_tdata; m_axis_tvalid =  s5_tvalid; end
            4'd6:  begin m_axis_tdata =  s6_tdata; m_axis_tvalid =  s6_tvalid; end
            4'd7:  begin m_axis_tdata =  s7_tdata; m_axis_tvalid =  s7_tvalid; end
            4'd8:  begin m_axis_tdata =  s8_tdata; m_axis_tvalid =  s8_tvalid; end
            4'd9:  begin m_axis_tdata =  s9_tdata; m_axis_tvalid =  s9_tvalid; end
            4'd10: begin m_axis_tdata = s10_tdata; m_axis_tvalid = s10_tvalid; end
            4'd11: begin m_axis_tdata = s11_tdata; m_axis_tvalid = s11_tvalid; end
            4'd12: begin m_axis_tdata = s12_tdata; m_axis_tvalid = s12_tvalid; end
            4'd13: begin m_axis_tdata = s13_tdata; m_axis_tvalid = s13_tvalid; end
            4'd14: begin m_axis_tdata = s14_tdata; m_axis_tvalid = s14_tvalid; end
            4'd15: begin m_axis_tdata = s15_tdata; m_axis_tvalid = s15_tvalid; end
        endcase
    end
endmodule