// ============================================================
// gmsk_bit_pack32.v
//
// Empaqueta el stream de bits ya sincronizados (uno por simbolo) en
// palabras de 32 bits, MSB-primero (el primer bit que llega termina en
// el bit mas significativo de la palabra), listas para escribir al
// FIFO de 32 bits que ya lee el ARM.
// ============================================================

module gmsk_bit_pack32 (
    input  wire        clk,
    input  wire        aresetn,

    input  wire        bit_in,
    input  wire        bit_in_valid,

    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready
);
    reg [31:0] shreg;
    reg [4:0]  contador;   // 0..31

    always @(posedge clk) begin
        if (!aresetn) begin
            contador      <= 5'd0;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (m_axis_tvalid && m_axis_tready)
                m_axis_tvalid <= 1'b0;

            if (bit_in_valid) begin
                shreg <= {shreg[30:0], bit_in};
                if (contador == 5'd31) begin
                    m_axis_tdata  <= {shreg[30:0], bit_in};
                    m_axis_tvalid <= 1'b1;
                    contador      <= 5'd0;
                end else begin
                    contador <= contador + 5'd1;
                end
            end
        end
    end
endmodule