// ============================================================
// gmsk_iq_unpack32.v
//
// Convierte un stream de 64 bits (I+Q empaquetados, misma convencion
// que gmsk_iq_pack) en dos palabras CONSECUTIVAS de 32 bits (I, despues
// Q) -- para poder mandar un punto de prueba de 64 bits al FIFO de 32
// bits, sin tocar nada del lado del servidor: read_adc ya interpreta
// cada par de palabras de 32 bits como una muestra compleja.
// ============================================================

module gmsk_iq_unpack32 (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [63:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid
);
    reg        fase;
    reg [31:0] q_guardado;

    always @(posedge clk) begin
        if (!aresetn) begin
            fase <= 1'b0;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (fase == 1'b0) begin
                if (s_axis_tvalid) begin
                    m_axis_tdata  <= s_axis_tdata[31:0];
                    q_guardado    <= s_axis_tdata[63:32];
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