// ============================================================
// gmsk_axis_broadcast2_tready.v
//
// Reparte un flujo AXI-Stream en dos salidas con el mismo dato y sin latencia. Cada salida recibe cada dato exactamente una vez: el dato
// se ofrece a las dos salidas hasta que cada una lo acepta, y la entrada avanza cuando las dos ya lo aceptaron o lo aceptan en este ciclo.
// ============================================================

module gmsk_axis_broadcast2_tready #(
    parameter DATA_WIDTH = 24
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,

    output wire [DATA_WIDTH-1:0] m0_axis_tdata,
    output wire        m0_axis_tvalid,
    input  wire        m0_axis_tready,

    output wire [DATA_WIDTH-1:0] m1_axis_tdata,
    output wire        m1_axis_tvalid,
    input  wire        m1_axis_tready
);
    reg ya0, ya1;                                   // la salida ya acepto el dato que esta en la entrada

    assign m0_axis_tdata  = s_axis_tdata;
    assign m1_axis_tdata  = s_axis_tdata;
    assign m0_axis_tvalid = s_axis_tvalid & ~ya0;
    assign m1_axis_tvalid = s_axis_tvalid & ~ya1;
    assign s_axis_tready  = (ya0 | m0_axis_tready) & (ya1 | m1_axis_tready);

    always @(posedge clk) begin
        if (!aresetn) begin
            ya0 <= 1'b0;
            ya1 <= 1'b0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            ya0 <= 1'b0;
            ya1 <= 1'b0;
        end else begin
            if (m0_axis_tvalid && m0_axis_tready) ya0 <= 1'b1;
            if (m1_axis_tvalid && m1_axis_tready) ya1 <= 1'b1;
        end
    end
endmodule