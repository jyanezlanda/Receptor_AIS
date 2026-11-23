// ============================================================
// gmsk_delay_line.v
//
// Retardo de DELAY ciclos, para igualar la latencia de un stream
// contra otro que llega mas tarde (por ejemplo, soft[n] contra la
// salida de un dds_compiler con latencia propia). Avanza un ciclo por
// vez, independiente del tvalid -- el dato y su validez viajan juntos
// por el mismo pipeline.
// ============================================================

module gmsk_delay_line #(
    parameter DATA_WIDTH = 24,
    parameter DELAY      = 8   // ciclos -- poner igual a la latencia
                                 // reportada del bloque que se quiere igualar
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire        m_axis_tvalid
);
    reg [DATA_WIDTH-1:0] pipe_data [0:DELAY-1];
    reg                  pipe_valid [0:DELAY-1];
    integer k;

    always @(posedge clk) begin
        if (!aresetn) begin
            for (k = 0; k < DELAY; k = k + 1)
                pipe_valid[k] <= 1'b0;
        end else begin
            pipe_data[0]  <= s_axis_tdata;
            pipe_valid[0] <= s_axis_tvalid;
            for (k = 1; k < DELAY; k = k + 1) begin
                pipe_data[k]  <= pipe_data[k-1];
                pipe_valid[k] <= pipe_valid[k-1];
            end
        end
    end

    assign m_axis_tdata  = pipe_data[DELAY-1];
    assign m_axis_tvalid = pipe_valid[DELAY-1];
endmodule