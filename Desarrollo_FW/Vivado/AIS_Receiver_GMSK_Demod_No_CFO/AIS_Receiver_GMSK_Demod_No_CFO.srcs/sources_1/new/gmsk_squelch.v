module gmsk_squelch #(
    parameter PHASE_WIDTH = 16
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [PHASE_WIDTH-1:0] s_axis_mag_tdata,
    input  wire        s_axis_mag_tvalid,

    input  wire [PHASE_WIDTH-1:0] umbral_alto,
    input  wire [PHASE_WIDTH-1:0] umbral_bajo,

    output reg          activo
);
    always @(posedge clk) begin
        if (!aresetn) begin
            activo <= 1'b0;
        end else if (s_axis_mag_tvalid) begin
            if (!activo && s_axis_mag_tdata > umbral_alto)
                activo <= 1'b1;
            else if (activo && s_axis_mag_tdata < umbral_bajo)
                activo <= 1'b0;
        end
    end
endmodule