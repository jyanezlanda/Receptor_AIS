// ============================================================
// gmsk_iq_unpack48to32.v
//
// Convierte un stream de 48 bits (I+Q de 24 bits cada uno, misma
// convencion que la salida de un cmpy) en dos palabras CONSECUTIVAS
// de 32 bits (I, despues Q) -- cada componente se extiende en signo
// de 24 a 32 bits antes de salir. Mismo patron que gmsk_iq_unpack32
// ============================================================

module gmsk_iq_unpack48to32 #(
    parameter DATA_WIDTH = 24   // ancho de CADA componente en la entrada
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [2*DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    reg        fase;
    reg signed [31:0] q_guardado;

    wire signed [DATA_WIDTH-1:0] i_in = s_axis_tdata[DATA_WIDTH-1:0];
    wire signed [DATA_WIDTH-1:0] q_in = s_axis_tdata[2*DATA_WIDTH-1:DATA_WIDTH];

    // extension de signo de DATA_WIDTH a 32 bits
    wire signed [31:0] i_extendido = {{(32-DATA_WIDTH){i_in[DATA_WIDTH-1]}}, i_in};
    wire signed [31:0] q_extendido = {{(32-DATA_WIDTH){q_in[DATA_WIDTH-1]}}, q_in};

    always @(posedge clk) begin
        if (!aresetn) begin
            fase <= 1'b0;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (fase == 1'b0) begin
                if (s_axis_tvalid) begin
                    m_axis_tdata  <= i_extendido;
                    q_guardado    <= q_extendido;
                    m_axis_tvalid <= 1'b1;
                    fase          <= 1'b1;
                end else begin
                    m_axis_tvalid <= 1'b0;
                end
            end else begin
                m_axis_tdata  <= q_guardado;
                m_axis_tvalid <= 1'b1;
                fase          <= 1'b0;
            end
        end
    end
endmodule